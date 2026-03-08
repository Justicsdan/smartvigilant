import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import '../utils/vigilant_constants.dart';
import '../utils/vigilant_theme.dart';
import '../widgets/vigilant_alert_card.dart';
import 'vigilant_camera.dart';
import 'vigilant_alerts.dart';
import 'vigilant_insights.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> systemStatus = {
    "status": "secure",
    "threat_level": "low",
    "devices_online": 4,
    "threats_today": 0,
    "last_scan": "just now"
  };

  List<Map<String, dynamic>> recentAlerts = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    // In production: fetch from API
    // final status = await apiClient.dio.get("/system/status");
    // final alerts = await apiClient.dio.get("/alerts/recent?limit=5");

    // Simulated data for now
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      recentAlerts = [
        {
          "title": "Motion Detected",
          "message": "Person in backyard — 5 minutes ago",
          "severity": "medium",
          "icon": Icons.motion_photos_auto,
          "color": vigilantWarning,
        },
        {
          "title": "All Clear",
          "message": "No threats in the last hour",
          "severity": "low",
          "icon": Icons.check_circle,
          "color": vigilantSuccess,
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vigilantBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: vigilantAccent))
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                color: vigilantAccent,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "SmartVigilant",
                          style: GoogleFonts.orbitron(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: vigilantAccent, size: 32),
                          onPressed: _loadDashboardData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "by Dutycall",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    // Main Status Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [vigilantPrimaryDark, vigilantPrimary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            systemStatus["status"] == "secure" ? Icons.shield : Icons.warning_amber_rounded,
                            color: vigilantSuccess,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "System Secure",
                            style: GoogleFonts.orbitron(fontSize: 36, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "All systems nominal — your guardian is active",
                            style: const TextStyle(fontSize: 18, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Quick Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statCard("Devices Online", "${systemStatus["devices_online"]}", Icons.devices, vigilantAccent),
                        _statCard("Threats Today", "${systemStatus["threats_today"]}", Icons.security, vigilantSuccess),
                        _statCard("Last Scan", systemStatus["last_scan"], Icons.scanner, Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Recent Alerts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Alerts",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VigilantAlerts()),
                          ),
                          child: const Text("View all", style: TextStyle(color: vigilantAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    recentAlerts.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: vigilantCard,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle, size: 80, color: vigilantSuccess),
                                const SizedBox(height: 20),
                                Text(
                                  "All Clear",
                                  style: GoogleFonts.orbitron(fontSize: 28, color: vigilantSuccess),
                                ),
                                const Text(
                                  "No threats detected — your home is protected",
                                  style: TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: recentAlerts
                                .map((alert) => VigilantAlertCard(alert: alert))
                                .toList(),
                          ),
                    const SizedBox(height: 40),

                    // Quick Actions
                    const Text(
                      "Quick Actions",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _quickActionButton("Live View", Icons.camera_alt, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VigilantCamera()),
                          );
                        }),
                        _quickActionButton("Panic", Icons.warning_amber_rounded, () {
                          Vibration.vibrate(duration: 1000);
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: vigilantCard,
                              title: Text("PANIC ACTIVATED", style: GoogleFonts.orbitron(color: vigilantDanger)),
                              content: const Text("Emergency services and trusted contacts notified"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
                              ],
                            ),
                          );
                        }, color: vigilantDanger),
                        _quickActionButton("Insights", Icons.bar_chart, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VigilantInsights()),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 60),

                    // Footer
                    Center(
                      child: Text(
                        "© 2026 Dutycall — SmartVigilant\nDanladi Heman Shagatpo",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.28,
      decoration: BoxDecoration(
        color: vigilantCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton(String label, IconData icon, VoidCallback onPressed, {Color? color}) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: color ?? vigilantAccent,
          onPressed: onPressed,
          child: Icon(icon, size: 36),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
