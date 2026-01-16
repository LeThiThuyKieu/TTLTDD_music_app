import { Router } from "express";
import { ArtistController } from "../controllers/artistController";
import { SongController } from "../controllers/songController";
import { optionalAuth } from "../middleware/auth";

const router = Router();

// Lấy danh sách nghệ sĩ (public)
router.get("/", optionalAuth, ArtistController.getAll);

// Lấy nghệ sĩ theo ID
router.get("/:id", optionalAuth, ArtistController.getById);

// Lấy danh sách bài hát theo artist
router.get("/:artistId/songs", optionalAuth, SongController.getByArtist);

export default router;
