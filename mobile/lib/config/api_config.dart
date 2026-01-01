class ApiConfig {
  // URL của backend server
  // static const String baseUrl = 'http://localhost:3000/api';
  
  // Hoặc nếu test trên emulator Android:
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Hoặc nếu test trên thiết bị thật, dùng IP máy tính:
  // static const String baseUrl = 'http://192.168.1.xxx:3000/api';

  // API Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  
  static const String usersProfile = '/users/profile';
  static const String usersById = '/users';
  
  static const String songs = '/songs';
  static const String songsSearch = '/songs/search';
  static const String songsByGenre = '/songs/genre';
  
  static const String playlists = '/playlists';
  static const String playlistsMy = '/playlists/my';
  
  static const String favorites = '/favorites';
  
  static const String history = '/history';

  static const String genres = '/genres';
}



