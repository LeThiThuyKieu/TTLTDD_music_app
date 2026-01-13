import { Artist } from "../../models/Artist";
import { AdminArtistRepository } from "../../repositories/admin/adminArtistRepository";
export class AdminArtistService {
    // LẤY DANH SÁCH NGHỆ SĨ
    static async getAllArtists(limit: number, offset: number
        // , search?: string, isActive?: number
    ): Promise<Artist[]> {
        const artists = await AdminArtistRepository.findAllArtists(limit, offset);    
        return artists;
    }

    // XOÁ NGHỆ SĨ THEO ID
    static async deleteArtistById(artist_id: number): Promise<boolean> {
        return AdminArtistRepository.deleteArtistById(artist_id);
    }

    //LẤY CHI TIẾT NGHỆ SĨ THEO ID
     static async getArtistById(artist_id: number): Promise<Artist | null> {
    return AdminArtistRepository.findArtistById(artist_id);
  }

  //THÊM NGHỆ SĨ MỚI
   static async createArtist(data: {
    name: string;
    description?: string;
    avatar_url: string;
    avatar_public_id: string;
  }) {
    return AdminArtistRepository.createArtist(data);
  }

    //CẬP NHẬP NGHỆ SĨ THEO ID
  static async updateArtist(
    artist_id: number,
    data: {
      name: string;
      description?: string;
      is_active: boolean;
      avatar_url?: string;
      avatar_public_id?: string;
    }
  ) {
    return AdminArtistRepository.updateArtist(artist_id, data);
  }

}