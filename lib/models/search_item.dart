class SearchItem {
  final String branchId;
  final String tableId;
  final String tableName;
  final String branchName;
  final String? metaTerms;
  final String? metaSource;
  SearchItem({
    required this.branchId,
    required this.tableId,
    required this.tableName,
    this.branchName = "",
    this.metaTerms,
    this.metaSource
  });
}
