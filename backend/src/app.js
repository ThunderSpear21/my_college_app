import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";

const app = express();

app.use(
  cors({
    origin: process.env.CORS_ORIGIN,
    credentials: true,
  })
);

app.use(express.json({ limit: "32kb" })); // limit the amount of server requests

app.use(express.urlencoded({ extended: true, limit: "32kb" })); // blankspace <=> %20, extended allows nested object, etc

app.use(express.static("public")); // store on server in a folder named "public"

app.use(cookieParser());

import authRouter from "./routes/auth_route.js";
import connectRoutes from "./routes/connect_route.js";
import courseRoutes from "./routes/course_route.js";
app.use("/api/auth", authRouter);
app.use("/api/connect", connectRoutes);
app.use("/api/course", courseRoutes);

export { app };
