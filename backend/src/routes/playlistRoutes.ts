import { Router, Request, Response, NextFunction } from "express";
import { PlaylistController } from "../controllers/playlistController";
import { authenticate } from "../middleware/auth";

const router = Router();

/**
 * 🔐 TẤT CẢ ROUTE DÙNG TOKEN
 * FE phải gửi: Authorization: Bearer <token>
 */
router.use(authenticate);

const parseIdParam = (value: string) => {
  const n = Number(value);
  return Number.isFinite(n) && n > 0 ? Math.floor(n) : null;
};

const validatePlaylistId = (req: Request, res: Response, next: NextFunction): void => {
  const id = parseIdParam(req.params.id);
  if (!id) {
    res.status(400).json({ success: false, error: "Invalid playlist id" });
    return;
  }
  req.params.id = String(id);
  return next();
};

const validatePlaylistIdAndSongId = (req: Request, res: Response, next: NextFunction): void => {
  const id = parseIdParam(req.params.id);
  const songId = parseIdParam(req.params.songId);

  if (!id) {
    res.status(400).json({ success: false, error: "Invalid playlist id" });
    return;
  }
  if (!songId) {
    res.status(400).json({ success: false, error: "Invalid songId" });
    return;
  }

  req.params.id = String(id);
  req.params.songId = String(songId);
  return next();
};

// Lấy playlist của user hiện tại (từ token)
router.get("/my", PlaylistController.getMyPlaylists);

// Tạo playlist cho user hiện tại
router.post("/", PlaylistController.create);

// Chi tiết playlist (check quyền bằng token)
router.get("/:id", validatePlaylistId, PlaylistController.getById);

// Thêm / xoá bài hát (chủ playlist)
router.post("/:id/songs", validatePlaylistId, PlaylistController.addSong);
router.delete("/:id/songs/:songId", validatePlaylistIdAndSongId, PlaylistController.removeSong);

// Xoá playlist
router.delete("/:id", validatePlaylistId, PlaylistController.delete);

router.get(
  "/songs/:songId/playlists",
  authenticate,
  PlaylistController.getBySong
);

export default router;
