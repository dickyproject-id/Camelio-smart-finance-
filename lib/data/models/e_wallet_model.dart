import 'package:cloud_firestore/cloud_firestore.dart';

class EWalletModel {
  final String? id;
  final String userId;
  final String name;
  final String
  type; // 'banking', 'e-wallet', 'marketplace', 'loan', 'investment', 'cash'
  final double balance;
  final String? accountNumber; // or email for marketplace
  final String? iconUrl;
  final DateTime? lastSyncDate;
  final DateTime createdAt;

  EWalletModel({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    this.accountNumber,
    this.iconUrl,
    this.lastSyncDate,
    required this.createdAt,
  });

  factory EWalletModel.fromMap(Map<String, dynamic> data, String documentId) {
    return EWalletModel(
      id: documentId,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'cash',
      balance: (data['balance'] ?? 0).toDouble(),
      accountNumber: data['accountNumber'],
      iconUrl: data['iconUrl'],
      lastSyncDate: data['lastSyncDate'] != null
          ? (data['lastSyncDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'accountNumber': accountNumber,
      'iconUrl': iconUrl,
      'lastSyncDate': lastSyncDate,
      'createdAt': createdAt,
    };
  }

  EWalletModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    double? balance,
    String? accountNumber,
    String? iconUrl,
    DateTime? lastSyncDate,
    DateTime? createdAt,
  }) {
    return EWalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      accountNumber: accountNumber ?? this.accountNumber,
      iconUrl: iconUrl ?? this.iconUrl,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
