import 'package:flutter/material.dart';

class BrandUtils {
  static String? getAssetPath(String text) {
    final t = text.toLowerCase();
    if (t.contains('ocbc')) return 'assets/ocbc.png';
    if (t.contains('bca')) return 'assets/bca.png';
    if (t.contains('bri')) return 'assets/bri.png';
    if (t.contains('bni')) return 'assets/bni.png';
    if (t.contains('mandiri')) return 'assets/mandiri.png';
    if (t.contains('gopay')) return 'assets/gopay.jpg';
    if (t.contains('ovo')) return 'assets/ovo.png';
    if (t.contains('dana')) return 'assets/dana.jpeg';
    if (t.contains('shopee')) return 'assets/shopeepay.png';
    if (t.contains('lazada')) return 'assets/lazada.png';
    if (t.contains('tokopedia') || t.contains('toped')) {
      return 'assets/tokopedia.png';
    }
    if (t.contains('tiktok')) return 'assets/tiktokshop.png';
    if (t.contains('klikindomaret')) return 'assets/klikindomaret.png';
    if (t.contains('blibli')) return 'assets/blibli.png';
    if (t.contains('bibit')) return 'assets/bibit.jpeg';
    if (t.contains('ajaib')) return 'assets/ajaib.png';
    if (t.contains('pluang')) return 'assets/pluang.png';
    if (t.contains('mifx')) return 'assets/mifx.png';
    if (t.contains('stockbit')) return 'assets/stockbit.png';
    if (t.contains('kredivo')) return 'assets/kredivo.png';
    if (t.contains('akulaku')) return 'assets/akulaku.jpeg';
    if (t.contains('linkaja')) return 'assets/linkaja.png';
    if (t.contains('easycash')) return 'assets/easycash.png';
    if (t.contains('fifgroup')) return 'assets/fifgroup.png';
    if (t.contains('pegadaian')) return 'assets/pegadaian.png';
    return null;
  }

  static Widget getBrandIcon(
    String text, {
    double size = 48,
    bool isExpense = true,
  }) {
    final assetPath = getAssetPath(text);

    if (assetPath != null) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.2),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.account_balance_wallet, size: size * 0.5),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.25),
      decoration: BoxDecoration(
        color: !isExpense
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        !isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        color: !isExpense ? Colors.green : Colors.red,
        size: size * 0.5,
      ),
    );
  }
}
