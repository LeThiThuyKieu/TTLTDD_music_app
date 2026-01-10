// In-memory storage for OTP
interface OTPData {
  otp: string;
  email: string;
  expiresAt: Date;
}

const otpStorage = new Map<string, OTPData>();

// Xóa OTP cũ mỗi 5 phút
setInterval(() => {
  const now = new Date();
  for (const [key, data] of otpStorage.entries()) {
    if (data.expiresAt < now) {
      otpStorage.delete(key);
    }
  }
}, 5 * 60 * 1000); // 5 phút

export class OTPService {
  // Tạo OTP 4 số
  static generateOTP(): string {
    return Math.floor(1000 + Math.random() * 9000).toString();
  }

  // Lưu OTP
  static saveOTP(
    email: string,
    otp: string,
    expiresInMinutes: number = 10
  ): void {
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + expiresInMinutes);

    otpStorage.set(email, {
      otp,
      email,
      expiresAt,
    });
  }

  // Verify OTP
  static verifyOTP(email: string, otp: string): boolean {
    const data = otpStorage.get(email);
    if (!data) {
      return false;
    }

    // Kiểm tra hết hạn
    if (data.expiresAt < new Date()) {
      otpStorage.delete(email);
      return false;
    }

    // Kiểm tra OTP
    if (data.otp !== otp) {
      return false;
    }

    // OTP sẽ được xóa sau khi reset password thành công
    return true;
  }

  // Xóa OTP
  static deleteOTP(email: string): void {
    otpStorage.delete(email);
  }

  // Kiểm tra OTP còn tồn tại không
  static hasOTP(email: string): boolean {
    const data = otpStorage.get(email);
    if (!data) {
      return false;
    }

    if (data.expiresAt < new Date()) {
      otpStorage.delete(email);
      return false;
    }

    return true;
  }
}
