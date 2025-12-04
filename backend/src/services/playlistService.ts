import { PlaylistModel } from "../models/Playlist";
import { UserModel } from "../models/User";
import { Playlist, Song } from "../types";

export class PlaylistService {
  // Lấy user từ Firebase UID
  private static async getUserByFirebaseUid(
    firebaseUid: string
  ): Promise<{ user_id: number } | null> {
    const user = await UserModel.findByFirebaseUid(firebaseUid);
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

    return await PlaylistModel.create({
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

    return await PlaylistModel.findByUserId(user.user_id);
  }

  // Lấy playlist theo ID
  static async getPlaylistById(playlistId: number): Promise<Playlist | null> {
    return await PlaylistModel.findById(playlistId);
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
    return await PlaylistModel.getSongs(playlistId);
  }

  // Thêm bài hát vào playlist
  static async addSongToPlaylist(
    playlistId: number,
    songId: number,
    firebaseUid: string
  ): Promise<boolean> {
    const playlist = await PlaylistModel.findById(playlistId);
    if (!playlist) return false;

    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user || user.user_id !== playlist.user_id) return false;

    return await PlaylistModel.addSong(playlistId, songId);
  }

  // Xóa bài hát khỏi playlist
  static async removeSongFromPlaylist(
    playlistId: number,
    songId: number,
    firebaseUid: string
  ): Promise<boolean> {
    const playlist = await PlaylistModel.findById(playlistId);
    if (!playlist) return false;

    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user || user.user_id !== playlist.user_id) return false;

    return await PlaylistModel.removeSong(playlistId, songId);
  }

  // Xóa playlist
  static async deletePlaylist(
    playlistId: number,
    firebaseUid: string
  ): Promise<boolean> {
    const playlist = await PlaylistModel.findById(playlistId);
    if (!playlist) return false;

    const user = await this.getUserByFirebaseUid(firebaseUid);
    if (!user || user.user_id !== playlist.user_id) return false;

    return await PlaylistModel.delete(playlistId);
  }
}
