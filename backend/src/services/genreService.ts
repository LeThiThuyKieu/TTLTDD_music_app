import { GenreRepository } from "../repositories/GenreRepository";
import { Genre } from "../models";

export class GenreService {
  // Lấy danh sách genres
  static async getAllGenres(): Promise<Genre[]> {
    return await GenreRepository.findAll();
  }

  // Lấy genre theo ID
  static async getGenreById(genreId: number): Promise<Genre | null> {
    return await GenreRepository.findById(genreId);
  }

  // Tạo genre mới
  static async createGenre(name: string): Promise<Genre> {
    return await GenreRepository.create({ name });
  }

  // Cập nhật genre
  static async updateGenre(
    genreId: number,
    name: string
  ): Promise<Genre | null> {
    return await GenreRepository.update(genreId, { name });
  }

  // Xóa genre
  static async deleteGenre(genreId: number): Promise<boolean> {
    return await GenreRepository.delete(genreId);
  }
}
