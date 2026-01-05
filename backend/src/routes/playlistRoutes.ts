// import { Router } from "express";
// import { PlaylistController } from "../controllers/playlistController";
// import { authenticate, optionalAuth } from "../middleware/auth";
// import { validate, validatePlaylist } from "../utils/validation";

// const router = Router();

// // Tạo playlist mới (cần authentication)
// router.post(
//   "/",
//   authenticate,
//   validate(validatePlaylist),
//   PlaylistController.create
// );

// // Lấy playlists của user (cần authentication)
// router.get("/my", authenticate, PlaylistController.getMyPlaylists);

// // Lấy playlist theo ID (public nếu is_public = 1)
// router.get("/:id", optionalAuth, PlaylistController.getById);

// // Thêm bài hát vào playlist (cần authentication)
// router.post("/:id/songs", authenticate, PlaylistController.addSong);

// // Xóa bài hát khỏi playlist (cần authentication)
// router.delete(
//   "/:id/songs/:songId",
//   authenticate,
//   PlaylistController.removeSong
// );

// // Xóa playlist (cần authentication)
// router.delete("/:id", authenticate, PlaylistController.delete);

// export default router;
import { Router } from "express";
import { PlaylistController } from "../controllers/playlistController";
import { authenticate } from "../middleware/auth";

const router = Router();

router.use(authenticate);

router.get("/my", PlaylistController.getMyPlaylists);
router.post("/", PlaylistController.create);

// QUAN TRỌNG: dùng :id (đúng với controller đang parse req.params.id)
router.get("/:id", PlaylistController.getById);
router.post("/:id/songs", PlaylistController.addSong);
router.delete("/:id/songs/:songId", PlaylistController.removeSong);
router.delete("/:id", PlaylistController.delete);

export default router;
