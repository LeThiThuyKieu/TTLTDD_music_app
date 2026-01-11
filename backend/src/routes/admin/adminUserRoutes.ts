import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { AdminUserController } from '../../controllers/admin/adminUserController';

const router = Router();
// Lấy danh sách người dùng ( GET /api/admin/users )
router.get('/', authenticate, AdminUserController.getAllUsers);

// Khoá người dùng theo ID ( DELETE /api/admin/users/:id/status )
router.patch('/:id/status', authenticate, AdminUserController.toggleUserStatusById);
export default router;