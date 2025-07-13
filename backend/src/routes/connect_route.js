import { Router } from "express";
import { getAvailableMentors } from "../controllers/connect_controller.js";
import { verifyJWT } from "../middlewares/auth_middleware.js";

const router = Router();
router.use(verifyJWT);

router.route("/available-mentors").get(getAvailableMentors);

export default router;
