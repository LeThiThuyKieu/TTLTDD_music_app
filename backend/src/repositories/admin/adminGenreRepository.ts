import pool from "../../config/database";
import { Genre } from "../../models";

export class AdminGenreRepository {
static async findAllGenres(
    limit: number,
    offset: number
): Promise<Genre[]> {

const sql = `
    SELECT * 
    FROM genres
    LIMIT ? OFFSET ?;
`;
// thực hiện sql
    const [rows] = await pool.query<any[]>(sql, [limit, offset]);
  // Map dữ liệu DB về kiểu Genre
    const genres: Genre[] = rows.map(row => ({
      genre_id: row.genre_id,
      name: row.name,
    }));

    return genres;
  }

}