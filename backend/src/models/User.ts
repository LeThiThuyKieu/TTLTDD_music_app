// User Model
export interface User {
  user_id?: number;
  firebase_uid: string;
  name: string;
  email: string;
  avatar_url?: string;
  created_at?: Date;
}
