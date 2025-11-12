abstract class BaseGptService {
  Future<String> analyzeOutfit({
    required String prompt,
    required Map<String, dynamic> metadata,
  });
  Future<String> generateCombination({
    required String prompt,
    required List<Map<String, dynamic>> wardrobeItems,
  });
}
