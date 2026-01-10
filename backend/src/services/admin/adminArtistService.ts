import { Artist } from "../../models/Artist";
import { AdminArtistRepository } from "../../repositories/admin/adminArtistRepoository";
export class AdminArtistService {
    static async getAllArtists(limit: number, offset: number
        // , search?: string, isActive?: number
    ): Promise<Artist[]> {
        const artists = await AdminArtistRepository.findAllArtists(limit, offset);
        
    //      // Filter theo tên nếu có search
    // if (search) {
    //   const searchLower = search.toLowerCase();
    //   artists = artists.filter(a => a.name.toLowerCase().includes(searchLower));
    // }

    // // Filter theo trạng thái nếu isActive được truyền
    // if (isActive !== undefined) {
    //   artists = artists.filter(a => a.is_active === isActive);
    // }
           
        return artists;
    }

}