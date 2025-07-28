import mongoose from "mongoose";
import mongooseAggregatePaginate from "mongoose-aggregate-paginate-v2";
import { deleteFromCloudinary } from "../utils/cloudinary.js";
import { Note } from "../models/notes_model.js";

const courseStructureSchema = new mongoose.Schema(
  {
    courseId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    courseName: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    semester: {
      type: Number,
      required: true,
    },
    url: {
      type: String,
      required: true,
    },
    uploadedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true }
);
courseStructureSchema.post("findOneAndDelete", async function (doc) {
  if (doc) {
    const relatedNotes = await Note.find({ course: doc._id });
    for (const note of relatedNotes) {
      await deleteFromCloudinary(note.url);
      await note.deleteOne();
    }
  }
});

courseStructureSchema.plugin(mongooseAggregatePaginate);
export const CourseStructure = mongoose.model(
  "CourseStructure",
  courseStructureSchema
);
