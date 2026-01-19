import multer from "multer";

// Chỉ parse multipart/form-data, không lưu cục bộ
export const uploadFiles = multer().fields([
  { name: "music", maxCount: 1 },
  { name: "cover", maxCount: 1 },
  { name: "avatar", maxCount: 1 },
  { name: "album_cover", maxCount: 1 },
]);
