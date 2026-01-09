import { AlbumRepository } from "../repositories/AlbumRepository";

export class AlbumService {
  static async getAllAlbums(limit: number = 50, offset: number = 0) {
    const rows = await AlbumRepository.findAllWithArtist(limit, offset);
    // Map rows to include nested artist object compatible with frontend
    return rows.map((row: any) => ({
      album_id: row.album_id,
      title: row.title,
      artist_id: row.artist_id,
      cover_url: row.cover_url,
      release_date: row.release_date,
      is_active: row.is_active,
      artist: row.artist_id
        ? {
            artist_id: row.artist_id,
            name: row.artist_name,
            avatar_url: row.artist_avatar,
          }
        : null,
    }));
  }

  static async getAlbumById(albumId: number) {
    return await AlbumRepository.findById(albumId);
  }

  static async getSongs(albumId: number) {
    return await AlbumRepository.getSongs(albumId);
  }
}