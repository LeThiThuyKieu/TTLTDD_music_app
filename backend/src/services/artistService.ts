import { ArtistRepository } from "../repositories/ArtistRepository";
import { Artist } from "../models";

export class ArtistService {
  static async getAllArtists(limit: number): Promise<Artist[]> {
    return await ArtistRepository.findAll(limit);
  }

  static async getArtistById(id: number): Promise<Artist | null> {
    return await ArtistRepository.findById(id);
  }
}
