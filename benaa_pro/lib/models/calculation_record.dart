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

  // تحويل الكائن إلى Map لتخزينه
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'elementType': elementType,
      'count': count,
      'concrete': concrete,
      'steel': steel,
      'totalCost': totalCost,
    };
  }

  // استرجاع الكائن من Map
  factory CalculationRecord.fromMap(Map<String, dynamic> map) {
    return CalculationRecord(
      date: map['date'] ?? '',
      elementType: map['elementType'] ?? '',
      count: map['count']?.toInt() ?? 0,
      concrete: map['concrete']?.toDouble() ?? 0.0,
      steel: map['steel']?.toDouble() ?? 0.0,
      totalCost: map['totalCost']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());
  factory CalculationRecord.fromJson(String source) =>
      CalculationRecord.fromMap(json.decode(source));
}
