import multer from "multer";
import path from "path";
import fs from "fs";

// ====== ROOT UPLOAD DIR ======
const uploadRoot = path.join(__dirname, "../../uploads");

const ensureDir = (dir: string) => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
};

ensureDir(uploadRoot);
ensureDir(path.join(uploadRoot, "avatar"));
ensureDir(path.join(uploadRoot, "cover"));
ensureDir(path.join(uploadRoot, "audio"));

// ====== STORAGE ======
const storage = multer.diskStorage({
  destination: (_req, file, cb) => {
    if (file.fieldname === "avatar") {
      cb(null, path.join(uploadRoot, "avatar"));
    } else if (file.fieldname === "cover") {
      cb(null, path.join(uploadRoot, "cover"));
    } else if (file.fieldname === "music") {
      cb(null, path.join(uploadRoot, "audio"));
    } else {
      cb(new Error("Invalid upload field"), "");
    }
  },

  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname);
    const prefix =
      file.fieldname === "music"
        ? "audio"
        : file.fieldname === "cover"
        ? "cover"
        : "avatar";

    cb(null, `${prefix}-${Date.now()}${ext}`);
  },
});

// ====== FILE FILTER ======
const fileFilter: multer.Options["fileFilter"] = (_req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();
  console.log("UPLOAD FILE:", {
    field: file.fieldname,
    mimetype: file.mimetype,
    originalname: file.originalname,
  });
  // MP3
 if (file.fieldname === "music") {
  const ext = path.extname(file.originalname).toLowerCase();
  const mime = file.mimetype;

  if (
    ext === ".mp3" &&
    (mime === "audio/mpeg" ||
     mime === "audio/mp3" ||
     mime === "application/octet-stream")
  ) {
    return cb(null, true);
  }

  return cb(new Error("Only MP3 files are allowed"));
}

  // IMAGE
 if (file.fieldname === "cover" || file.fieldname === "avatar") {
    if ([".jpg", ".jpeg", ".png", ".webp"].includes(ext)) {
      return cb(null, true);
    }
    return cb(new Error("Only image files are allowed"));
  }

  return cb(new Error("Invalid file field"));
};

// ====== EXPORTS ======
export const uploadAvatar = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
}).single("avatar");

export const uploadSongFiles = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 20 * 1024 * 1024, // 20MB mp3
  },
}).fields([
  { name: "music", maxCount: 1 },
  { name: "cover", maxCount: 1 },
]);
