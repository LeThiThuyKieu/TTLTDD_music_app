import { Router } from "express";
import { HistoryController } from "../controllers/historyController";
import { authenticateFirebase } from "../middleware/auth";

const router = Router();

// Tất cả routes đều cần authentication
router.use(authenticateFirebase);

// Lấy lịch sử nghe
router.get("/", HistoryController.getAll);

// Thêm vào history
router.post("/", HistoryController.add);

// Xóa lịch sử
router.delete("/", HistoryController.clear);

export default router;




