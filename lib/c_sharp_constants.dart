class CSharpConstants {
  static List<String> varTypes = [
    'bool',
    'byte',
    'sbyte',
    'char',
    'decimal',
    'int',
    'float',
    'double',
    'uint',
    'nint',
    'nuint',
    'long',
    'ulong',
    'short',
    'ushort',
    'string',
    'dynamic',
    'DateTime',
  ];

  static List<String> varOptionalTypes = varTypes.map((e) => '$e?').toList();
  static List<String> varArrayTypes = varTypes.map((e) => 'List<$e>').toList();
  static List<String> varArrayOptionalTypes =
      varTypes.map((e) => 'List<$e?>').toList();
  static List<String> varOptionalArrayTypes =
      varTypes.map((e) => 'List<$e>?').toList();
  static List<String> varOptionalArrayOptionalTypes =
      varTypes.map((e) => 'List<$e?>?').toList();
  static List<String> allTypes = varTypes +
      varOptionalTypes +
      varArrayTypes +
      varArrayOptionalTypes +
      varOptionalArrayTypes +
      varOptionalArrayOptionalTypes;
}
