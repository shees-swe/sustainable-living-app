enum WasteCategory {
  plastic('Plastic'),
  paperAndCardboard('Paper & cardboard'),
  glass('Glass'),
  metal('Metal'),
  organic('Organic'),
  other('Other');

  const WasteCategory(this.value);

  final String value;

  static WasteCategory fromValue(String value) => values.singleWhere(
    (category) => category.value == value,
    orElse: () => throw FormatException('Unknown waste category "$value".'),
  );
}
