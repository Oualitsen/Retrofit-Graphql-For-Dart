class GeneratorConfig {
  final List<String> schemaPaths;
  final String mode;
  final String basePackage;
  Map<String, String>? typeMappings;
  final String outputDir;

  GeneratorConfig({
    required this.schemaPaths,
    required this.mode,
    required this.basePackage,
    required this.typeMappings,
    required this.outputDir,
  });

  factory GeneratorConfig.fromJson(Map<String, dynamic> json) {
    return GeneratorConfig(
      schemaPaths: List<String>.from(json['schema_paths']),
      mode: json['mode'],
      basePackage: json['base_package'],
      typeMappings: Map<String, String>.from(json['type_mappings']),
      outputDir: json['output_dir'] ?? 'src/main/java',
    );
  }
}
