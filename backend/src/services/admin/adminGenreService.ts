import { Genre } from "../../models/Genre";
import { AdminGenreRepository } from "../../repositories/admin/adminGenreRepository";
export class AdminGenreService {
    static async getAllGenres(limit: number, offset: number
    ): Promise<Genre[]> {
        const genres = await AdminGenreRepository.findAllGenres(limit, offset);
        return genres;
    }


}