import { UserSummary } from "../../models";
import { AdminUserRepository } from "../../repositories/admin/adminUserRepository";

export class AdminUserService {
static async getAllUsers(limit: number, offset: number)
: Promise<UserSummary[]> {
    const users = await AdminUserRepository.findAllUsers(limit, offset);
    return users;
  }

  // KHOÁ TÀI KHOẢN THEO ID
  static async toggleUserStatusById(
    userId: number,
    isActive: number
  ): Promise<void> {

    // 1. Validate input
    if (![0, 1].includes(isActive)) {
      throw new Error("Invalid is_active value");
    }

    // 2. Kiểm tra user tồn tại
    const user = await AdminUserRepository.findById(userId);
    if (!user) {
      throw new Error("User not found");
    }

    // 3. Không cho khoá admin (tuỳ rule)
    if (user.role === 'admin') {
      throw new Error("Cannot change status of admin account");
    }

    // 4. Update status
    const updated = await AdminUserRepository.updateStatus(userId, isActive);
    if (!updated) {
      throw new Error("Failed to update user status");
    }
  }
}