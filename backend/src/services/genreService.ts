import { GenreModel } from "../models/Genre";
import { Genre } from "../types";

export class GenreService {
  // Lấy danh sách genres
  static async getAllGenres(): Promise<Genre[]> {
    return await GenreModel.findAll();
  }

  // Lấy genre theo ID
  static async getGenreById(genreId: number): Promise<Genre | null> {
    return await GenreModel.findById(genreId);
  }

  // Tạo genre mới
  static async createGenre(name: string): Promise<Genre> {
    return await GenreModel.create({ name });
  }

  // Cập nhật genre
  static async updateGenre(
    genreId: number,
    name: string
  ): Promise<Genre | null> {
    return await GenreModel.update(genreId, { name });
  }

  // Xóa genre
  static async deleteGenre(genreId: number): Promise<boolean> {
    return await GenreModel.delete(genreId);
  }
}
