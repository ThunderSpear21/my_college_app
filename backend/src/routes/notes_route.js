import { Router } from "express";
import {
  getAllNotes,
  getNotesBySemester,
  getNotesByCourseId,
  uploadNotes,
  deleteNotes,
  searchNotes,
} from "../controllers/notes_controller.js";
import { verifyJWT } from "../middlewares/auth_middleware.js";
import { checkIsAdmin } from "../middlewares/isAdmin_middleware.js";
import { upload } from "../middlewares/multer_middleware.js";

const router = Router();
router.use(verifyJWT);

router.route("/all").get(getAllNotes);
router.route("/semester/:semester").get(getNotesBySemester);
router.route("/id/:courseId").get(getNotesByCourseId);
router
  .route("/upload")
  .post(
    checkIsAdmin,
    upload.fields([{ name: "notesPdf", maxCount: 1 }]),
    uploadNotes
  );
router.route("/id/:notesId").delete(checkIsAdmin, deleteNotes);
router.route("/search").get(checkIsAdmin, searchNotes);

export default router;
