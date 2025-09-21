class TableConfig {
  final int? id;
  final String tableName;
  final int archivalDays;
  final int purgeDays;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TableConfig({
    this.id,
    required this.tableName,
    required this.archivalDays,
    required this.purgeDays,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory TableConfig.fromJson(Map<String, dynamic> json) {
    return TableConfig(
      id: json['id'],
      tableName: json['tableName'],
      archivalDays: json['archivalDays'],
      purgeDays: json['purgeDays'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableName': tableName,
      'archivalDays': archivalDays,
      'purgeDays': purgeDays,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TableConfig copyWith({
    int? id,
    String? tableName,
    int? archivalDays,
    int? purgeDays,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableConfig(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      archivalDays: archivalDays ?? this.archivalDays,
      purgeDays: purgeDays ?? this.purgeDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}