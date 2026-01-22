import { AuthenticatedRequest } from "../../models";
import { Response } from "express";
import { AdminSongService } from "../../services/admin/adminSongService";
import { uploadToCloudinary } from "../../config/cloudinary";

export class AdminSongController {
  //ADMIN: Lấy danh sách bài hát (GET /api/admin/songs?limit=10&offset=0)
    static async getAllSongs(req: AuthenticatedRequest, res: Response ){
     try {
       const limit = Number(req.query.limit) || 20;
       const offset = Number(req.query.offset) || 0;

       const [songs, total] = await Promise.all([
      AdminSongService.getAllSongs(limit, offset),
      AdminSongService.countSongs()
    ]);
   res.status(200).json({
        success: true,
        limit,
        offset,
        total,
        data: songs
      });
    } catch (error) {
      console.error("Admin get songs error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to fetch admin songs"
      });
    }
  }

  //ADMIN : Lấy danh sách bài hát cho select
  static async getSongsForSelect(req: AuthenticatedRequest,res: Response) {
  try {
    const songs = await AdminSongService.getSongsForSelect();

    return res.status(200).json({
      success: true,
      data: songs,
    });
  } catch (error) {
    console.error("Admin get songs select error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch songs for select",
    });
  }
}
  //ADMIN: Lấy XOÁ bài hát theo ID (DELETE /api/admin/songs/:id)
  static async deleteSongById(req: AuthenticatedRequest, res: Response) {
    try {
      const song_id = Number(req.params.id);
      if (isNaN(song_id)) { // không f number
        return res.status(400).json({
          success: false,
          message: "Invalid song ID"
        });
      }
      const deleted = await AdminSongService.deleteSongById(song_id);
      if (!deleted) {
        return res.status(404).json({
          success: false,
          message: "Song not found"
        });
      }
      return res.status(200).json({
        success: true,
        message: "Song deleted successfully",
        song_id: song_id
      });
    } catch (error) {
      console.error("Admin delete song error:", error); 
      return res.status(500).json({
        success: false,
        message: "Failed to delete song"
      });
    }
  }
  //ADMIN: Thêm bài hát ( POST /api/admin/songs )
 static async createSong(req: AuthenticatedRequest, res: Response) {
  try {
    const { title, genre_id, duration, lyrics, artist_ids } = req.body;

    if (!title || !genre_id || Number(duration) <= 0 || !artist_ids) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }

    // ÉP KIỂU req.files
    const files = req.files as {
      [fieldname: string]: Express.Multer.File[];
    };

    //lấy file nhạc từ request upload
    const musicFile = files?.music?.[0];
    if (!musicFile) {
      return res.status(400).json({
        success: false,
        message: "Music file is required",
      });
    }

    const coverFile = files?.cover?.[0];
    console.log("Received cover file:", coverFile);
    // Upload lên Cloudinary
    const publicIdBase = `song_${Date.now()}`;
      const musicUrl = await uploadToCloudinary(musicFile, "songs/audio", publicIdBase);
      console.log("Music URL để lưu vào DB:", musicUrl);
      const coverUrl = coverFile ? await uploadToCloudinary(coverFile, "songs/cover", `${publicIdBase}_cover`) : null;
      console.log("Cover URL để lưu vào DB:", coverUrl);
      
    const song = await AdminSongService.createSong({
      title,
      genre_id: Number(genre_id),
      duration: Number(duration),
      lyrics,
      artistIds: artist_ids.split(",").map(Number).filter((id: number) => !isNaN(id)),
      file_url: musicUrl.url,
      file_public_id: musicUrl.public_id,
      cover_url: coverUrl?.url ?? null,
      cover_public_id: coverUrl?.public_id ?? null,
    });

    return res.status(201).json({
      success: true,
      data: song,
    });
  } catch (error) {
    console.error("Create song error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to create song",
    });
  }
}
// ADMIN: Lấy chi tiết bài hát theo ID (GET /api/admin/songs/:id)
static async getSongById(req: AuthenticatedRequest, res: Response) {
  try {
    const song_id = Number(req.params.id);

    if (isNaN(song_id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid song ID",
      });
    }

    const song = await AdminSongService.getSongById(song_id, true);

    if (!song) {
      return res.status(404).json({
        success: false,
        message: "Song not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: song,
    });
  } catch (error) {
    console.error("Admin get song detail error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch song detail",
    });
  }
}
// ADMIN: Cập nhật bài hát (PUT /api/admin/songs/:id)
static async updateSong(req: AuthenticatedRequest, res: Response) {
  try {
    const song_id = Number(req.params.id);
    if (isNaN(song_id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid song ID",
      });
    }

    const {
      title,
      genre_id,
      duration,
      lyrics,
      artist_ids,
      is_active,
    } = req.body;

    if (!title || !genre_id || !duration || !artist_ids) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }

    // Parse artistIds 
    const artistIds = artist_ids
      .split(",")
      .map(Number)
      .filter((id: number) => !isNaN(id));
    if (!artistIds.length) {
      return res.status(400).json({
        success: false,
        message: "Artist list is invalid",
      });
    }

    // files (req.files) ép kiểu
    const files = req.files as {
      [fieldname: string]: Express.Multer.File[];
    };

    const musicFile = files?.music?.[0];
    const coverFile = files?.cover?.[0];

    // upload nếu có file mới
     const publicIdBase = `song_${song_id}`;
   let musicUpload:
      | { url: string; public_id: string }
      | undefined;
    let coverUpload:
      | { url: string; public_id: string }
      | undefined;


    if (musicFile) {
      musicUpload = await uploadToCloudinary(
        musicFile,
        "songs/audio",
        publicIdBase // overwrite file cũ
      );
    }

    if (coverFile) {
      coverUpload = await uploadToCloudinary(
        coverFile,
        "songs/cover",
        `${publicIdBase}_cover` // overwrite cover cũ
      );
    }
    // update db
    const updatedSong = await AdminSongService.updateSong(song_id, {
      title,
      genre_id: Number(genre_id),
      duration: Number(duration),
      lyrics,
      is_active: Number(is_active) === 1,
      artistIds: artistIds,
      
      file_url: musicUpload?.url,
      file_public_id: musicUpload?.public_id,

      cover_url: coverUpload?.url,
      cover_public_id: coverUpload?.public_id,
    });

    return res.status(200).json({
      success: true,
      data: updatedSong,
    });
  } catch (error) {
    console.error("Update song error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to update song",
    });
  }
}


}
