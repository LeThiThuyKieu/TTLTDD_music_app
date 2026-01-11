import { AlbumWithArtist } from "../../models";
import { AdminAlbumRepository } from "../../repositories/admin/adminAlbumRepository";

export class AdminAlbumService {
    // LẤY DANH SÁCH ALBUM
    static async getAllAlbums(limit: number, offset: number) : 
    Promise<AlbumWithArtist[]> {
    return AdminAlbumRepository.findAllAlbums(limit, offset);
    }
    // XOÁ ALBUM THEO ID
    static async deleteAlbumById(album_id: number): Promise<boolean> {
    return AdminAlbumRepository.deleteAlbumById(album_id);
    }
}