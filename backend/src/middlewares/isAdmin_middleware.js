import { asyncHandler } from "../utils/asyncHandler.js";
import { apiError } from "../utils/apiError.js";
import { User } from "../models/user_model.js";

export const checkIsAdmin = asyncHandler(async (req, res, next) => {
  try {
    const userId = req.user._id;
  const user = await User.findById(userId);
  if (!user || !user.isAdmin) {
    throw new apiError(403, "Access denied");
  }
  next();
  } catch (error) {
    throw new apiError(402, error?.message || "Not an Admin")
  }
});
