import { Router } from "express";
import {
  getStudentsByYear,
  toggleAdminStatus,
  toggleMentorEligibility,
} from "../controllers/user_controller.js";
import { verifyJWT } from "../middlewares/auth_middleware.js";
import { checkIsAdmin } from "../middlewares/isAdmin_middleware.js";

const router = Router();
router.use(verifyJWT);
router.use(checkIsAdmin);

router.get("/students/year/:yearOfAdmission", getStudentsByYear);
router.put("/promote-admin", toggleAdminStatus);
router.put("/mark-mentor-eligible", toggleMentorEligibility);

export default router;
