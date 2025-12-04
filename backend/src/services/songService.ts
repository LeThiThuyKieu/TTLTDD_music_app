import { SongModel } from "../models/Song";
import { Song, SongWithArtists } from "../types";

export class SongService {
  // Lấy danh sách bài hát
  static async getAllSongs(
    limit: number = 50,
    offset: number = 0
  ): Promise<Song[]> {
    return await SongModel.findAll(limit, offset);
  }

  // Lấy bài hát theo ID
  static async getSongById(songId: number): Promise<SongWithArtists | null> {
    return await SongModel.findByIdWithArtists(songId);
  }

  // Tìm kiếm bài hát
  static async searchSongs(query: string, limit: number = 50): Promise<Song[]> {
    return await SongModel.search(query, limit);
  }

  // Lấy bài hát theo genre
  static async getSongsByGenre(
    genreId: number,
    limit: number = 50,
    offset: number = 0
  ): Promise<Song[]> {
    return await SongModel.findByGenre(genreId, limit, offset);
  }

  // Tạo bài hát mới
  static async createSong(songData: Song): Promise<Song> {
    return await SongModel.create(songData);
  }
}
