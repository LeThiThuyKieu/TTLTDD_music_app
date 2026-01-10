import pool from "../../config/database";
// import { AdminSong } from "../../models/admin/adminSong.model";
import { SongWithArtists } from "../../models/Song";
import { Artist } from "../../models/Artist";

export class AdminSongRepository {
  static async findAllSong(
    limit: number,
    offset: number
  ): Promise<SongWithArtists[]> {

    const sql = `
      SELECT 
        s.song_id,
        s.title,
        s.file_url,
        s.cover_url,
        s.is_active,
        a.artist_id,
        a.name AS artist_name
      FROM songs s
      LEFT JOIN song_artists sa ON sa.song_id = s.song_id
      LEFT JOIN artists a ON a.artist_id = sa.artist_id
      ORDER BY s.song_id DESC
      LIMIT ? OFFSET ?
    `;
// Thực hiện query
    const [rows] = await pool.query<any[]>(sql, [limit, offset]);
// Map để gom artists theo song_id
    const map = new Map<number, SongWithArtists>();

    for (const row of rows) {
      // Nếu song chưa có trong map, tạo mới
      if (!map.has(row.song_id)) {
        map.set(row.song_id, {
          song_id: row.song_id,
          title: row.title,
          file_url: row.file_url,
          cover_url: row.cover_url,
          is_active: row.is_active,
          artists: []
        });
      }
        // Lấy song từ map
      const song = map.get(row.song_id);
      if (song && row.artist_id) {
        const artist: Artist = {
          artist_id: row.artist_id,
          name: row.artist_name
        };
         song.artists!.push(artist)
      }
    }

    return Array.from(map.values());
  }

  
  static async findSongById(song_id: number, includeDetails = false): Promise<SongWithArtists | null> {
  const fields = includeDetails
    ? "s.*, a.artist_id, a.name AS artist_name, a.avatar_url"
    : "s.song_id, s.title, s.file_url, s.cover_url, s.is_active, a.artist_id, a.name AS artist_name";

  const sql = `
    SELECT ${fields}
    FROM songs s
    LEFT JOIN song_artists sa ON sa.song_id = s.song_id
    LEFT JOIN artists a ON a.artist_id = sa.artist_id
    WHERE s.song_id = ?
  `;

  const [rows] = await pool.query<any[]>(sql, [song_id]);

  if (!rows.length) return null;

  const map = new Map<number, SongWithArtists>();
  for (const row of rows) {
    if (!map.has(row.song_id)) {
      map.set(row.song_id, {
        song_id: row.song_id,
        title: row.title,
        file_url: row.file_url,
        cover_url: row.cover_url,
        is_active: row.is_active,
        artists: []
      });
    }
    const song = map.get(row.song_id);
    if (song && row.artist_id) {
      song.artists!.push({
        artist_id: row.artist_id,
        name: row.artist_name
      });
    }
  }

  return Array.from(map.values())[0];
}

}
