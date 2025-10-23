class ApiResponse<T> {
  final List<T> data;
  final int totalCount;
  final int pageIndex;
  final int pageSize;

  ApiResponse({
    required this.data,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse<T>(
      data: (json['data'] as List).map((item) => fromJson(item)).toList(),
      totalCount: json['totalCount'],
      pageIndex: json['pageIndex'],
      pageSize: json['pageSize'],
    );
  }
}
