class NotificationItem {
  final String branchId;
  final String tableId;
  final String tableName;
  final int seq;
  final String subtitle;
  final String lastUpdated;
  final String timestamp;

  NotificationItem({
    required this.branchId,
    required this.tableId,
    required this.tableName,
    required this.seq,
    required this.subtitle,
    required this.lastUpdated,
    required this.timestamp,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      branchId: json['branch_id']?.toString() ?? '',
      tableId: json['table_id']?.toString() ?? '',
      tableName: json['table_name']?.toString() ?? '',
      seq: int.tryParse(json['seq']?.toString() ?? '0') ?? 0,
      subtitle: json['subtitle']?.toString() ?? '',
      lastUpdated: json['last_updated']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }
}
