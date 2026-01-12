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

  //upload file lên Cloudinary.
export const uploadToCloudinary = async (
  file: Express.Multer.File, //file được Multer parse từ form-data.
  folder: string //tên folder trên Cloudinary để lưu file
): Promise<string> => { //trả về URL của file đã upload
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload_stream( //phương thức upload file từ buffer (không cần lưu tạm vào ổ cứng).
        {
          resource_type: "auto", //tự động nhận diện loại file (image, video, raw...)
          folder,
        },
        (error, result) => {
          if (error || !result) reject(error || "Upload failed");
          else resolve(result.secure_url); //secure_url là URL https của file đã upload.
        }
      )
      .end(file.buffer);
  });
};


