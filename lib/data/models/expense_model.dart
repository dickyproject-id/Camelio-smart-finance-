import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseItem {
  final String name;
  final double price;
  final int quantity;

  ExpenseItem({required this.name, required this.price, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class ExpenseModel {
  final String? id;
  final String userId;
  final String merchantName;
  final double totalAmount;
  final DateTime date;
  final String category;
  final List<ExpenseItem> items;
  final String? notes;
  final String? receiptImageUrl;

  ExpenseModel({
    this.id,
    required this.userId,
    required this.merchantName,
    required this.totalAmount,
    required this.date,
    required this.category,
    required this.items,
    this.notes,
    this.receiptImageUrl,
  });

  // Digunakan untuk mengubah Data dari Firestore menjadi Objek Dart
  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      merchantName: data['merchantName'] ?? 'Unknown Merchant',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      category: data['category'] ?? 'Uncategorized',
      items: data['items'] != null
          ? (data['items'] as List).map((i) => ExpenseItem.fromJson(i)).toList()
          : [],
      notes: data['notes'],
      receiptImageUrl: data['receiptImageUrl'],
    );
  }

  // Digunakan untuk mengirim data Dart ke Firebase Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'merchantName': merchantName,
      'totalAmount': totalAmount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'items': items.map((i) => i.toJson()).toList(),
      'notes': notes,
      'receiptImageUrl': receiptImageUrl,
    };
  }

  // CopyWith berguna untuk proses Update data lokal / State sebelum disimpan
  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? merchantName,
    double? totalAmount,
    DateTime? date,
    String? category,
    List<ExpenseItem>? items,
    String? notes,
    String? receiptImageUrl,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchantName: merchantName ?? this.merchantName,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      category: category ?? this.category,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
    );
  }
}
