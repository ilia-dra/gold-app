import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const GoldIntelApp());
}

class GoldIntelApp extends StatelessWidget {
  const GoldIntelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دیده‌بان طلا و ارز',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        cardColor: const Color(0xFF161B22),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFF00E676),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String baseUrl = "https://worker-production-6eb2.up.railway.app";
  bool isLoading = true;
  Map<String, dynamic> prices = {};
  Map<String, dynamic> latestReport = {};
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final priceRes = await http.get(Uri.parse('$baseUrl/api/prices')).timeout(const Duration(seconds: 15));
      final reportRes = await http.get(Uri.parse('$baseUrl/api/latest')).timeout(const Duration(seconds: 15));

      if (priceRes.statusCode == 200 && reportRes.statusCode == 200) {
        setState(() {
          prices = json.decode(utf8.decode(priceRes.bodyBytes));
          latestReport = json.decode(utf8.decode(reportRes.bodyBytes));
          isLoading = false;
        });
      } else {
        throw Exception("خطا در دریافت اطلاعات");
      }
    } catch (e) {
      setState(() {
        errorMessage = "عدم برقراری ارتباط با سرور. لطفاً اتصال اینترنت را چک کنید.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF161B22),
          elevation: 0,
          title: const Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text(
                'Goldbotop Intel',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
              onPressed: fetchData,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: fetchData,
          color: const Color(0xFFFFD700),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(errorMessage, style: const TextStyle(color: Colors.redAccent)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                            onPressed: fetchData,
                            child: const Text('تلاش مجدد', style: TextStyle(color: Colors.black)),
                          )
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSectionHeader('📊 تابلوی زنده قیمت‌ها', prices['updated_at']?.toString() ?? ''),
                        const SizedBox(height: 12),
                        _buildPriceGrid(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('🧠 آخرین تحلیل هوشمند و تارگت‌ها', latestReport['last_updated']?.toString() ?? ''),
                        const SizedBox(height: 12),
                        _buildAnalysisCard(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPriceGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _priceItem('دلار آزاد', prices['dollar']?.toString() ?? '---', 'تومان', Colors.greenAccent),
        _priceItem('انس جهانی طلا', prices['ons_gold']?.toString() ?? '---', 'دلار', const Color(0xFFFFD700)),
        _priceItem('طلای ۱۸ عیار', prices['geram18']?.toString() ?? '---', 'تومان', const Color(0xFFFFD700)),
        _priceItem('مظنه آب‌شده', prices['mesghal']?.toString() ?? '---', 'تومان', const Color(0xFFFFD700)),
        _priceItem('سکه امامی', prices['sekeh']?.toString() ?? '---', 'تومان', Colors.amber),
        _priceItem('گرم نقره ۹۹۹', prices['silver_gram']?.toString() ?? '---', 'تومان', Colors.blueGrey),
        _priceItem('انس جهانی نقره', prices['ons_silver']?.toString() ?? '---', 'دلار', Colors.blueGrey),
      ],
    );
  }

  Widget _priceItem(String title, String value, String unit, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard() {
    final text = latestReport['analysis_text']?.toString() ?? 'تحلیلی در دسترس نیست.';
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.8, color: Colors.white),
      ),
    );
  }
}
