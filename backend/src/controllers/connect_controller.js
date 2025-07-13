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
  // implementation
});

// 3. Accept a mentor request (mentor accepts a mentee)
const acceptMenteeRequest = asyncHandler(async (req, res) => {
  // implementation
});

// 4. Reject a mentor request
const rejectMenteeRequest = asyncHandler(async (req, res) => {
  // implementation
});

// 5. Get current user's mentor (if they have one)
const getMyMentor = asyncHandler(async (req, res) => {
  // implementation
});

// 6. Get current user's mentees (if they are a mentor)
const getMyMentees = asyncHandler(async (req, res) => {
  // implementation
});

// 7. Remove an existing mentor-mentee relationship
const removeMentorMenteeConnection = asyncHandler(async (req, res) => {
  // implementation
});

export {
  getAvailableMentors,
  sendMenteeRequest,
  acceptMenteeRequest,
  rejectMenteeRequest,
  getMyMentor,
  getMyMentees,
  removeMentorMenteeConnection,
};
