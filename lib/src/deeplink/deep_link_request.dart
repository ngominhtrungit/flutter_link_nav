class DeepLinkRequest {
  /// The full URI received from the platform
  final Uri uri;

  /// The parsed path/route name
  final String path;

  /// Query parameters from the URI
  final Map<String, String> queryParameters;

  /// Optional arguments passed from Navigator or deep link processor
  final dynamic arguments;

  DeepLinkRequest({
    required this.uri,
    required this.path,
    required this.queryParameters,
    this.arguments,
  });

  @override
  String toString() => 'DeepLinkRequest(path: $path, params: $queryParameters)';
}

extension QueryParametersX on Map<String, String> {
  /// Safely parse an integer value
  int? getInt(String key) => int.tryParse(this[key] ?? '');

  /// Safely parse a double value
  double? getDouble(String key) => double.tryParse(this[key] ?? '');

  /// Safely parse a boolean value
  /// Returns [true] for 'true' or '1'
  /// Returns [false] for 'false' or '0'
  /// Returns [defaultValue] if the key is missing or invalid
  bool getBool(String key, {bool defaultValue = false}) {
    final val = this[key]?.toLowerCase();
    if (val == 'true' || val == '1') return true;
    if (val == 'false' || val == '0') return false;
    return defaultValue;
  }

  /// Safely parse an enum value
  T? getEnum<T extends Enum>(String key, List<T> values) {
    final val = this[key];
    for (final e in values) {
      if (e.name == val) return e;
    }
    return null;
  }

  /// Safely parse a list of strings separated by [separator]
  List<String> getList(String key, {String separator = ','}) {
    final val = this[key];
    if (val == null || val.isEmpty) return [];
    return val.split(separator).where((e) => e.isNotEmpty).toList();
  }
}

extension DeepLinkObjectX on Object? {
  /// Safely cast dynamic/Object to `Map<String, String>` for deep link parameter parsing.
  /// Returns an empty map if the object is not a Map.
  Map<String, String> get toParams {
    final self = this;
    if (self is Map<String, String>) return self;
    if (self is Map) {
      return self.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return const {};
  }
}
