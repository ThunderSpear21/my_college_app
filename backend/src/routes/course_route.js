import { Router } from "express";
import {
  getAllCourseStructures,
  getCoursesBySemester,
  getCourseById,
  uploadCourseStructure,
  deleteCourseById,
} from "../controllers/course_controller.js";
import { verifyJWT } from "../middlewares/auth_middleware.js";
import { checkIsAdmin } from "../middlewares/isAdmin_middleware.js";
import { upload } from "../middlewares/multer_middleware.js";

const router = Router();
router.use(verifyJWT);

router.route("/all").get(getAllCourseStructures);
router.route("/semester/:semester").get(getCoursesBySemester);
router.route("/id/:courseId").get(getCourseById);
router
  .route("/upload")
  .post(
    checkIsAdmin,
    upload.fields([{ name: "coursePdf", maxCount: 1 }]),
    uploadCourseStructure
  );
router.route("/id/:courseId").delete(checkIsAdmin, deleteCourseById);

export default router;
