class Gateway {
  // Class that handles communication with backend server
  // Has endpoint url, and handles middleware like signing out on 401 Unauthorized error
  // Simple abstraction such as get, post, put, delete methods
  // Is NOT a singleton, can be instantiated normally but it made a singleton in get_it.dart
}
