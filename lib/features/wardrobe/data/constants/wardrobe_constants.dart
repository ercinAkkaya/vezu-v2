class WardrobeFilters {
  WardrobeFilters._();

  static const filterOptions = <WardrobeFilter>[
    WardrobeFilter(labelKey: 'tabAll', categoryKey: null),
    WardrobeFilter(labelKey: 'tabTops', categoryKey: 'upper_clothing'),
    WardrobeFilter(labelKey: 'tabBottoms', categoryKey: 'lower_clothing'),
    WardrobeFilter(labelKey: 'tabShoes', categoryKey: 'shoes'),
    WardrobeFilter(labelKey: 'tabAccessories', categoryKey: 'accessory'),
    WardrobeFilter(labelKey: 'wardrobeCategoryOuter', categoryKey: 'outerwear'),
  ];
}

class WardrobeFilter {
  const WardrobeFilter({required this.labelKey, required this.categoryKey});

  final String labelKey;
  final String? categoryKey;
}

class WardrobeCategoryTypes {
  WardrobeCategoryTypes._();

  static const values = <String, List<String>>{
    'upper_clothing': [
      'shirt',
      't_shirt',
      'blouse',
      'sweater',
      'hoodie',
      'dress',
    ],
    'lower_clothing': [
      'pants',
      'jeans',
      'shorts',
      'skirt',
      'leggings',
    ],
    'shoes': [
      'sneakers',
      'boots',
      'heels',
      'loafers',
      'sandals',
      'oxfords',
    ],
    'accessory': [
      'bag',
      'belt',
      'hat',
      'scarf',
      'jewelry',
      'watch',
    ],
    'outerwear': [
      'jacket',
      'coat',
      'blazer',
      'vest',
    ],
  };
}

class WardrobeTypeLabels {
  WardrobeTypeLabels._();

  static const map = <String, String>{
    'shirt': 'wardrobeTypeShirt',
    't_shirt': 'wardrobeTypeTShirt',
    'blouse': 'wardrobeTypeBlouse',
    'sweater': 'wardrobeTypeSweater',
    'hoodie': 'wardrobeTypeHoodie',
    'dress': 'wardrobeTypeDress',
    'pants': 'wardrobeTypePants',
    'jeans': 'wardrobeTypeJeans',
    'shorts': 'wardrobeTypeShorts',
    'skirt': 'wardrobeTypeSkirt',
    'leggings': 'wardrobeTypeLeggings',
    'sneakers': 'wardrobeTypeSneakers',
    'boots': 'wardrobeTypeBoots',
    'heels': 'wardrobeTypeHeels',
    'loafers': 'wardrobeTypeLoafers',
    'sandals': 'wardrobeTypeSandals',
    'oxfords': 'wardrobeTypeOxfords',
    'bag': 'wardrobeTypeBag',
    'belt': 'wardrobeTypeBelt',
    'hat': 'wardrobeTypeHat',
    'scarf': 'wardrobeTypeScarf',
    'jewelry': 'wardrobeTypeJewelry',
    'watch': 'watch',
    'jacket': 'wardrobeTypeJacket',
    'coat': 'wardrobeTypeCoat',
    'blazer': 'wardrobeTypeBlazer',
    'vest': 'wardrobeTypeVest',
  };
}

