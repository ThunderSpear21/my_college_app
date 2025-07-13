import mongoose from "mongoose";
import mongooseAggregatePaginate from "mongoose-aggregate-paginate-v2";

const courseStructureSchema = new mongoose.Schema(
  {
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

courseStructureSchema.plugin(mongooseAggregatePaginate);
export const CourseStructure = mongoose.model(
  "CourseStructure",
  courseStructureSchema
);
