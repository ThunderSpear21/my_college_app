import { Router } from "express";
import {
  getAvailableMentors,
  sendMenteeRequest,
  getMyMentor,
  getMyMentees,
} from "../controllers/connect_controller.js";
import { verifyJWT } from "../middlewares/auth_middleware.js";

const router = Router();
router.use(verifyJWT);

router.route("/available-mentors").get(getAvailableMentors);
router.route("/connect-mentor/:mentorId").post(sendMenteeRequest);
router.route("/my-mentor").get(getMyMentor);
router.route("/my-mentees").get(getMyMentees);

export default router;
