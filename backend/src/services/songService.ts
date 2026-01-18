import { SongRepository } from "../repositories/SongRepository";
import { Song, SongWithArtists } from "../models";

export class SongService {
  // Lấy danh sách bài hát
  static async getAllSongs(
    limit: number = 50,
    offset: number = 0
  ): Promise<Song[]> {
    return await SongRepository.findAll(limit, offset);
  }

  // Lấy bài hát theo ID
  static async getSongById(songId: number): Promise<SongWithArtists | null> {
    return await SongRepository.findByIdWithArtists(songId);
  }

  // Tìm kiếm bài hát
  static async searchSongs(query: string, limit: number = 50): Promise<Song[]> {
    return await SongRepository.search(query, limit);
  }

  // Lấy bài hát theo genre
  static async getSongsByGenre(
    genreId: number,
    limit: number = 50,
    offset: number = 0
  ): Promise<Song[]> {
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
  // Lấy chi tiết bài hát (đầy đủ thông tin)
static async getSongDetail(id: number) {
  return await SongRepository.findByIdWithFullInfo(id);
}

}
