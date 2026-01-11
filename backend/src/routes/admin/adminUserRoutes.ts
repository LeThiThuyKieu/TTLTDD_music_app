import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { AdminUserController } from '../../controllers/admin/adminUserController';

const router = Router();
// Lấy danh sách người dùng ( GET /api/admin/users )
router.get('/', authenticate, AdminUserController.getAllUsers);

export default router;