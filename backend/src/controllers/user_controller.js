import { asyncHandler } from "../utils/asyncHandler.js";
import { apiError } from "../utils/apiError.js";
import { apiResponse } from "../utils/apiResponse.js";
import { User } from "../models/user_model.js";

const getStudentsByYear = asyncHandler(async (req, res) => {
  const yearOfAdmission = parseInt(req.params.yearOfAdmission);
  if (isNaN(yearOfAdmission))
    throw new apiError(400, "Invalid year of admission");

  const students = await User.find({
    yearOfAdmission,
  }).select("-password -refreshToken");

  return res
    .status(200)
    .json(new apiResponse(200, students, "Students fetched"));
});

const toggleAdminStatus = asyncHandler(async (req, res) => {
  const { toToggleUserId } = req.body;
  if (!toToggleUserId) throw new apiError(400, "Missing user ID");

  const adminUser = await User.findById(req.user._id);
  const toToggleUser = await User.findById(toToggleUserId);
  if (!toToggleUser) throw new apiError(404, "User not found");

  if (toToggleUser.yearOfAdmission !== adminUser.yearOfAdmission + 1) {
    throw new apiError(
      403,
      "You can only modify admin status of your immediate junior"
    );
  }

  await User.findByIdAndUpdate(toToggleUserId, {
    isAdmin: !toToggleUser.isAdmin,
  });

  return res
    .status(200)
    .json(new apiResponse(200, {}, "Admin status updated !!"));
});

const toggleMentorEligibility = asyncHandler(async (req, res) => {
  const { toToggleUserId } = req.body;
  if (!toToggleUserId) throw new apiError(400, "Missing user ID");

  const adminUser = await User.findById(req.user._id);
  const toToggleUser = await User.findById(toToggleUserId);
  if (!toToggleUser) throw new apiError(404, "User not found");

  if (toToggleUser.yearOfAdmission !== adminUser.yearOfAdmission) {
    throw new apiError(
      403,
      "You can only modify mentor status of your own year"
    );
  }

  const isRevoking = toToggleUser.isMentorEligible;

  if (isRevoking) {
    await User.updateMany(
      { _id: { $in: toToggleUser.mentorToMenteeIds } },
      { $unset: { menteeToMentorId: "" } }
    );
    toToggleUser.mentorToMenteeIds = [];
    await toToggleUser.save();
  }


  const updatedUser = await User.findByIdAndUpdate(toToggleUserId, {
    isMentorEligible: !toToggleUser.isMentorEligible,
  });

  return res
    .status(200)
    .json(new apiResponse(200, {}, "Mentor eligiblitiy status updated !!"));
});

export { getStudentsByYear, toggleAdminStatus, toggleMentorEligibility };
