import { asyncHandler } from "../utils/asyncHandler.js";
import { apiError } from "../utils/apiError.js";
import { apiResponse } from "../utils/apiResponse.js";
import { CourseStructure } from "../models/course_model.js";
import {
  uploadOnCloudinary,
  deleteFromCloudinary,
} from "../utils/cloudinary.js";

const getAllCourseStructures = asyncHandler(async (req, res) => {
  const allCourses = await CourseStructure.find()
    .sort({ semester: 1 })
    .populate("uploadedBy", "-password -refreshToken");

  return res
    .status(200)
    .json(new apiResponse(200, allCourses, "All courses fetched"));
});


const getCoursesBySemester = asyncHandler(async (req, res) => {
  const semester = parseInt(req.params.semester);

  if (isNaN(semester) || semester <= 0 || semester >= 11)
    throw new apiError(400, "Semester does not exist");

  const allCourses = await CourseStructure.find({ semester })
    .sort({ courseName: 1 })
    .populate("uploadedBy", "-password -refreshToken");

  return res
    .status(200)
    .json(new apiResponse(200, allCourses, "Courses for the semster fetched"));
});


const getCourseById = asyncHandler(async (req, res) => {
  const courseId = req.params.courseId;
  if (!courseId) throw new apiError(404, "Missing courseId");

  const course = await CourseStructure.findOne({ courseId }).populate(
    "uploadedBy",
    "-password -refreshToken"
  );
  if (!course) throw new apiError(404, "Missing or Invalid courseId");

  return res
    .status(200)
    .json(new apiResponse(200, course, "Course fetched !!"));
});


const uploadCourseStructure = asyncHandler(async (req, res) => {
  const pdfPath = req?.files?.coursePdf?.[0]?.path;
  if (!pdfPath) throw new apiError(404, "File not found");

  const { courseId, courseName, semester } = req.body;
  const uploadedBy = req?.user?._id;
  if (!uploadedBy) throw new apiError(402, "Not logged in");
  if (!courseId || !courseName || !semester)
    throw new apiError(400, "courseId, courseName, and semester are required");

  const existingCourse = await CourseStructure.findOne({ courseId });
  if (existingCourse)
    throw new apiError(409, "Course with the same ID already exists");

  try {
    const pdfUrl = await uploadOnCloudinary(pdfPath);
    if (!pdfUrl?.url)
      throw new apiError(500, "Failed to upload PDF to Cloudinary");
    const course = await CourseStructure.create({
      courseId,
      courseName,
      semester,
      url: pdfUrl.url,
      uploadedBy,
    });

    return res
      .status(201)
      .json(new apiResponse(201, course, "Course uploaded !!"));
  } catch (err) {
    throw new apiError(400, err.message || "Course upload failed");
  }
});


const deleteCourseById = asyncHandler(async (req, res) => {
  const courseId = req.params.courseId;
  if (!courseId) throw new apiError(400, "Missing courseId");

  const course = await CourseStructure.findOne({ courseId });
  if (!course) throw new apiError(404, "Invalid courseId");
  //console.log(course);
  await deleteFromCloudinary(course.url);

  await CourseStructure.findOneAndDelete({ courseId });

  return res
    .status(200)
    .json(new apiResponse(200, {}, "Deleted file successfully"));
});

export {
  getAllCourseStructures,
  getCoursesBySemester,
  getCourseById,
  uploadCourseStructure,
  deleteCourseById,
};
