import { SongRepository } from "../repositories/SongRepository";
import { ArtistRepository } from "../repositories/ArtistRepository";
import { AlbumRepository } from "../repositories/AlbumRepository";
import { GenreRepository } from "../repositories/GenreRepository";

export class SearchService {
  static async searchAll(query: string, limit: number) {
    const [songs, artists, albums, genres] = await Promise.all([
      SongRepository.search(query, limit),
      ArtistRepository.search(query, limit),
      AlbumRepository.search(query, limit),
      GenreRepository.search(query, limit),
    ]);

    return {
      songs,
      artists,
      albums,
      genres,
    };
  }
}
