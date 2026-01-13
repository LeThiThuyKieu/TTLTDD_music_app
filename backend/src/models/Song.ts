import { Artist } from "./Artist";

// Song Model
export interface Song {
  song_id?: number;
  title: string;
  album_id?: number;
  genre_id?: number;
  duration?: number;
  lyrics?: string;
  file_url: string;
  file_public_id?: string;
  cover_url?: string;
  cover_public_id?: string;
  release_date?: Date;
  is_active?: number;
}

// Song with Artists
export interface SongWithArtists extends Song {
  artists?: Artist[];
}
