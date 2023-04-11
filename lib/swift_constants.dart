class SwiftConstants {
  static List<String> varTypes = [
    'Bool',
    'Int',
    'Float',
    'Double',
    'Date',
    'String',
  ];

  static List<String> varOptionalTypes = varTypes.map((e) => '$e?').toList();
  static List<String> varArrayTypes = varTypes.map((e) => '[$e]').toList();
  static List<String> varArrayOptionalTypes =
      varTypes.map((e) => '[$e?]').toList();
  static List<String> varOptionalArrayTypes =
      varTypes.map((e) => '[$e]?').toList();
  static List<String> varOptionalArrayOptionalTypes =
      varTypes.map((e) => '[$e?]?').toList();
  static List<String> allTypes = varTypes +
      varOptionalTypes +
      varArrayTypes +
      varArrayOptionalTypes +
      varOptionalArrayTypes +
      varOptionalArrayOptionalTypes;
}
