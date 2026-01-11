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
}