class WardrobeFailure implements Exception {
  WardrobeFailure(this.message);

  final String message;

  @override
  String toString() => 'WardrobeFailure: $message';
}

