class IdGenerator {
  static int _currentId = 0;

  static int nextId() {
    // Reset to 0 if we reach the maximum value
    if (_currentId >= 0xFFFFFFFF) {
      _currentId = 0;
    }
    return _currentId++;
  }
}
