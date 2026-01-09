import { SongRepository } from "../repositories/SongRepository";
import { Song, SongWithArtists } from "../models";

export class SongService {
  // Lấy danh sách bài hát (có artists)
  static async getAllSongs(
    limit: number = 50,
    offset: number = 0
  ): Promise<SongWithArtists[]> {
    return await SongRepository.findAll(limit, offset);
  }

  // Lấy bài hát theo ID (có artists)
  static async getSongById(songId: number): Promise<SongWithArtists | null> {
    return await SongRepository.findByIdWithArtists(songId);
  }

  // Tìm kiếm bài hát (có artists)
  static async searchSongs(
    query: string,
    limit: number = 50,
    offset: number = 0
  ): Promise<SongWithArtists[]> {
    return await SongRepository.search(query, limit, offset);
  }

  // Lấy bài hát theo genre (có artists)
  static async getSongsByGenre(
    genreId: number,
    limit: number = 50,
    offset: number = 0
  ): Promise<SongWithArtists[]> {
    return await SongRepository.findByGenre(genreId, limit, offset);
  }

  // Tạo bài hát mới
  static async createSong(songData: Song): Promise<Song> {
    return await SongRepository.create(songData);
  }

  // Lấy bài hát theo artist (đã có artists)
  static async getSongsByArtist(
    artistId: number,
    limit: number = 50,
    offset: number = 0
  ): Promise<SongWithArtists[]> {
    return await SongRepository.findByArtist(artistId, limit, offset);
  }
}
