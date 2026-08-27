import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;

  // Preferensi kustom bawaan User
  final String currencyPreference; // Contoh: IDR, USD
  final double? monthlyBudget; // Target pengeluaran bulanan

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.currencyPreference = 'IDR',
    this.monthlyBudget,
  });

  // Fungsi untuk membaca Data Firestore menjadi Objek Dart
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      currencyPreference: data['currencyPreference'] ?? 'IDR',
      monthlyBudget: data['monthlyBudget']?.toDouble(),
    );
  }

  // Fungsi untuk mengubah Dart Objek ke Map Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'currencyPreference': currencyPreference,
      'monthlyBudget': monthlyBudget,
    };
  }

  // CopyWith untuk proses manipulasi State dengan mudah
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? currencyPreference,
    double? monthlyBudget,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      currencyPreference: currencyPreference ?? this.currencyPreference,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }
}
