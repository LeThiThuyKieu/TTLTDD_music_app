// History Model
export interface History {
  history_id?: number;
  user_id: number;
  song_id: number;
  listened_at?: Date;
  listened_duration?: number;
}
