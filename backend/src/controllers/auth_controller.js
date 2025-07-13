import { asyncHandler } from "../utils/asyncHandler.js";
import { apiError } from "../utils/apiError.js";
import { User } from "../models/user_model.js";
import { apiResponse } from "../utils/apiResponse.js";
import jwt from "jsonwebtoken";
import { OtpToken } from "../models/otp_token_model.js";
import bcrypt from "bcrypt";
import { sendEmail } from "../utils/sendEmail.js";

const generateAccessAndRefreshToken = async (userId) => {
  try {
    const user = await User.findById(userId);
    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    user.refreshToken = refreshToken;
    await user.save({ validateBeforeSave: false });

    return { accessToken, refreshToken };
  } catch (error) {
    throw new apiError(500, error.message);
  }
};

const extractYearFromEmail = (email) => {
  const match = email.match(/\.([0-9]{2})@bitmesra\.ac\.in$/);
  if (!match) return null;
  const yearSuffix = parseInt(match[1], 10);
  const century = new Date().getFullYear().toString().slice(0, 2);
  return parseInt(`${century}${yearSuffix}`, 10);
};

const registerUser = asyncHandler(async (req, res) => {
  const { name, email, password, otp } = req.body;
  // --- STEP 1: Send OTP ---
  if (email && !otp && !name && !password) {
    const existingUser = await User.findOne({ email });
    if (existingUser) throw new apiError(400, "User already exists");

    const existingToken = await OtpToken.findOne({ email });
    if (existingToken) await OtpToken.deleteOne({ email });

    const rawOtp = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedOtp = await bcrypt.hash(rawOtp, 10);

    await OtpToken.create({ email, otp: hashedOtp });

    await sendEmail({
      to: email,
      subject: "Your OTP for MyCollegeApp",
      text: `Your OTP is ${rawOtp}. It will expire in 5 minutes.`,
    });

    return res
      .status(200)
      .json(new apiResponse(200, null, "OTP sent successfully"));
  }

  // --- STEP 2: Verify OTP and Register ---
  if (email && otp && name && password) {
    const existingUser = await User.findOne({ email });
    if (existingUser) throw new apiError(400, "User already exists");

    const otpRecord = await OtpToken.findOne({ email });
    if (!otpRecord) throw new apiError(400, "OTP expired or not found");

    const isOtpValid = await bcrypt.compare(otp, otpRecord.otp);
    if (!isOtpValid) throw new apiError(400, "Invalid OTP");

    await OtpToken.deleteOne({ email }); // Clean up used OTP

    const yearOfAdmission = extractYearFromEmail(email);
    if (!yearOfAdmission) {
      throw new apiError(400, "Invalid institute email format");
    }

    const user = await User.create({
      email,
      password,
      name,
      yearOfAdmission,
    });

    const safeUser = await User.findById(user._id).select("-password");

    return res
      .status(201)
      .json(new apiResponse(201, safeUser, "User registered successfully"));
  }

  // If neither case matched:
  throw new apiError(400, "Invalid registration step or missing fields");
});

const loginUser = asyncHandler(async (req, res) => {
  let { email, password } = req.body;

  if (!email?.trim()) throw new apiError(400, "Email is required");
  if (!password?.trim()) throw new apiError(400, "Password is required");

  const currentUser = await User.findOne({
    $or: [{ email: email }],
  });

  if (!currentUser) throw new apiError(404, "User does not exist");

  const isPasswordValid = await currentUser.isPasswordCorrect(password);
  if (!isPasswordValid) throw new apiError(401, "Wrong Password");

  const { accessToken, refreshToken } = await generateAccessAndRefreshToken(
    currentUser._id
  );

  const loggedInUser = await User.findById(currentUser._id).select(
    "-password -refreshToken"
  );
  const options = {
    httpOnly: true,
    secure: true,
  };

  return res
    .status(200)
    .cookie("accessToken", accessToken, options)
    .cookie("refreshToken", refreshToken, options)
    .json(
      new apiResponse(
        200,
        {
          user: loggedInUser,
          accessToken,
          refreshToken,
        },
        "User logged in successfully"
      )
    );
});

const logoutUser = asyncHandler(async (req, res) => {
  await User.findByIdAndUpdate(
    req.user._id,
    {
      $set: {
        refreshToken: "",
      },
    },
    {
      new: true,
    }
  );
  const options = {
    httpOnly: true,
    secure: true,
  };
  return res
    .status(200)
    .clearCookie("accessToken", options)
    .clearCookie("refreshToken", options)
    .json(new apiResponse(200, {}, "User logged out successfully"));
});

const refreshAccessToken = asyncHandler(async (req, res) => {
  const incomingRefreshToken =
    req.cookies.refreshToken || req.body.refreshToken;
  if (!incomingRefreshToken) throw new apiError(400, "Unauthorized User");
  try {
    const decodedToken = jwt.verify(
      incomingRefreshToken,
      process.env.REFRESH_TOKEN_SECRET
    );
    if (!decodedToken) throw new apiError(400, "Unauthorized User");

    const user = await User.findById(decodedToken?._id);
    if (!user) throw new apiError(401, "Invalid Refresh Token");

    const options = {
      httpOnly: true,
      secure: true,
    };

    if (incomingRefreshToken != user?.refreshToken)
      throw new apiError(400, "Refresh Token has expired");

    const { newAccessToken, newRefreshToken } =
      await generateAccessAndRefreshToken(user._id);
    return res
      .status(200)
      .cookie("accessToken", newAccessToken, options)
      .cookie("refreshToken", newRefreshToken, options)
      .json(
        new apiResponse(
          200,
          { newAccessToken, newRefreshToken },
          "Access Token refreshed successfully !!"
        )
      );
  } catch (error) {
    throw new apiError(400, error?.message || "Invalid Token");
  }
});

const changeCurrentPassword = asyncHandler(async (req, res) => {
  const { oldPassword, newPassword } = req.body;
  const user = await User.findById(req.user?._id);

  if (!user.isPasswordCorrect(oldPassword))
    throw new apiError(400, "Existing Password does not match !");

  user.password = newPassword;
  await user.save({ validateBeforeSave: false });

  return res
    .status(200)
    .json(new apiResponse(200, {}, "Password Changes Successfully"));
});

const getCurrentUser = asyncHandler(async (req, res) => {
  if (!req.user) throw new apiError(401, "No user signed in !!");
  const user = await User.findById(req.user?._id).select(
    "-password -refreshToken"
  );
  return res
    .status(200)
    .json(new apiResponse(200, { user }, "Current Logged In User"));
});

const updateAccountDetails = asyncHandler(async (req, res) => {
  const { name } = req.body;
  if (!name) throw new apiError(400, "Name required");

  const user = await User.findByIdAndUpdate(
    req.user._id,
    {
      $set: {
        name: name,
      },
    },
    {
      new: true,
    }
  ).select("-password");

  return res
    .status(200)
    .json(new apiResponse(200, user, "Account Details Updated !!"));
});

export {
  registerUser,
  loginUser,
  logoutUser,
  refreshAccessToken,
  changeCurrentPassword,
  getCurrentUser,
  updateAccountDetails,
};
