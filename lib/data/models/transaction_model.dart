class TransactionModel {
  final String? id;
  final String userId;
  final String? walletId; // ID of the e-wallet used
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String type; // 'expense' atau 'income'
  final String? imageUrl;
  final String source; // 'manual', 'ai', 'ocr', 'gmail'
  final List<dynamic>? items; // Daftar barang dari struk belanja
  final double? aiPredictedAmount; // Menyimpan tebakan awal AI sebelum diedit

  TransactionModel({
    this.id,
    required this.userId,
    this.walletId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.type,
    this.imageUrl,
    required this.source,
    this.items,
    this.aiPredictedAmount,
  });

  // Mengubah data dari Map (Firestore) ke Object Flutter
  factory TransactionModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      userId: data['userId'] ?? '',
      walletId: data['walletId'],
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] != null ? data['date'].toDate() : DateTime.now(),
      type: data['type'] ?? 'expense',
      imageUrl: data['imageUrl'],
      source: data['source'] ?? 'manual',
      items: data['items'] != null ? List<dynamic>.from(data['items']) : null,
      aiPredictedAmount: data['aiPredictedAmount'] != null
          ? (data['aiPredictedAmount'] as num).toDouble()
          : null,
    );
  }

  // Mengubah Object Flutter ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'walletId': walletId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      'type': type,
      'imageUrl': imageUrl,
      'source': source,
      if (items != null) 'items': items,
      if (aiPredictedAmount != null) 'aiPredictedAmount': aiPredictedAmount,
    };
  }
}
