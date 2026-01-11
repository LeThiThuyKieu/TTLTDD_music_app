import { UserSummary } from "../../models";
import { AdminUserRepository } from "../../repositories/admin/adminUserRepository";

export class AdminUserService {
static async getAllUsers(limit: number, offset: number)
: Promise<UserSummary[]> {
    const users = await AdminUserRepository.findAllUsers(limit, offset);
    return users;
  }
}