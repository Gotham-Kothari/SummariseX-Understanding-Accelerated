class AppConfig {
  //Base URL of your FastAPI backend
  //On Android emulator, 10.0.0.2 maps to localhost machine
  static const String baseUrl = 'http://10.0.2.2:8000';

  //Endpoint for summarisation
  static const String summarisePath = '/summarise';
}
