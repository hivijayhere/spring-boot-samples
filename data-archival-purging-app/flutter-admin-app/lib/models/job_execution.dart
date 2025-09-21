class JobExecution {
  final int? id;
  final String tableName;
  final String jobType;
  final String status;
  final int recordsProcessed;
  final int recordsArchived;
  final int recordsPurged;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? errorMessage;
  final DateTime? createdAt;

  JobExecution({
    this.id,
    required this.tableName,
    required this.jobType,
    required this.status,
    this.recordsProcessed = 0,
    this.recordsArchived = 0,
    this.recordsPurged = 0,
    this.startTime,
    this.endTime,
    this.errorMessage,
    this.createdAt,
  });

  factory JobExecution.fromJson(Map<String, dynamic> json) {
    return JobExecution(
      id: json['id'],
      tableName: json['tableName'],
      jobType: json['jobType'],
      status: json['status'],
      recordsProcessed: json['recordsProcessed'] ?? 0,
      recordsArchived: json['recordsArchived'] ?? 0,
      recordsPurged: json['recordsPurged'] ?? 0,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      errorMessage: json['errorMessage'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableName': tableName,
      'jobType': jobType,
      'status': status,
      'recordsProcessed': recordsProcessed,
      'recordsArchived': recordsArchived,
      'recordsPurged': recordsPurged,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'errorMessage': errorMessage,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isRunning => status == 'RUNNING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  bool get isPending => status == 'PENDING';

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }
}