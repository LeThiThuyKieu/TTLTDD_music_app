import { deleteFromCloudinary } from "../../config/cloudinary";
import pool from "../../config/database";
import { Artist } from "../../models";

export class AdminArtistRepository {
  // LẤY DANH SÁCH NGHỆ SĨ
static async findAllArtists(
    limit: number,
    offset: number
): Promise<Artist[]> {

const sql = `
    SELECT artist_id, name, avatar_url, avatar_public_id, is_active 
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
      avatar_public_id: row.avatar_public_id ?? undefined,
    //   description: row.description ?? undefined,
      is_active: row.is_active ?? 0
    }));

    return artists;
  }

  // XOÁ NGHỆ SĨ THEO ID
   static async deleteArtistById(artist_id: number): Promise<boolean> {
    const [rows]: any = await pool.query(
      `SELECT avatar_public_id FROM artists WHERE artist_id = ?`,
      [artist_id]
    );
    if (!rows.length) return false;

    await pool.query(`DELETE FROM artists WHERE artist_id = ?`, [artist_id]);

    if (rows[0].avatar_public_id) {
      await deleteFromCloudinary(rows[0].avatar_public_id, "image");
    }

    return true;
  }
  // THÊM NGHỆ SĨ MỚI
  static async createArtist(data: {
    name: string;
    description?: string;
    avatar_url: string;
    avatar_public_id: string;
  }) {
    const [result]: any = await pool.query(
      `
      INSERT INTO artists (name, description, avatar_url, avatar_public_id, is_active)
      VALUES (?, ?, ?, ?, 1)
      `,
      [
        data.name,
        data.description ?? null,
        data.avatar_url,
        data.avatar_public_id
      ]
    );

    return {
      artist_id: result.insertId,
      ...data
    };
  }
  // CẬP NHẬP NGHỆ SĨ THEO ID
  static async updateArtist(
    artist_id: number,
    data: {
      name: string;
      description?: string;
      is_active: boolean;
      avatar_url?: string;
      avatar_public_id?: string;
    }
  ) {
    await pool.query(
      `
      UPDATE artists
      SET
        name = ?,
        description = ?,
        is_active = ?,
        avatar_url = COALESCE(?, avatar_url),
        avatar_public_id = COALESCE(?, avatar_public_id)
      WHERE artist_id = ?
      `,
      [
        data.name,
        data.description ?? null,
        data.is_active ? 1 : 0,
        data.avatar_url ?? null,
        data.avatar_public_id ?? null,
        artist_id
      ]
    );

    return this.findArtistById(artist_id);
  }
  // LẤY CHI TIẾT NGHỆ SĨ THEO ID
  static async findArtistById(artist_id: number): Promise<Artist | null> {
    const sql = `
      SELECT artist_id, name, avatar_url, avatar_public_id, description, is_active
      FROM artists
      WHERE artist_id = ?
    `;

    const [rows]: any = await pool.query(sql, [artist_id]);
    if (!rows.length) return null;

    return {
      artist_id: rows[0].artist_id,
      name: rows[0].name,
      avatar_url: rows[0].avatar_url,
      description: rows[0].description,
      is_active: rows[0].is_active
    };
  }

}
