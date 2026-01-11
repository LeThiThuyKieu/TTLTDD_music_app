import pool from "../../config/database";
import { AlbumWithArtist } from "../../models";

export class AdminAlbumRepository {

static async findAllAlbums( limit: number, offset: number): Promise<AlbumWithArtist[]> {
const sql = `
    SELECT al.album_id, al.title, al.cover_url, al.is_active, ar.artist_id, ar.name AS artist_name, ar.is_active as artist_is_active 
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
  static async deleteAlbumById(album_id: number): Promise<boolean> {
    const sql = `DELETE FROM albums WHERE album_id = ?`;
    const [result]: any = await pool.query(sql, [album_id]);
    return result.affectedRows > 0;
  }
}