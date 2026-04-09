import 'dart:convert';

class CalculationRecord {
  final String date;
  final String elementType;
  final int count;
  final double concrete;
  final double steel;
  final double totalCost;

  CalculationRecord({
    required this.date,
    required this.elementType,
    required this.count,
    required this.concrete,
    required this.steel,
    required this.totalCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'element_type': elementType,
      'count': count,
      'concrete_m3': concrete,
      'steel_tons': steel,
      'total_cost': totalCost,
    };
  }

  factory CalculationRecord.fromMap(Map<String, dynamic> map) {
    return CalculationRecord(
      date: map['date'] ?? 'محفوظ سحابياً',
      elementType: map['element_type'] ?? 'عنصر',
      count: map['count']?.toInt() ?? 1,
      concrete: map['concrete_m3']?.toDouble() ?? 0.0,
      steel: map['steel_tons']?.toDouble() ?? 0.0,
      totalCost: map['total_cost']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());
  factory CalculationRecord.fromJson(String source) =>
      CalculationRecord.fromMap(json.decode(source));
}
