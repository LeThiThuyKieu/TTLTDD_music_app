import { v2 as cloudinary } from "cloudinary";
import dotenv from "dotenv";

dotenv.config(); //Nạp các biến trong file .env vào process.env.

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true, //trả về URL https thay vì http.
});

cloudinary.api.ping()
  .then(() => console.log("Cloudinary kết nối thành công!"))
  .catch((err) => console.error("Cloudinary kết nối thất bại:", err));

  export interface CloudinaryUploadResult {
  url: string;
  public_id: string;
}

  //upload file lên Cloudinary.
export const uploadToCloudinary = async (
  file: Express.Multer.File, //file được Multer parse từ form-data.
  folder: string, //tên folder trên Cloudinary để lưu file
  publicId: string
): Promise<CloudinaryUploadResult> => {
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload_stream(
      {
        resource_type: "auto",
        folder,
        public_id: publicId,
        overwrite: true,
      },
      (error, result) => {
        if (error || !result) {
          return reject(error || new Error("Upload failed"));
        }

        resolve({
          url: result.secure_url,
          public_id: result.public_id,
        });
      }
    ).end(file.buffer);
  });
};

// helper xoá file Cloudinary
export const deleteFromCloudinary = async (
  publicId: string,
  resourceType: "image" | "video" = "video"
) => {
  await cloudinary.uploader.destroy(publicId, {
    resource_type: resourceType,
  });
};