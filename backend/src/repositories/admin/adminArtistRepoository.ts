import pool from "../../config/database";
import { Artist } from "../../models";

export class AdminArtistRepository {
static async findAllArtists(
    limit: number,
    offset: number
): Promise<Artist[]> {

const sql = `
    SELECT artist_id, name, avatar_url, is_active 
    FROM artists
    ORDER BY artist_id DESC
    LIMIT ? OFFSET ?;
`;
// thực hiện sql
    const [rows] = await pool.query<any[]>(sql, [limit, offset]);
  // Map dữ liệu DB về kiểu Artist
    const artists: Artist[] = rows.map(row => ({
      artist_id: row.artist_id,
      name: row.name,
      avatar_url: row.avatar_url ?? undefined,
    //   description: row.description ?? undefined,
      is_active: row.is_active ?? 0
    }));

    return artists;
  }
}
