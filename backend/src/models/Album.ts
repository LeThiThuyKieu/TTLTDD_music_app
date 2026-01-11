import { Artist } from "./Artist";

// Album Model
export interface Album {
  album_id?: number;
  title: string;
  artist_id?: number;
  cover_url?: string;
  release_date?: Date;
  is_active?: number;
}

export interface AlbumWithArtist extends Album {
  artist?: Artist; 
}