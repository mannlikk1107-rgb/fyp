import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class TopUpPage extends StatelessWidget {
  const TopUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Top Up ACoin"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 頂部大圖示
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on_rounded, size: 60, color: Colors.amber),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Get More ACoin",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              "Current Balance: ${userProvider.balance.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),

            // 儲值選項 (Grid View)
            Row(
              children: [
                Expanded(child: _buildPriceCard(context, "10 ACoin", "HK\$ 8.00", Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildPriceCard(context, "100 ACoin", "HK\$ 36.00", Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            // 大額選項
            _buildPriceCard(context, "444 ACoin", "HK\$ 444.00", Colors.purple, isLarge: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, String coins, String price, Color color, {bool isLarge = false}) {
    return GestureDetector(
      onTap: () {
        // MVP 模擬購買成功
        _showSuccessDialog(context, coins);
      },
      child: Container(
        height: isLarge ? 100 : 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: isLarge 
          ? Row( // 橫向佈局 (大卡片)
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(coins, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 4),
                    Text("Best Value", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            )
          : Column( // 縱向佈局 (小卡片)
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, size: 40, color: color),
                const Spacer(),
                Text(coins, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(price, style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500)),
              ],
            ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Purchase Successful"),
        content: Text("You have purchased $amount. (Demo Only - No real money charged)"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }
}
