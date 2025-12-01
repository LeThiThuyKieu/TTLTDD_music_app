import { Router } from "express";
import { SongController } from "../controllers/songController";
import { optionalAuth } from "../middleware/auth";
import { validate, validateSong } from "../utils/validation";

const router = Router();

// Lấy danh sách bài hát (public)
router.get("/", optionalAuth, SongController.getAll);

// Tìm kiếm bài hát
router.get("/search", optionalAuth, SongController.search);

// Lấy bài hát theo genre
router.get("/genre/:genreId", optionalAuth, SongController.getByGenre);

// Lấy bài hát theo ID
router.get("/:id", optionalAuth, SongController.getById);

// Tạo bài hát mới (cần authentication - có thể thêm admin check sau)
router.post("/", optionalAuth, validate(validateSong), SongController.create);

export default router;



