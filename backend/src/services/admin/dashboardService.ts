import { AdminDashboardRepository } from "../../repositories/admin/dashboardRepository";
import dayjs from "dayjs";
const calcPercent = (today: number, yesterday: number) => {
  if (yesterday === 0) return today > 0 ? 100 : 0;
  return Number((((today - yesterday) / yesterday) * 100).toFixed(1));
};

export class AdminDashboardService {
//1. API (GET /api/admin/dashboard/overview)
static async getOverview() {
    const data = await AdminDashboardRepository.getOverviewRaw();

    return {
      songs: {
        total: data.total_songs,
        active: data.active_songs,
      },
      albums: {
        total: data.total_albums,
        active: data.active_albums,
      },
      artists: {
        total: data.total_artists,
        active: data.active_artists,
      },
      users: {
        total: data.total_users,
        active: data.active_users,
      },
    };
  }

  //2. API(GET /api/admin/dashboard/weekly)
   static async getWeekly() {
    const raw = await AdminDashboardRepository.getWeeklyRaw();
    const total = await AdminDashboardRepository.getTotalPlays();

    const map = new Map<string, number>();
    raw.forEach((r: any) => {
      map.set(dayjs(r.date).format("YYYY-MM-DD"), r.value);
    });

    const daily = [];

    // { date: "2026-01-14", value: 0 },
    for (let i = 6; i >= 0; i--) {
      const date = dayjs().subtract(i, "day").format("YYYY-MM-DD");
      daily.push({
        date,
        value: map.get(date) || 0,
      });
    }

    return {
      total,
      daily,
    };
  }

    // 3 API (Get api/admin/dashboard/highlights)
  static async getHighlights() {
    const data = await AdminDashboardRepository.getHighlightsRaw();

    return [
      {
        title: "Lượt nghe hôm nay",
        subtitle: "So với hôm qua",
        value: data.today_plays,
        percent: calcPercent(data.today_plays, data.yesterday_plays),//(today - yesterday) / yesterday * 100
      },
      {
        title: "Tổng lượt yêu thích",
        subtitle: "Toàn hệ thống",
        value: data.total_favorites,
        percent: 0, // tổng nên không so sánh ngày
      },
      {
        title: "Tổng playlist",
        subtitle: "So với hôm qua",
        value: data.total_playlists,
        percent: calcPercent(data.today_playlists, data.yesterday_playlists),
      },
    ];
  }

  //4. API (Get api/admin/dashboard/topsongs?limit=10)
  static async getTopSongs(limit = 10) {
  const data = await AdminDashboardRepository.getTopSongsRaw(limit);

  return data.map((s: any) => ({
    id: s.id,
    title: s.title,
    artist: s.artist,
    plays: Number(s.plays),
    image: s.image,
  }));
}
// 5. API (GET /api/admin/dashboard/genredistribution)
static async getGenreDistribution() {
  const data = await AdminDashboardRepository.getGenreDistributionRaw();

  return data.map((g: any) => ({
    name: g.name,
    songCount: Number(g.songCount),
  }));
}

}
