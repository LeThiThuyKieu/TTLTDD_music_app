import { PlaylistRepository } from "../repositories/PlaylistRepository";
import { Playlist, Song } from "../models";

export class PlaylistService {
  // Tạo playlist mới
  static async createPlaylist(
    userId: number,
    name: string,
    cover_url?: string,
    is_public: boolean = false
  ): Promise<Playlist> {
    return await PlaylistRepository.create({
      user_id: userId,
      name,
      cover_url,
      is_public: is_public ? 1 : 0,
    });
  }

  // Lấy playlists của user
  static async getMyPlaylists(userId: number): Promise<Playlist[]> {
    return await PlaylistRepository.findByUserId(userId);
  }

  // Lấy playlist theo ID
  static async getPlaylistById(playlistId: number): Promise<Playlist | null> {
    return await PlaylistRepository.findById(playlistId);
  }

  // Kiểm tra quyền truy cập playlist
  static async checkPlaylistAccess(
    playlist: Playlist,
    userId: number | undefined
  ): Promise<boolean> {
    // Nếu playlist public thì ai cũng xem được
    if (playlist.is_public === 1) return true;

    // Nếu không public thì phải là chủ sở hữu
    if (!userId) return false;

    return userId === playlist.user_id;
  }

  // Lấy danh sách bài hát trong playlist
  static async getPlaylistSongs(playlistId: number): Promise<Song[]> {
    return await PlaylistRepository.getSongs(playlistId);
  }

  // Thêm bài hát vào playlist
  static async addSongToPlaylist(
    playlistId: number,
    songId: number,
    userId: number
  ): Promise<boolean> {
    const playlist = await PlaylistRepository.findById(playlistId);
    if (!playlist) return false;

    if (userId !== playlist.user_id) return false;

    return await PlaylistRepository.addSong(playlistId, songId);
  }

  // Xóa bài hát khỏi playlist
  static async removeSongFromPlaylist(
    playlistId: number,
    songId: number,
    userId: number
  ): Promise<boolean> {
    const playlist = await PlaylistRepository.findById(playlistId);
    if (!playlist) return false;

    if (userId !== playlist.user_id) return false;

    return await PlaylistRepository.removeSong(playlistId, songId);
  }

  // Xóa playlist
  static async deletePlaylist(
    playlistId: number,
    userId: number
  ): Promise<boolean> {
    const playlist = await PlaylistRepository.findById(playlistId);
    if (!playlist) return false;

    if (userId !== playlist.user_id) return false;

    return await PlaylistRepository.delete(playlistId);
  }

   /**
   * Lấy playlist của user theo bài hát
   */
  static async getPlaylistsBySong(
    songId: number,
    userId: number
  ) {
    return PlaylistRepository.findPlaylistsBySong(songId, userId);
  }
}
