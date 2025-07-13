import { asyncHandler } from "../utils/asyncHandler.js";
import { apiError } from "../utils/apiError.js";
import { apiResponse } from "../utils/apiResponse.js";
import { User } from "../models/user_model.js";

// 1. Get all mentors from current user's year who are marked as eligible
const getAvailableMentors = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const user = await User.findById(userId);
  const admissionYear = user.yearOfAdmission;
  const availableMentors = await User.find({
    yearOfAdmission: user.yearOfAdmission,
    isMentorEligible: true,
  }).select("-password -refreshToken");

  if (!availableMentors) throw new apiError(500, "Error fetching mentors !!");
  return res
    .status(200)
    .json(
      new apiResponse(200, availableMentors, "Mentors fetched successfully !!")
    );
});

// 2. Send a mentor request to someone
const sendMenteeRequest = asyncHandler(async (req, res) => {
  const { mentorId } = req.body;
  const menteeId = req.user._id;

  if (!mentorId) throw new apiError(400, "Mentor ID is required");
  if (mentorId.toString() === menteeId.toString())
    throw new apiError(400, "You cannot select yourself as mentor");

  const mentorUser = await User.findById(mentorId);
  const menteeUser = await User.findById(menteeId);

  if (!mentorUser || !menteeUser)
    throw new apiError(404, "Mentor or mentee not found");

  const mentorYear = mentorUser.yearOfAdmission;
  const menteeYear = menteeUser.yearOfAdmission;
  if (mentorYear + 1 !== menteeYear || !mentorUser.isMentorEligible)
    throw new apiError(403, "Selected user is not an eligible mentor");

  if (menteeUser.menteeToMentorId)
    throw new apiError(409, "You already have a mentor");

  menteeUser.menteeToMentorId = mentorUser._id;
  mentorUser.mentorToMenteeIds.push(menteeUser._id);

  await menteeUser.save();
  await mentorUser.save();

  return res
    .status(200)
    .json(new apiResponse(200, null, "Mentor connected successfully"));
});

// 3. Get current user's mentor (if they have one)
const getMyMentor = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const user = await User.findById(userId).populate(
    "menteeToMentorId",
    "-password -refreshToken"
  );

  if (!user.menteeToMentorId) {
    return res
      .status(200)
      .json(new apiResponse(200, null, "No mentor assigned"));
  }

  return res
    .status(200)
    .json(new apiResponse(200, user.menteeToMentorId, "Mentor found"));
});

// 4. Get current user's mentees (if they are a mentor)
const getMyMentees = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const user = await User.findById(userId).populate(
    "mentorToMenteeIds",
    "-password -refreshToken"
  );

  if (!user.isMentorEligible)
    throw new apiError(403, "User is not marked as a mentor");

  const mentees = user.mentorToMenteeIds;

  if (!mentees || mentees.length === 0) {
    return res
      .status(200)
      .json(new apiResponse(200, [], "No mentees assigned"));
  }

  return res
    .status(200)
    .json(new apiResponse(200, mentees, "Mentees fetched successfully"));
});

export { getAvailableMentors, sendMenteeRequest, getMyMentor, getMyMentees };
