import { PlaylistRepository } from "../repositories/PlaylistRepository";
import { UserRepository } from "../repositories/UserRepository";
import { Playlist, Song } from "../models";

export class PlaylistService {
  // Lấy user từ Firebase UID
  private static async getUserByFirebaseUid(
    firebaseUid: string
  ): Promise<{ user_id: number } | null> {
    const user = await UserRepository.findByFirebaseUid(firebaseUid);
    if (!user || !user.user_id) return null;
    return { user_id: user.user_id };
  }

  // Tạo playlist mới
  static async createPlaylist(
    firebaseUid: string,
    name: string,
    cover_url?: string,
    is_public: boolean = false
  ): Promise<Playlist> {
    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) {
      throw new Error("User not found");
    }

    return await PlaylistRepository.create({
      user_id: user.user_id,
      name,
      cover_url,
      is_public: is_public ? 1 : 0,
    });
  }

  // Lấy playlists của user
  static async getMyPlaylists(firebaseUid: string): Promise<Playlist[]> {
    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) return [];

    return await PlaylistRepository.findByUserId(user.user_id);
  }

  // Lấy playlist theo ID
  static async getPlaylistById(playlistId: number): Promise<Playlist | null> {
    return await PlaylistRepository.findById(playlistId);
  }

  // Kiểm tra quyền truy cập playlist
  static async checkPlaylistAccess(
    playlist: Playlist,
    firebaseUid: string | undefined
  ): Promise<boolean> {
    // Nếu playlist public thì ai cũng xem được
    if (playlist.is_public === 1) return true;

    // Nếu không public thì phải là chủ sở hữu
    if (!firebaseUid) return false;

    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user) return false;

    return user.user_id === playlist.user_id;
  }

  // Lấy danh sách bài hát trong playlist
  static async getPlaylistSongs(playlistId: number): Promise<Song[]> {
    return await PlaylistRepository.getSongs(playlistId);
  }

  // Thêm bài hát vào playlist
  static async addSongToPlaylist(
    playlistId: number,
    songId: number,
    firebaseUid: string
  ): Promise<boolean> {
    const playlist = await PlaylistRepository.findById(playlistId);
    if (!playlist) return false;

    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user || user.user_id !== playlist.user_id) return false;

    return await PlaylistRepository.addSong(playlistId, songId);
  }

  // Xóa bài hát khỏi playlist
  static async removeSongFromPlaylist(
    playlistId: number,
    songId: number,
    firebaseUid: string
  ): Promise<boolean> {
    const playlist = await PlaylistRepository.findById(playlistId);
    if (!playlist) return false;

    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user || user.user_id !== playlist.user_id) return false;

    return await PlaylistRepository.removeSong(playlistId, songId);
  }

  // Xóa playlist
  static async deletePlaylist(
    playlistId: number,
    firebaseUid: string
  ): Promise<boolean> {
    const playlist = await PlaylistRepository.findById(playlistId);
    if (!playlist) return false;

    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user || user.user_id !== playlist.user_id) return false;

    return await PlaylistRepository.delete(playlistId);
  }
}
