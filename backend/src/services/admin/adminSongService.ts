import { SongWithArtists } from "../../models/Song";
import {AdminSongRepository} from "../../repositories/admin/adminSongRepository";


export class AdminSongService {
  // LẤY DANH SÁCH BÀI HÁT
  static async getAllSongs(limit: number, offset: number): Promise<SongWithArtists []> {
    return AdminSongRepository.findAllSong(limit, offset);
  }
  // LẤY CHI TIẾT BÀI HÁT THEO ID
  static async getSongById(song_id: number, includeDetails = false): Promise<SongWithArtists | null> {
    return AdminSongRepository.findSongById(song_id, includeDetails);
  }
  // XOÁ BÀI HÁT THEO ID
  static async deleteSongById(song_id: number): Promise<boolean> {
    return AdminSongRepository.deleteSongById(song_id);
  }
  // THÊM BÀI HÁT MỚI
  static async createSong(data: {
  title: string;
  genre_id: number;
  duration: number;
  lyrics?: string;
  artistIds: number[];
  file_url: string;
  file_public_id: string;
  cover_url?: string | null;
  cover_public_id?: string | null;
}) {
  return AdminSongRepository.createSong(data);
}
  // CẬP NHẬP BÀI HÁT THEO ID

static async updateSong(
  song_id: number,
  data: {
    title: string;
    genre_id: number;
    duration: number;
    lyrics?: string;
    is_active: boolean;
    artistIds: number[];
    file_url?: string;
    file_public_id?: string;
    cover_url?: string;
    cover_public_id?: string;
  }
) {
  return AdminSongRepository.updateSong(song_id, data);
}
}