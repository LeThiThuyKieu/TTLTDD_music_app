import { Artist } from "./Artist";

// Song Model
export interface Song {
  song_id?: number;
  title: string;
  album_id?: number;
  genre_id?: number;
  duration?: number;
  file_url: string;
  cover_url?: string;
  release_date?: Date;
  is_active?: number;
}

// Song with Artists
export interface SongWithArtists extends Song {
  artists?: Artist[];
}
