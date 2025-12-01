import { Router } from "express";
import { PlaylistController } from "../controllers/playlistController";
import { authenticateFirebase, optionalAuth } from "../middleware/auth";
import { validate, validatePlaylist } from "../utils/validation";

const router = Router();

// Tạo playlist mới (cần authentication)
router.post(
  "/",
  authenticateFirebase,
  validate(validatePlaylist),
  PlaylistController.create
);

// Lấy playlists của user (cần authentication)
router.get("/my", authenticateFirebase, PlaylistController.getMyPlaylists);

// Lấy playlist theo ID (public nếu is_public = 1)
router.get("/:id", optionalAuth, PlaylistController.getById);

// Thêm bài hát vào playlist (cần authentication)
router.post("/:id/songs", authenticateFirebase, PlaylistController.addSong);

// Xóa bài hát khỏi playlist (cần authentication)
router.delete(
  "/:id/songs/:songId",
  authenticateFirebase,
  PlaylistController.removeSong
);

// Xóa playlist (cần authentication)
router.delete("/:id", authenticateFirebase, PlaylistController.delete);

export default router;




