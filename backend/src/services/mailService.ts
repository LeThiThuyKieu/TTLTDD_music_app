import nodemailer from "nodemailer";

export class EmailService {
  private static transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 587,
    secure: false, // TLS
    auth: {
      user: process.env.MAIL_USER,
      pass: process.env.MAIL_PASS,
    },
  });

  static async sendForgotPasswordOTP(to: string, otp: string): Promise<void> {
    try {
      await this.transporter.sendMail({
        from: `"Music App" <${process.env.MAIL_USER}>`,
        to,
        subject: "Mã xác minh đặt lại mật khẩu",
        text: `Xin chào,
        
Mã xác minh của bạn là: ${otp}

Mã có hiệu lực trong 10 phút.
Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.

Music App Team`,
        html: `
          <h2>Quên mật khẩu</h2>
          <p>Mã xác minh của bạn là:</p>
          <h1 style="letter-spacing:4px">${otp}</h1>
          <p>Mã có hiệu lực trong <b>10 phút</b>.</p>
        `,
      });
    } catch (error) {
      console.error("Send mail error:", error);
      throw new Error("Không thể gửi email xác minh");
    }
  }
}
