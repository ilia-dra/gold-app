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
      title: 'Goldbotop Intel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D12),
        cardColor: const Color(0xFF131922),
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
  Map<String, dynamic> pricesData = {};
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
      final pRes = await http.get(Uri.parse('$baseUrl/api/prices')).timeout(const Duration(seconds: 15));
      final rRes = await http.get(Uri.parse('$baseUrl/api/latest')).timeout(const Duration(seconds: 15));

      if (pRes.statusCode == 200 && rRes.statusCode == 200) {
        setState(() {
          pricesData = json.decode(utf8.decode(pRes.bodyBytes));
          latestReport = json.decode(utf8.decode(rRes.bodyBytes));
          isLoading = false;
        });
      } else {
        throw Exception("خطا در ارتباط با سرور");
      }
    } catch (e) {
      setState(() {
        errorMessage = "خطا در اتصال به سرور. اینترنت گوشی را بررسی کنید.";
        isLoading = false;
      });
    }
  }

  IconData _getAssetIcon(String key) {
    switch (key) {
      case "dollar":
        return Icons.attach_money_rounded;
      case "ons_gold":
        return Icons.monetization_on_rounded;
      case "geram18":
        return Icons.auto_awesome_rounded;
      case "mesghal":
        return Icons.layers_rounded;
      case "sekeh":
        return Icons.album_rounded;
      case "silver_gram":
        return Icons.adjust_rounded;
      case "ons_silver":
        return Icons.brightness_medium_rounded;
      default:
        return Icons.show_chart_rounded;
    }
  }

  Color _getAssetColor(String key) {
    switch (key) {
      case "dollar":
        return const Color(0xFF00E676);
      case "ons_gold":
      case "geram18":
      case "mesghal":
        return const Color(0xFFFFD700);
      case "sekeh":
        return const Color(0xFFFFA000);
      case "silver_gram":
      case "ons_silver":
        return const Color(0xFF90CAF9);
      default:
        return Colors.white;
    }
  }

  // پنل کشویی نمایش جزئیات، چارت و تاریخچه هنگام کلیک
  void _showAssetDetailSheet(String key, Map<String, dynamic> item) {
    final history = item['history'] as List<dynamic>? ?? [];
    final accentColor = _getAssetColor(key);
    final isTradingView = (item['tv_symbol'] as String? ?? "").isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131922),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),

                // هدر نماد با آیکون بزرگ و بج
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getAssetIcon(key), color: accentColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['symbol'] ?? '',
                            style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item['current_price']} ${item['unit']}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          item['change'] ?? '۰.۰٪',
                          style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(color: Colors.white10, height: 28),

                // سقف و کف قیمت روز
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🔻 کمترین قیمت امروز', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text('${item['low']} ${item['unit']}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🔺 بیشترین قیمت امروز', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text('${item['high']} ${item['unit']}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // نمودار روند خطی نئونی
                const Text('📈 نمودار روند نوسان:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 90,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: CustomPaint(
                    painter: MiniChartPainter(
                      data: history.map((e) => (e['raw'] as num? ?? 100).toDouble()).toList(),
                      lineColor: accentColor,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // سابقه تغییرات زمانی
                const Text('🕒 سابقه تغییرات ساعات و روزهای قبل:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (ctx, idx) {
                      final h = history.reversed.toList()[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(h['time']?.toString() ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            Text('${h['price']} ${item['unit']}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                if (isTradingView) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2962FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2962FF).withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.show_chart_rounded, color: Color(0xFF2962FF), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'نماد جهانی در TradingView: ${item['tv_symbol']}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> assets = pricesData['assets'] ?? {};
    final structured = latestReport['structured'] ?? {};

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF131922),
          elevation: 0,
          title: const Row(
            children: [
              Icon(Icons.shield_rounded, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text('Goldbotop Intel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('📊 تابلوی زنده بازار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(pricesData['updated_at']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildAssetGrid(assets),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('🧠 تحلیل هوشمند اخبار و تارگت‌ها', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(latestReport['last_updated']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildNewsCard(structured),
                      ],
                    ),
        ),
      ),
    );
  }

  // تابلوی قیمت‌ها با نمادهای گرافیکی و بج پررنگ
  Widget _buildAssetGrid(Map<String, dynamic> assets) {
    if (assets.isEmpty) {
      return const Center(child: Text('درحال بارگذاری نرخ‌ها...', style: TextStyle(color: Colors.grey)));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.25,
      ),
      itemCount: assets.length,
      itemBuilder: (ctx, idx) {
        final key = assets.keys.toList()[idx];
        final item = assets[key];
        final accentColor = _getAssetColor(key);

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showAssetDetailSheet(key, item),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF131922),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // آیکون اختصاصی و نماد دارایی
                    Row(
                      children: [
                        Icon(_getAssetIcon(key), color: accentColor, size: 18),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: accentColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            item['symbol'] ?? '',
                            style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.touch_app_outlined, size: 14, color: Colors.grey),
                  ],
                ),
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['current_price'] ?? '---',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(item['unit'] ?? '', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                    Text(
                      item['change'] ?? '۰.۰٪',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00E676)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // کارت تحلیل با تیتر بولد، بج و قابلیت باز شدن انیمیشنی
  Widget _buildNewsCard(Map<String, dynamic> n) {
    final title = n['title'] ?? 'گزارش تحلیلی بازار';
    final importance = n['importance'] ?? '🟡 متوسط';
    final affected = n['affected'] ?? '#طلا #دلار';
    final direction = n['direction'] ?? '⚪️ نوسانی';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          collapsedIconColor: const Color(0xFFFFD700),
          iconColor: const Color(0xFFFFD700),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(importance, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    affected,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          children: [
            const Divider(color: Colors.white10, height: 20),
            _infoRow('🌐 منبع انتشار:', n['source'] ?? '---'),
            const SizedBox(height: 6),
            _infoRow('⏰ زمان و ماهیت:', '${n['timing'] ?? ''} (${n['exact_time'] ?? ''})'),
            const SizedBox(height: 6),
            _infoRow('🧭 جهت حرکت:', direction),
            const SizedBox(height: 12),
            const Text('📝 تحلیل اثر اقتصادی:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              n['economic_analysis'] ?? '---',
              style: const TextStyle(fontSize: 13, height: 1.7, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text('🎯 تارگت و پیش‌بینی قیمت:', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                n['target'] ?? '---',
                style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// رسم خودکار نمودار خطی نوسانات
class MiniChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  MiniChartPainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalized = (data[i] - minVal) / range;
      final y = size.height - (normalized * (size.height - 16)) - 8;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
