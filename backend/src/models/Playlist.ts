// Playlist Model
export interface Playlist {
  playlist_id?: number;
  user_id: number;
  name: string;
  cover_url?: string;
  is_public?: number;
  created_at?: Date;
}
