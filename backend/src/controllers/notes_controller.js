import { asyncHandler } from "../utils/asyncHandler.js";
import { apiError } from "../utils/apiError.js";
import { apiResponse } from "../utils/apiResponse.js";
import { Note } from "../models/notes_model.js";
import { CourseStructure } from "../models/course_model.js";
import {
  uploadOnCloudinary,
  deleteFromCloudinary,
} from "../utils/cloudinary.js";

const getAllNotes = asyncHandler(async (req, res) => {
  const allNotes = await Note.aggregate([
    {
      $lookup: {
        from: "coursestructures",
        localField: "course",
        foreignField: "_id",
        as: "course",
      },
    },
    { $unwind: "$course" },
    {
      $lookup: {
        from: "users",
        localField: "uploadedBy",
        foreignField: "_id",
        as: "uploadedBy",
      },
    },
    { $unwind: "$uploadedBy" },
    {
      $sort: {
        "course.semester": 1,
      },
    },
    {
      $project: {
        title: 1,
        url: 1,
        "course.courseId": 1,
        "course.courseName": 1,
        "course.semester": 1,
        "uploadedBy.name": 1,
        "uploadedBy.email": 1,
      },
    },
  ]);

  return res
    .status(200)
    .json(new apiResponse(200, allNotes, "All notes fetched"));
});

const getNotesBySemester = asyncHandler(async (req, res) => {
  const semester = parseInt(req.params.semester);

  if (isNaN(semester) || semester <= 0 || semester >= 11)
    throw new apiError(400, "Semester does not exist");

  const allNotes = await Note.aggregate([
    {
      $lookup: {
        from: "coursestructures",
        localField: "course",
        foreignField: "_id",
        as: "course",
      },
    },
    { $unwind: "$course" },
    {
      $lookup: {
        from: "users",
        localField: "uploadedBy",
        foreignField: "_id",
        as: "uploadedBy",
      },
    },
    { $unwind: "$uploadedBy" },
    {
      $match: {
        "course.semester": semester,
      },
    },
    {
      $sort: {
        "course.semester": 1,
      },
    },
    {
      $project: {
        title: 1,
        url: 1,
        "course.courseId": 1,
        "course.courseName": 1,
        "course.semester": 1,
        "uploadedBy.name": 1,
        "uploadedBy.email": 1,
      },
    },
  ]);

  return res
    .status(200)
    .json(new apiResponse(200, allNotes, "Notes for the semster fetched"));
});

const getNotesByCourseId = asyncHandler(async (req, res) => {
  const courseId = req.params.courseId;
  if (!courseId) throw new apiError(404, "Missing courseId");

  const allNotes = await Note.aggregate([
    {
      $lookup: {
        from: "coursestructures",
        localField: "course",
        foreignField: "_id",
        as: "course",
      },
    },
    { $unwind: "$course" },
    {
      $lookup: {
        from: "users",
        localField: "uploadedBy",
        foreignField: "_id",
        as: "uploadedBy",
      },
    },
    { $unwind: "$uploadedBy" },
    {
      $match: {
        "course.courseId": courseId,
      },
    },
    {
      $sort: {
        "course.semester": 1,
      },
    },
    {
      $project: {
        title: 1,
        url: 1,
        "course.courseId": 1,
        "course.courseName": 1,
        "course.semester": 1,
        "uploadedBy.name": 1,
        "uploadedBy.email": 1,
      },
    },
  ]);
  if (allNotes.length === 0)
    throw new apiError(404, "No Notes found for the courseId");

  return res
    .status(200)
    .json(new apiResponse(200, allNotes, "Notes fetched !!"));
});

const uploadNotes = asyncHandler(async (req, res) => {
  const notesPath = req?.files?.notesPdf?.[0]?.path;
  if (!notesPath) throw new apiError(404, "File not found");

  const { title, courseId } = req.body;
  const uploadedBy = req?.user?._id;

  if (!uploadedBy) throw new apiError(401, "Not logged in");
  if (!title || !courseId)
    throw new apiError(400, "title and courseId are required");

  const course = await CourseStructure.findOne({ courseId });
  if (!course) throw new apiError(404, "Invalid courseId");

  try {
    const pdfUrl = await uploadOnCloudinary(notesPath);
    if (!pdfUrl?.url)
      throw new apiError(500, "Failed to upload PDF to Cloudinary");

    const note = await Note.create({
      title,
      url: pdfUrl.url,
      course: course._id,
      uploadedBy,
    });

    return res
      .status(201)
      .json(new apiResponse(201, note, "Note uploaded successfully"));
  } catch (err) {
    throw new apiError(400, err.message || "Note upload failed");
  }
});

const deleteNotes = asyncHandler(async (req, res) => {
  const notesId = req.params.notesId;
  if (!notesId) throw new apiError(400, "Missing notesId");

  const notes = await Note.findOne({ _id: notesId });
  if (!notes) throw new apiError(404, "Invalid notesId");
  //console.log(course);
  await deleteFromCloudinary(notes.url);

  await Note.findOneAndDelete({ _id: notesId });

  return res
    .status(200)
    .json(new apiResponse(200, {}, "Deleted file successfully"));
});

const searchNotes = asyncHandler(async (req, res) => {
  const { semester, courseId } = req.query;

  const matchStage = {};

  if (semester) {
    const parsedSemester = parseInt(semester);
    if (isNaN(parsedSemester) || parsedSemester < 1 || parsedSemester > 10) {
      throw new apiError(400, "Invalid semester value");
    }
    matchStage["course.semester"] = parsedSemester;
  }

  if (courseId) {
    matchStage["course.courseId"] = courseId;
  }

  const filteredNotes = await Note.aggregate([
    {
      $lookup: {
        from: "coursestructures",
        localField: "course",
        foreignField: "_id",
        as: "course",
      },
    },
    { $unwind: "$course" },
    {
      $lookup: {
        from: "users",
        localField: "uploadedBy",
        foreignField: "_id",
        as: "uploadedBy",
      },
    },
    { $unwind: "$uploadedBy" },
    { $match: matchStage },
    {
      $sort: { "course.semester": 1 },
    },
    {
      $project: {
        title: 1,
        url: 1,
        "course.courseId": 1,
        "course.courseName": 1,
        "course.semester": 1,
        "uploadedBy.name": 1,
        "uploadedBy.email": 1,
      },
    },
  ]);

  return res
    .status(200)
    .json(new apiResponse(200, filteredNotes, "Filtered notes fetched"));
});

export {
  getAllNotes,
  getNotesBySemester,
  getNotesByCourseId,
  uploadNotes,
  deleteNotes,
  searchNotes,
};
