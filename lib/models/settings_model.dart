/// Settings model for app configuration
class SettingsModel {
  final String menuHeaderText;
  final String menuFooterNote;

  SettingsModel({
    this.menuHeaderText = 'เมนูอาหารวันนี้',
    this.menuFooterNote = '',
  });

  SettingsModel copyWith({String? menuHeaderText, String? menuFooterNote}) {
    return SettingsModel(
      menuHeaderText: menuHeaderText ?? this.menuHeaderText,
      menuFooterNote: menuFooterNote ?? this.menuFooterNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {'menuHeaderText': menuHeaderText, 'menuFooterNote': menuFooterNote};
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      menuHeaderText: map['menuHeaderText'] as String? ?? 'เมนูอาหารวันนี้',
      menuFooterNote: map['menuFooterNote'] as String? ?? '',
    );
  }
}
