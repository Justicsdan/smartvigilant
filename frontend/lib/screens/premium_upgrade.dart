// premium_upgrade.dart - Premium subscription upgrade screen
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/vigilant_theme.dart';

class PremiumUpgrade extends StatefulWidget {
  @override
  _PremiumUpgradeState createState() => _PremiumUpgradeState();
}

class _PremiumUpgradeState extends State<PremiumUpgrade> {
  bool _loading = false;

  Future<void> _startCheckout(String planId) async {
    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/v1/premium/create-checkout-session'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_JWT_TOKEN_HERE", // Get from secure storage
        },
        body: jsonEncode({"plan_id": planId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['checkout_url'];
        // In real app: use url_launcher or webview to open Stripe
        launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to start checkout")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Go Premium")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              "Unlock SmartVigilant Premium",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),

            _PlanCard(
              title: "SmartVigilant Plus",
              price: "\$9.99/month",
              features: [
                "Unlimited encrypted cloud backup",
                "Advanced AI threat detection",
                "Priority alerts & support",
                "Ad-free experience",
              ],
              color: vigilantAccent,
              onTap: () => _startCheckout("plus_monthly"),
              loading: _loading,
            ),
            SizedBox(height: 24),

            _PlanCard(
              title: "Family Pro",
              price: "\$19.99/month",
              features: [
                "Everything in Plus",
                "24/7 human monitoring team",
                "Full family dashboard",
                "Emergency response coordination",
                "Liability protection partnership",
              ],
              color: Colors.amber,
              isRecommended: true,
              onTap: () => _startCheckout("family_monthly"),
              loading: _loading,
            ),
            SizedBox(height: 40),

            Text(
              "Free version remains fully functional forever.\nPremium adds cloud-powered superpowers.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final Color color;
  final bool isRecommended;
  final VoidCallback onTap;
  final bool loading;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.features,
    required this.color,
    this.isRecommended = false,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isRecommended ? 12 : 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isRecommended ? Border.all(color: color, width: 3) : null,
        ),
        child: Column(
          children: [
            if (isRecommended)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                child: Text("RECOMMENDED", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(price, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)),
            SizedBox(height: 24),
            ...features.map((f) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [Icon(Icons.check_circle, color: vigilantAccent, size: 20), SizedBox(width: 8), Text(f)]),
            )),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: loading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: loading
                  ? CircularProgressIndicator(color: Colors.black)
                  : Text("Upgrade Now", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
