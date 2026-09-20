import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final String baseUrl = "https://worker-production-6eb2.up.railway.app";
  bool isLoading = true;
  Map<String, dynamic> pricesData = {};
  Map<String, dynamic> news3DaysData = {};
  String errorMessage = "";
  Timer? _liveAutoRefreshTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchData();

    // به‌روزرسانی لایو هر ۱۰ ثانیه بدون پرش صفحه
    _liveAutoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchData(isSilent: true);
    });
  }

  @override
  void dispose() {
    _liveAutoRefreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchData({bool isSilent = false}) async {
    if (!isSilent) {
      setState(() {
        isLoading = true;
        errorMessage = "";
      });
    }

    try {
      final pRes = await http.get(Uri.parse('$baseUrl/api/prices')).timeout(const Duration(seconds: 8));
      final nRes = await http.get(Uri.parse('$baseUrl/api/news-3days')).timeout(const Duration(seconds: 8));

      if (pRes.statusCode == 200 && nRes.statusCode == 200) {
        if (mounted) {
          setState(() {
            pricesData = json.decode(utf8.decode(pRes.bodyBytes));
            news3DaysData = json.decode(utf8.decode(nRes.bodyBytes));
            isLoading = false;
          });
        }
      } else {
        throw Exception("خطا در پاسخ سرور");
      }
    } catch (e) {
      if (!isSilent && mounted) {
        setState(() {
          errorMessage = "خطا در اتصال به سرور. اینترنت گوشی را بررسی کنید.";
          isLoading = false;
        });
      }
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

  void _showAssetSheet(String key, Map<String, dynamic> item) {
    final accentColor = _getAssetColor(key);
    final linkType = item['link_type']?.toString() ?? 'tgju';
    final chartUrl = item['chart_url']?.toString() ?? 'https://www.tgju.org/';
    final isTradingView = linkType == 'tradingview';
    final change = item['change']?.toString() ?? '۰.۰٪';
    final isNegative = change.contains('-');

    showModalBottomSheet(
      context: context,
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
                        Text(item['name']?.toString() ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(item['symbol']?.toString() ?? '', style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item['current_price']} ${item['unit']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(
                          change,
                          style: TextStyle(
                            color: isNegative ? const Color(0xFFF23645) : const Color(0xFF00E676),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 26),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🔻 کمترین قیمت امروز', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('${item['low']} ${item['unit']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🔺 بیشترین قیمت امروز', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('${item['high']} ${item['unit']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isTradingView ? const Color(0xFF2962FF).withOpacity(0.12) : const Color(0xFFFF9800).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isTradingView ? const Color(0xFF2962FF).withOpacity(0.3) : const Color(0xFFFF9800).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(isTradingView ? Icons.candlestick_chart_rounded : Icons.insights_rounded, 
                           color: isTradingView ? const Color(0xFF2962FF) : const Color(0xFFFF9800)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isTradingView ? 'مرجع جهانی: TradingView ($chartUrl)' : 'مرجع رسمی داخلی: TGJU ($chartUrl)',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> assets = pricesData['assets'] != null
        ? Map<String, dynamic>.from(pricesData['assets'])
        : {};

    final List<dynamic> todayList = news3DaysData['today'] ?? [];
    final List<dynamic> yesterdayList = news3DaysData['yesterday'] ?? [];
    final List<dynamic> twoDaysAgoList = news3DaysData['two_days_ago'] ?? [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF131922),
          elevation: 0,
          title: Row(
            children: [
              const Icon(Icons.shield_rounded, color: Color(0xFFFFD700)),
              const SizedBox(width: 8),
              const Text('Goldbotop Intel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF00E676).withOpacity(0.4)),
                ),
                child: const Text('🟢 زنده', style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
              tooltip: 'به‌روزرسانی',
              onPressed: () => fetchData(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => fetchData(),
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
                            onPressed: () => fetchData(),
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
                            const Text('📊 تابلوی نرخ‌های لحظه‌ای', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(pricesData['updated_at']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildAssetGrid(assets),
                        const SizedBox(height: 24),

                        // هدر بخش اخبار با تب‌های سه‌روزه
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD700), size: 20),
                            SizedBox(width: 8),
                            Text('پایش هوشمند اخبار موثر بر بازار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E222D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: const Color(0xFF2962FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white60,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            tabs: const [
                              Tab(text: 'امروز'),
                              Tab(text: 'روز قبل'),
                              Tab(text: '۲ روز قبل'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // نمایش محتوای تب فعال
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            if (_tabController.index == 0) {
                              return _buildNewsList(todayList, "هنوز تحلیلی برای امروز ثبت نشده است.");
                            } else if (_tabController.index == 1) {
                              return _buildNewsList(yesterdayList, "تحلیلی برای روز قبل در آرشیو موجود نیست.");
                            } else {
                              return _buildNewsList(twoDaysAgoList, "تحلیلی برای ۲ روز قبل در آرشیو موجود نیست.");
                            }
                          },
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

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
        childAspectRatio: 1.28,
      ),
      itemCount: assets.length,
      itemBuilder: (ctx, idx) {
        final key = assets.keys.toList()[idx];
        final item = Map<String, dynamic>.from(assets[key]);
        final accentColor = _getAssetColor(key);
        final change = item['change']?.toString() ?? '۰.۰٪';
        final isNegative = change.contains('-');

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showAssetSheet(key, item),
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
                            item['symbol']?.toString() ?? '',
                            style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.open_in_new_rounded, size: 14, color: Colors.grey),
                  ],
                ),
                Text(item['name']?.toString() ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['current_price']?.toString() ?? '---',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(item['unit']?.toString() ?? '', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isNegative ? const Color(0xFFF23645) : const Color(0xFF00E676)).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        change,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isNegative ? const Color(0xFFF23645) : const Color(0xFF00E676),
                        ),
                      ),
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

  Widget _buildNewsList(List<dynamic> list, String emptyMessage) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.center,
        child: Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, idx) {
        final item = list[idx];
        final structured = item['structured'] ?? {};
        final timeStr = item['timestamp']?.toString() ?? '';
        return _buildNewsCard(structured, timeStr);
      },
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> n, String timestamp) {
    final title = n['title']?.toString() ?? 'گزارش تحلیلی بازار';
    final importance = n['importance']?.toString() ?? '🟡 متوسط';
    final affected = n['affected']?.toString() ?? '#طلا #دلار';
    final direction = n['direction']?.toString() ?? '⚪️ نوسانی';

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
                Text(timestamp.split(' - ').last, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          children: [
            const Divider(color: Colors.white10, height: 20),
            _infoRow('🌐 منبع انتشار:', n['source']?.toString() ?? '---'),
            const SizedBox(height: 6),
            _infoRow('⏰ زمان رویداد:', '${n['timing'] ?? ''} (${n['exact_time'] ?? ''})'),
            const SizedBox(height: 6),
            _infoRow('🧭 جهت حرکت:', direction),
            const SizedBox(height: 12),
            const Text('📝 تحلیل اثر اقتصادی:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(n['economic_analysis'] ?? '---', style: const TextStyle(fontSize: 13, height: 1.7, color: Colors.white)),
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
              child: Text(n['target'] ?? '---', style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.white)),
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
