import nodemailer from "nodemailer";

export const sendEmail = async ({ to, subject, text }) => {
  if (!to || !subject || !text) throw new Error("Missing email fields");

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.SMTP_USER, 
      pass: process.env.SMTP_PASS,
    },
  });

  const mailOptions = {
    from: `"MyCollegeApp" <${process.env.SMTP_USER}>`,
    to,
    subject,
    text,
  };

  await transporter.sendMail(mailOptions);
};
