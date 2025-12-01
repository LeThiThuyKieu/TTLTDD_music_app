// User Types
export interface User {
  user_id?: number;
  firebase_uid: string;
  name: string;
  email: string;
  avatar_url?: string;
  created_at?: Date;
}

// Artist Types
export interface Artist {
  artist_id?: number;
  name: string;
  avatar_url?: string;
  description?: string;
  is_active?: number;
}

// Genre Types
export interface Genre {
  genre_id?: number;
  name: string;
}

// Album Types
export interface Album {
  album_id?: number;
  title: string;
  artist_id?: number;
  cover_url?: string;
  release_date?: Date;
  is_active?: number;
}

// Song Types
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

// Playlist Types
export interface Playlist {
  playlist_id?: number;
  user_id: number;
  name: string;
  cover_url?: string;
  is_public?: number;
  created_at?: Date;
}

// History Types
export interface History {
  history_id?: number;
  user_id: number;
  song_id: number;
  listened_at?: Date;
  listened_duration?: number;
}

// Favorite Types
export interface Favorite {
  user_id: number;
  song_id: number;
}

import { Request } from "express";

// Request Types
export interface AuthenticatedRequest extends Request {
  user?: {
    uid: string;
    email?: string;
    user_id?: number;
  };
}
