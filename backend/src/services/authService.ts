import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { UserRepository } from "../repositories/UserRepository";
import { User } from "../models";

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
}
