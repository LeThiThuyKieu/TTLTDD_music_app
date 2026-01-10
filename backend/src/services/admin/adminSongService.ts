import { SongWithArtists } from "../../models/Song";
import {AdminSongRepository} from "../../repositories/admin/adminSongRepository";


export class AdminSongService {
  static async getAllSongs(limit: number, offset: number): Promise<SongWithArtists []> {
    const rows = await AdminSongRepository.findAllSong(limit, offset);

    const map = new Map<number, SongWithArtists >();

    rows.forEach((row: any) => {
      if (!map.has(row.song_id)) {
        map.set(row.song_id, {
          song_id: row.song_id,
          title: row.title,
          file_url: row.file_url ?? "",
          cover_url: row.cover_url ?? "",
          is_active: row.is_active ?? 0,
          artists: []
        });
      }

      const song = map.get(row.song_id);
     if (song && row.artist_id) {
      if (!song.artists) song.artists = []; 
       song.artists.push({
          artist_id: row.artist_id,
          name: row.artist_name
        });
      }
    });

    return Array.from(map.values());
  }
}