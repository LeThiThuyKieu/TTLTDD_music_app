import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { UserRepository } from "../repositories/UserRepository";
import { User } from "../models";
import { OTPService } from "./otpService";

const JWT_SECRET =
  process.env.JWT_SECRET || "your-secret-key-change-in-production";
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "7d";

export class AuthService {
  // Đăng ký user mới
  static async register(
    name: string,
    email: string,
    password: string,
    avatar_url?: string
  ): Promise<{ user: User; token: string }> {
    // Kiểm tra email đã tồn tại chưa
    const existingUser = await UserRepository.findByEmail(email);
    if (existingUser) {
      throw new Error("Email already exists");
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Tạo user mới
    const user = await UserRepository.create({
      name,
      email,
      password_hash,
      avatar_url,
      role: "user",
    });

    if (!user || !user.user_id) {
      throw new Error("Failed to create user");
    }

    // Tạo JWT token
    const token = jwt.sign(
      { user_id: user.user_id, email: user.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN } as jwt.SignOptions
    );

    // Không trả về password_hash
    const { password_hash: _, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword as User,
      token,
    };
  }

  // Đăng nhập
  static async login(
    email: string,
    password: string
  ): Promise<{ user: User; token: string }> {
    // Tìm user theo email
    const user = await UserRepository.findByEmail(email);
    if (!user) {
      throw new Error("Invalid email or password");
    }

    // Kiểm tra password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      throw new Error("Invalid email or password");
    }

    // Kiểm tra user có active không
    if (user.is_active === 0) {
      throw new Error("User account is inactive");
    }

    // Tạo JWT token
    const token = jwt.sign(
      { user_id: user.user_id!, email: user.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN } as jwt.SignOptions
    );

    // Không trả về password_hash
    const { password_hash: _, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword as User,
      token,
    };
  }

  // Lấy thông tin user hiện tại
  static async getCurrentUser(userId: number): Promise<User | null> {
    const user = await UserRepository.findById(userId);
    if (!user) return null;

    // Không trả về password_hash
    const { password_hash: _, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }

  // Gửi OTP cho forgot password
  static async sendForgotPasswordOTP(email: string): Promise<string> {
    // Kiểm tra user có tồn tại không
    const user = await UserRepository.findByEmail(email);
    if (!user) {
      // Không báo lỗi để tránh email enumeration attack
      // Vẫn trả về success nhưng không gửi OTP
      return "";
    }

    // Tạo OTP
    const otp = OTPService.generateOTP();

    // Lưu OTP (10 phút)
    OTPService.saveOTP(email, otp, 10);

    // TODO: Gửi email với OTP
    // Ở đây chỉ log ra console, trong production cần tích hợp email service
    console.log(`OTP for ${email}: ${otp}`);

    return otp;
  }

  // Verify OTP
  static async verifyForgotPasswordOTP(
    email: string,
    otp: string
  ): Promise<boolean> {
    return OTPService.verifyOTP(email, otp);
  }

  // Reset password
  static async resetPassword(
    email: string,
    otp: string,
    newPassword: string
  ): Promise<void> {
    // Verify OTP trước
    const isValidOTP = await this.verifyForgotPasswordOTP(email, otp);
    if (!isValidOTP) {
      throw new Error("Invalid or expired OTP");
    }

    // Tìm user
    const user = await UserRepository.findByEmail(email);
    if (!user || !user.user_id) {
      throw new Error("User not found");
    }

    // Hash password mới
    const password_hash = await bcrypt.hash(newPassword, 10);

    // Cập nhật password
    await UserRepository.update(user.user_id, { password_hash });

    // Xóa OTP sau khi reset password thành công
    OTPService.deleteOTP(email);
  }
}
