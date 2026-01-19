import { deleteFromCloudinary } from "../../config/cloudinary";
import pool from "../../config/database";
import { AlbumWithArtist, SongWithArtists } from "../../models";

export class AdminAlbumRepository {

  // LẤY DANH SÁCH ALBUM
static async findAllAlbums( limit: number, offset: number): Promise<AlbumWithArtist[]> {
const sql = `
    SELECT al.album_id, al.title, al.cover_url, al.album_public_id, al.is_active, ar.artist_id, ar.name AS artist_name, ar.is_active as artist_is_active 
    FROM albums al LEFT JOIN artists ar ON al.artist_id = ar.artist_id
    ORDER BY al.album_id DESC
    LIMIT ? OFFSET ?;
`;
// thực hiện sql
    const [rows] = await pool.query<any[]>(sql, [limit, offset]);
    //Map để gom album thành danh sách kèm tên artist
    const map = new Map<number, AlbumWithArtist>();
    for (const row of rows) {
    // Mếu album chưa có trong map, tạo mới
      if (!map.has(row.album_id)) {
        map.set(row.album_id, {
          album_id: row.album_id,
          title: row.title,
          cover_url: row.cover_url,
          album_public_id: row.album_public_id,
          is_active: row.is_active,
          artist: row.artist_id 
          ?{
            artist_id: row.artist_id,
            name: row.artist_name,
            is_active: row.artist_is_active
          }
          : undefined,
        });
    }
}
    return Array.from(map.values());
}
// XOÁ ALBUM THEO ID
   static async deleteAlbumById(album_id: number) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();
      // Lấy thông tin album để xoá ảnh trên Cloudinary
    const [rows]: any = await connection.query(
      `SELECT album_public_id FROM albums WHERE album_id = ?`,
      [album_id]
    );
    if (!rows.length) {
      await connection.rollback();
      return false;
    }

    const { album_public_id } = rows[0];

      // Gỡ album khỏi bài hát
      await connection.query(`UPDATE songs SET album_id = NULL WHERE album_id = ?`, [album_id]);
      // Xoá album
      const [result]: any = await connection.query(`DELETE FROM albums WHERE album_id = ?`, [album_id]);

      await connection.commit();

      // Xóa cover trên Cloudinary
    if (album_public_id) {
      await deleteFromCloudinary(album_public_id, "image");
    }
    
      return result.affectedRows > 0;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  // LÂY CHI TIẾT ALBUM THEO ID
   static async findAlbumById(album_id: number): Promise<AlbumWithArtist & { songs: SongWithArtists[] } | null> {
    const connection = await pool.getConnection();
    try {
      // Lấy album + artist
      const [rows] = await connection.query<any[]>(
        `SELECT al.album_id, al.title, al.cover_url, al.album_public_id, al.is_active,
                ar.artist_id, ar.name AS artist_name
         FROM albums al
         LEFT JOIN artists ar ON al.artist_id = ar.artist_id
         WHERE al.album_id = ?`,
        [album_id]
      );
      if (!rows.length) return null;

      const album: AlbumWithArtist & { songs: SongWithArtists[] } = {
        album_id: rows[0].album_id,
        title: rows[0].title,
        cover_url: rows[0].cover_url,
        album_public_id: rows[0].album_public_id,
        is_active: rows[0].is_active,
        artist: rows[0].artist_id ? {
          artist_id: rows[0].artist_id,
          name: rows[0].artist_name
        } : undefined,
        songs: []
      };

      // Lấy danh sách bài hát 
      const [songRows] = await connection.query<any[]>(
        `SELECT song_id, title, file_url, cover_url, is_active
         FROM songs
         WHERE album_id = ?
         ORDER BY song_id DESC`,
        [album_id]
      );

      album.songs = songRows.map(row => ({
        song_id: row.song_id,
        title: row.title,
        file_url: row.file_url,
        cover_url: row.cover_url,
        is_active: row.is_active
      }));

      return album;
    } finally {
      connection.release();
    }
  }

  // THÊM ALBUM MỚI
  static async createAlbum(data: {
    title: string;
    artist_id?: number;
    cover_url?: string;
    album_public_id?: string;
    is_active?: number;
    song_ids?: number[];
  }) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();

      const [result]: any = await connection.query(
        `INSERT INTO albums (title, artist_id, cover_url, album_public_id, release_date, is_active)
         VALUES (?, ?, ?, ?, NOW(), ?)`,
        [
          data.title, 
          data.artist_id ?? null, 
          data.cover_url ?? null, 
          data.album_public_id ?? null, 
          data.is_active ?? 1]
      );

      const albumId = result.insertId;

      // Gán album_id cho các bài hát nếu có
      if (data.song_ids?.length) {
        await connection.query(
          `UPDATE songs SET album_id = ? WHERE song_id IN (?)`,
          [albumId, data.song_ids]
        );
      }

      await connection.commit();
      return this.findAlbumById(albumId);
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }


  // CẬP NHẬT THÔNG TIN ALBUM
   static async updateAlbum(album_id: number, data: {
    title?: string;
    artist_id?: number;
    cover_url?: string;
    album_public_id?: string;
    is_active?: number;
    song_ids?: number[];
  }) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();

      // Update thông tin album
      await connection.query(
        `UPDATE albums
         SET title = COALESCE(?, title),
             artist_id = COALESCE(?, artist_id),
             cover_url = COALESCE(?, cover_url),
             album_public_id = COALESCE(?, album_public_id),
             is_active = COALESCE(?, is_active)
         WHERE album_id = ?`,
        [
          data.title ?? null, 
          data.artist_id ?? null, 
          data.cover_url ?? null, 
          data.album_public_id ?? null, 
          data.is_active ?? null, 
          album_id
        ]
      );

      // Cập nhật bài hát nếu có
      if (data.song_ids) {
        // Gỡ các bài hát cũ
        await connection.query(`UPDATE songs SET album_id = NULL WHERE album_id = ?`, [album_id]);
        // Gán album mới
        if (data.song_ids.length > 0) {
          await connection.query(`UPDATE songs SET album_id = ? WHERE song_id IN (?)`, [album_id, data.song_ids]);
        }
      }

      await connection.commit();
      
      return this.findAlbumById(album_id);
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }
}