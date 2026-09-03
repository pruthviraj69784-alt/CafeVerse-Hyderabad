class TableModel {
  final String id;
  final int tableNumber;
  final int capacity;
  final bool isActive;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'tableNumber': tableNumber,
      'capacity': capacity,
      'isActive': isActive,
    };
  }

  factory TableModel.fromMap(Map<String, dynamic> data, String id) {
    return TableModel(
      id: id,
      tableNumber: data['tableNumber'] ?? 0,
      capacity: data['capacity'] ?? 2,
      isActive: data['isActive'] ?? true,
    );
  }
}
