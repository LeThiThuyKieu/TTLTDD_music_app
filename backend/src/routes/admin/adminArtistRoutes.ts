import { Router } from "express";
import { AdminArtistController } from "../../controllers/admin/adminArtistController";
import { authenticate } from "../../middleware/auth";
import { uploadFiles } from "../../middleware/uploadCloud";

const router = Router();

// Lấy danh sách nghệ sĩ ( GET /api/admin/artists )
router.get("/", authenticate, AdminArtistController.getAllArtists);

// Xoá nghệ sĩ theo ID ( DELETE /api/admin/artists/:id )
router.delete("/:id", authenticate, AdminArtistController.deleteArtistById);

// Lấy chi tiết nghệ sĩ theo ID ( GET /api/admin/artists/:id )
router.get("/:id", authenticate, AdminArtistController.getArtistById);

// Thêm nghệ sĩ ( POST /api/admin/artists )
router.post("/", authenticate, uploadFiles, AdminArtistController.createArtist);

// Cập nhập nghệ sĩ ( PUT /api/admin/artists/:id )
router.put("/:id", authenticate, uploadFiles, AdminArtistController.updateArtist);
export default router;