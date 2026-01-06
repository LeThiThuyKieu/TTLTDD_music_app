import { Router } from "express";
import { AlbumController } from "../controllers/albumController";
import { optionalAuth } from "../middleware/auth";

const router = Router();

// Lấy danh sách albums (public)
router.get("/", optionalAuth, AlbumController.getAll);

// Lấy album theo ID
router.get("/:id", optionalAuth, AlbumController.getById);

// Lấy bài hát trong album
router.get("/:id/songs", optionalAuth, AlbumController.getSongs);

export default router;