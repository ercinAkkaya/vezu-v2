abstract class BaseGptService {
  Future<Map<String, dynamic>> analyzeClothingItem({
    required String imageUrl,
    required String category,
    required String type,
    String languageCode = 'en',
  });

  Future<String> generateCombination({
    required String prompt,
    required List<Map<String, dynamic>> wardrobeItems,
  });
}
