import { deleteFromCloudinary } from "../../config/cloudinary";
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

    // LẤY CHI TIẾT ALBUM THEO ID
     static async getAlbumById(album_id: number) {
    return AdminAlbumRepository.findAlbumById(album_id);
  }

  // TẠO MỚI ALBUM
 static async createAlbum(data: {
    title: string;
    artist_id?: number;
    cover_url?: string;
    album_public_id?: string;
    is_active?: number;
    song_ids?: number[];
  }) {
    return AdminAlbumRepository.createAlbum(data);
  }

  // CẬP NHẬT ALBUM THEO ID
static async updateAlbum(album_id: number, data: {
    title?: string;
    artist_id?: number;
    cover_url?: string;
    album_public_id?: string;
    is_active?: number;
    song_ids?: number[];
  }) {
    // Lấy album cũ
    const oldAlbum = await AdminAlbumRepository.findAlbumById(album_id);
    if (!oldAlbum) {
      throw new Error("Album not found");
    }
    // update
     const updatedAlbum = await AdminAlbumRepository.updateAlbum(album_id, data);

     // xoá cover cũ nếu có thay đổi
         if (
      data.album_public_id &&
      oldAlbum.album_public_id &&
      data.album_public_id !== oldAlbum.album_public_id
    ) {
      await deleteFromCloudinary(oldAlbum.album_public_id, "image");
    }
    return updatedAlbum;
  }
  
}