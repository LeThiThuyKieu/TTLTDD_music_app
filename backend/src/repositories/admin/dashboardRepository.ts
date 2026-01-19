import pool from "../../config/database";

export class AdminDashboardRepository {
  
    //1. API (GET /api/admin/dashboard/overview)
static async getOverviewRaw() {
    const sql = `
      SELECT
        (SELECT COUNT(*) FROM songs) AS total_songs,
        (SELECT COUNT(*) FROM songs WHERE is_active = 1) AS active_songs,

        (SELECT COUNT(*) FROM albums) AS total_albums,
        (SELECT COUNT(*) FROM albums WHERE is_active = 1) AS active_albums,

        (SELECT COUNT(*) FROM artists) AS total_artists,
        (SELECT COUNT(*) FROM artists WHERE is_active = 1) AS active_artists,

        (SELECT COUNT(*) FROM users) AS total_users,
        (SELECT COUNT(*) FROM users WHERE is_active = 1) AS active_users
    `;

    const [rows]: any = await pool.query(sql);
    return rows[0];
  }

  // 2. API(GET /api/admin/dashboard/weekly)
   static async getWeeklyRaw() {
  const sql = `
    SELECT
      DATE(listened_at) AS date,
      COUNT(*) AS value
    FROM history
    WHERE listened_at >= CURDATE() - INTERVAL 6 DAY
    GROUP BY DATE(listened_at)
    ORDER BY DATE(listened_at)
  `;

  const [rows]: any = await pool.query(sql);
  return rows;
}

static async getTotalPlays() {
  const sql = `SELECT COUNT(*) AS total FROM history`;
  const [rows]: any = await pool.query(sql);
  return rows[0].total;
}


  // 3 API (Get api/admin/dashboard/highlights)
    static async getHighlightsRaw() {
    const sql = `
      SELECT
        (SELECT COUNT(*) FROM history WHERE DATE(listened_at) = CURDATE()) AS today_plays,
        (SELECT COUNT(*) FROM history WHERE DATE(listened_at) = CURDATE() - INTERVAL 1 DAY) AS yesterday_plays,

        (SELECT COUNT(*) FROM favorites) AS total_favorites,

        (SELECT COUNT(*) FROM playlists) AS total_playlists,
        (SELECT COUNT(*) FROM playlists WHERE DATE(created_at) = CURDATE()) AS today_playlists,
        (SELECT COUNT(*) FROM playlists WHERE DATE(created_at) = CURDATE() - INTERVAL 1 DAY) AS yesterday_playlists
    `;

    const [rows]: any = await pool.query(sql);
    return rows[0];
  }

  // 4. API (Get api/admin/dashboard/topsongs)
  static async getTopSongsRaw(limit = 10) {
    const sql = `
      SELECT
        s.song_id AS id,
        s.title,
        s.cover_url AS image,
        COUNT(h.history_id) AS plays,
        GROUP_CONCAT(DISTINCT a.name SEPARATOR ', ') AS artist
      FROM songs s
      LEFT JOIN history h ON h.song_id = s.song_id
      LEFT JOIN song_artists sa ON sa.song_id = s.song_id
      LEFT JOIN artists a ON a.artist_id = sa.artist_id
      WHERE s.is_active = 1
      GROUP BY s.song_id
      ORDER BY plays DESC
      LIMIT ?
    `;

    const [rows]: any = await pool.query(sql, [limit]);
    return rows;
  }

  // 5. API (GET /api/admin/dashboard/genredistribution)
static async getGenreDistributionRaw() {
  const sql = `
    SELECT
      g.name,
      COUNT(s.song_id) AS songCount
    FROM genres g
    LEFT JOIN songs s ON s.genre_id = g.genre_id
    GROUP BY g.genre_id, g.name
    ORDER BY songCount DESC
  `;

  const [rows]: any = await pool.query(sql);
  return rows;
}

}
