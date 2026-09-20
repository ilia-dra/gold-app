import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _openCandleChart(String key, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ProfessionalTradingChart(
          initialKey: key,
          initialAsset: item,
          baseUrl: baseUrl,
        ),
      ),
    );
  }

  void _showAssetSheet(String key, Map<String, dynamic> item) {
    final accentColor = _getAssetColor(key);

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
                        Text(item['change']?.toString() ?? '۰.۰٪', style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)),
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
                            const Text('🔻 کف قیمت امروز', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                            const Text('🔺 سقف قیمت امروز', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('${item['high']} ${item['unit']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.candlestick_chart_rounded, color: Colors.white),
                    label: const Text(
                      'ورود به میزکار تحلیلی و چارت کندلی',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openCandleChart(key, item);
                    },
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
    final Map<String, dynamic> structured = latestReport['structured'] != null
        ? Map<String, dynamic>.from(latestReport['structured'])
        : {};

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
              icon: const Icon(Icons.candlestick_chart_rounded, color: Color(0xFF2962FF)),
              tooltip: 'چارت طلا',
              onPressed: () {
                final goldData = assets['ons_gold'] != null
                    ? Map<String, dynamic>.from(assets['ons_gold'])
                    : {"name": "انس جهانی طلا", "symbol": "XAU / USD", "unit": "دلار", "current_price": "4,383.45", "low": "4,370.00", "high": "4,395.00", "change": "۰.۰٪"};
                _openCandleChart("ons_gold", goldData);
              },
            ),
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
                    const Icon(Icons.touch_app_outlined, size: 14, color: Colors.grey),
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
                    Text(
                      item['change']?.toString() ?? '۰.۰٪',
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

  Widget _buildNewsCard(Map<String, dynamic> n) {
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
              ],
            ),
          ),
          children: [
            const Divider(color: Colors.white10, height: 20),
            _infoRow('🌐 منبع انتشار:', n['source']?.toString() ?? '---'),
            const SizedBox(height: 6),
            _infoRow('⏰ زمان و ماهیت:', '${n['timing'] ?? ''} (${n['exact_time'] ?? ''})'),
            const SizedBox(height: 6),
            _infoRow('🧭 جهت حرکت:', direction),
            const SizedBox(height: 12),
            const Text('📝 تحلیل اثر اقتصادی:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(n['economic_analysis']?.toString() ?? '---', style: const TextStyle(fontSize: 13, height: 1.7, color: Colors.white)),
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
              child: Text(n['target']?.toString() ?? '---', style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.white)),
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

// مدل کندل‌استیک
class CandleModel {
  final String time;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleModel({required this.time, required this.open, required this.high, required this.low, required this.close});

  bool get isBullish => close >= open;
  double get changePct => open > 0 ? ((close - open) / open) * 100 : 0.0;
}

// میزکار تکنیکال تعاملی با قابلیت جابه‌جایی، زوم و تایم‌فریم
class ProfessionalTradingChart extends StatefulWidget {
  final String initialKey;
  final Map<String, dynamic> initialAsset;
  final String baseUrl;

  const ProfessionalTradingChart({super.key, required this.initialKey, required this.initialAsset, required this.baseUrl});

  @override
  State<ProfessionalTradingChart> createState() => _ProfessionalTradingChartState();
}

class _ProfessionalTradingChartState extends State<ProfessionalTradingChart> {
  late String currentKey;
  String selectedTf = "1D";
  bool isLoading = true;
  List<CandleModel> candles = [];

  // پارامترهای کنترل حرکت و زوم چارت
  double _scrollOffset = 0.0;
  double _candleWidth = 14.0;
  double _baseCandleWidth = 14.0;
  double _startScrollOffset = 0.0;
  Offset? _crosshairPoint;

  final Map<String, String> symbolNames = {
    "ons_gold": "انس طلا",
    "geram18": "طلای ۱۸ عیار",
    "mesghal": "مظنه آبشده",
    "sekeh": "سکه امامی",
    "dollar": "دلار آزاد",
    "silver_gram": "نقره ۹۹۹",
    "ons_silver": "انس نقره",
  };

  final List<String> timeframes = ["15M", "1H", "4H", "1D", "1W"];

  @override
  void initState() {
    super.initState();
    currentKey = widget.initialKey;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    fetchCandles(currentKey, selectedTf);
  }

  Future<void> fetchCandles(String key, String tf) async {
    setState(() {
      isLoading = true;
      _crosshairPoint = null;
      _scrollOffset = 0.0;
    });

    try {
      final res = await http.get(Uri.parse('${widget.baseUrl}/api/history/$key?tf=$tf')).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final List<dynamic> raw = json.decode(utf8.decode(res.bodyBytes));
        final parsed = raw.map((c) => CandleModel(
          time: c['time'].toString(),
          open: (c['open'] as num).toDouble(),
          high: (c['high'] as num).toDouble(),
          low: (c['low'] as num).toDouble(),
          close: (c['close'] as num).toDouble(),
        )).toList();

        if (parsed.isNotEmpty) {
          setState(() {
            candles = parsed;
            isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CandleModel? focusedCandle;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF131722),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E222D),
          elevation: 0,
          title: Row(
            children: [
              Text(symbolNames[currentKey] ?? currentKey, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF2962FF).withOpacity(0.25), borderRadius: BorderRadius.circular(4)),
                child: Text(selectedTf, style: const TextStyle(color: Color(0xFF2962FF), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.screen_rotation_rounded, color: Color(0xFFFFD700)),
              tooltip: 'چرخش صفحه',
              onPressed: () {
                final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                SystemChrome.setPreferredOrientations([
                  isLandscape ? DeviceOrientation.portraitUp : DeviceOrientation.landscapeLeft,
                ]);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // نوار انتخاب نماد
            Container(
              height: 42,
              color: const Color(0xFF1E222D),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                children: symbolNames.entries.map((e) {
                  final isSel = currentKey == e.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text(e.value, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.black : Colors.white70)),
                      selected: isSel,
                      selectedColor: const Color(0xFFFFD700),
                      backgroundColor: const Color(0xFF131722),
                      onSelected: (_) {
                        setState(() => currentKey = e.key);
                        fetchCandles(e.key, selectedTf);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // نوار ابزار تایم‌فریم‌ها
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF131722),
                border: Border(bottom: BorderSide(color: Color(0xFF2A2E39), width: 1)),
              ),
              child: Row(
                children: [
                  const Text('تایم‌فریم:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(width: 8),
                  ...timeframes.map((tf) {
                    final isSelected = selectedTf == tf;
                    return InkWell(
                      onTap: () {
                        setState(() => selectedTf = tf);
                        fetchCandles(currentKey, tf);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2962FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tf,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const Spacer(),
                  // راهنمای زوم و حرکت
                  const Row(
                    children: [
                      Icon(Icons.pan_tool_alt_rounded, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('درگ برای حرکت / زوم با ۲ انگشت', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),

            // بستر چارت تعاملی
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2962FF)))
                  : LayoutBuilder(
                      builder: (ctx, constraints) {
                        final chartWidth = constraints.maxWidth - 65.0; // فضا برای مقیاس قیمت راست
                        final maxScroll = ((candles.length * _candleWidth) - chartWidth).clamp(0.0, double.infinity);
                        _scrollOffset = _scrollOffset.clamp(0.0, maxScroll);

                        // پیدا کردن کندل زیر نشانگر
                        if (_crosshairPoint != null) {
                          final touchX = _crosshairPoint!.dx;
                          for (int i = 0; i < candles.length; i++) {
                            final x = chartWidth - ((candles.length - 1 - i) * _candleWidth) + _scrollOffset - (_candleWidth / 2);
                            if ((touchX - x).abs() <= _candleWidth / 2) {
                              focusedCandle = candles[i];
                              break;
                            }
                          }
                        }
                        focusedCandle ??= candles.isNotEmpty ? candles.last : null;

                        return Stack(
                          children: [
                            // تشخیص هوشمند حرکات لمسی (Drag & Pinch)
                            GestureDetector(
                              onScaleStart: (details) {
                                if (details.pointerCount == 1) {
                                  _startScrollOffset = _scrollOffset;
                                } else {
                                  _baseCandleWidth = _candleWidth;
                                }
                              },
                              onScaleUpdate: (details) {
                                if (details.pointerCount == 1) {
                                  setState(() {
                                    // حرکت افقی روی چارت به سمت تاریخچه گذشته یا حال
                                    _scrollOffset = (_scrollOffset - details.focalPointDelta.dx).clamp(0.0, maxScroll);
                                  });
                                } else if (details.pointerCount == 2) {
                                  setState(() {
                                    // زوم و کوچک/بزرگ‌نمایی کندل‌ها
                                    _candleWidth = (_baseCandleWidth * details.scale).clamp(5.0, 35.0);
                                  });
                                }
                              },
                              onLongPressStart: (details) => setState(() => _crosshairPoint = details.localPosition),
                              onLongPressMoveUpdate: (details) => setState(() => _crosshairPoint = details.localPosition),
                              onLongPressEnd: (_) => setState(() => _crosshairPoint = null),
                              child: CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: InteractiveCandlePainter(
                                  candles: candles,
                                  candleWidth: _candleWidth,
                                  scrollOffset: _scrollOffset,
                                  crosshairPoint: _crosshairPoint,
                                  isToman: widget.initialAsset['unit'] == 'تومان',
                                ),
                              ),
                            ),

                            // کادر اطلاعات کندل فعال در بالای چارت (HUD)
                            if (focusedCandle != null)
                              Positioned(
                                top: 8,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E222D).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(focusedCandle!.time, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      _hudText('O:', focusedCandle!.open),
                                      _hudText('H:', focusedCandle!.high),
                                      _hudText('L:', focusedCandle!.low),
                                      _hudText('C:', focusedCandle!.close, color: focusedCandle!.isBullish ? const Color(0xFF089981) : const Color(0xFFF23645)),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${focusedCandle!.changePct >= 0 ? "+" : ""}${focusedCandle!.changePct.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          color: focusedCandle!.isBullish ? const Color(0xFF089981) : const Color(0xFFF23645),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // دکمه بازگشت به جدیدترین قیمت در صورت ورق زدن به گذشته
                            if (_scrollOffset > 40)
                              Positioned(
                                bottom: 35,
                                left: 14,
                                child: FloatingActionButton.small(
                                  backgroundColor: const Color(0xFF2962FF),
                                  child: const Icon(Icons.fast_forward_rounded, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _scrollOffset = 0.0;
                                      _crosshairPoint = null;
                                    });
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hudText(String prefix, double val, {Color? color}) {
    final s = val > 1000 ? val.toInt().toString() : val.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text('$prefix $s', style: TextStyle(color: color ?? Colors.white70, fontSize: 10, fontFamily: 'monospace')),
    );
  }
}

// نقاش حرفه‌ای چارت با رندرینگ TradingView و مقیاس قیمت خودکار
class InteractiveCandlePainter extends CustomPainter {
  final List<CandleModel> candles;
  final double candleWidth;
  final double scrollOffset;
  final Offset? crosshairPoint;
  final bool isToman;

  InteractiveCandlePainter({
    required this.candles,
    required this.candleWidth,
    required this.scrollOffset,
    this.crosshairPoint,
    required this.isToman,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final double padTop = 30.0;
    final double padBottom = 26.0;
    final double padRight = 65.0;
    final double chartHeight = size.height - padTop - padBottom;
    final double chartWidth = size.width - padRight;

    // پیدا کردن کندل‌های داخل کادر برای محاسبه سقف و کف پویا
    List<CandleModel> visibleCandles = [];
    for (int i = 0; i < candles.length; i++) {
      final x = chartWidth - ((candles.length - 1 - i) * candleWidth) + scrollOffset - (candleWidth / 2);
      if (x >= -candleWidth && x <= chartWidth + candleWidth) {
        visibleCandles.add(candles[i]);
      }
    }
    if (visibleCandles.isEmpty) visibleCandles = candles;

    double minP = visibleCandles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    double maxP = visibleCandles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    double range = (maxP - minP) == 0 ? 1.0 : (maxP - minP);

    // افزودن حاشیه امنیتی عمودی
    minP -= range * 0.08;
    maxP += range * 0.08;
    range = maxP - minP;

    // خطوط افقی شبکه و برچسب‌های قیمت در ستون سمت راست
    final gridPaint = Paint()..color = const Color(0xFF1E222D)..strokeWidth = 1.0;
    for (int i = 0; i <= 4; i++) {
      final y = padTop + (chartHeight / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      final p = maxP - (range / 4) * i;
      final pStr = isToman ? (p > 1000 ? (p.toInt()).toString() : p.toStringAsFixed(0)) : p.toStringAsFixed(2);
      final tp = TextPainter(
        text: TextSpan(text: pStr, style: const TextStyle(color: Color(0xFF787B86), fontSize: 9, fontFamily: 'monospace')),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(chartWidth + 6, y - 5));
    }

    // قلم‌های کندل‌های صعودی و نزولی به سبک TradingView
    final bullColor = const Color(0xFF089981);
    final bearColor = const Color(0xFFF23645);

    final bullBodyPaint = Paint()..color = bullColor..style = PaintingStyle.fill;
    final bearBodyPaint = Paint()..color = bearColor..style = PaintingStyle.fill;
    final bullWickPaint = Paint()..color = bullColor..strokeWidth = 1.4;
    final bearWickPaint = Paint()..color = bearColor..strokeWidth = 1.4;

    // ترسیم کندل‌ها
    for (int i = 0; i < candles.length; i++) {
      final x = chartWidth - ((candles.length - 1 - i) * candleWidth) + scrollOffset - (candleWidth / 2);
      if (x < -candleWidth || x > chartWidth + candleWidth) continue;

      final c = candles[i];
      final yHigh = padTop + chartHeight - ((c.high - minP) / range * chartHeight);
      final yLow = padTop + chartHeight - ((c.low - minP) / range * chartHeight);
      final yOpen = padTop + chartHeight - ((c.open - minP) / range * chartHeight);
      final yClose = padTop + chartHeight - ((c.close - minP) / range * chartHeight);

      final isBull = c.isBullish;
      canvas.drawLine(Offset(x, yHigh), Offset(x, yLow), isBull ? bullWickPaint : bearWickPaint);

      final top = isBull ? yClose : yOpen;
      final bottom = isBull ? yOpen : yClose;
      final bHeight = (bottom - top).abs() < 1.5 ? 1.5 : (bottom - top).abs();
      final bWidth = (candleWidth * 0.7).clamp(2.5, 24.0);

      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, top + bHeight / 2), width: bWidth, height: bHeight),
        isBull ? bullBodyPaint : bearBodyPaint,
      );

      // برچسب زمان در محور پایین برای برخی کندل‌ها
      if (i % 6 == 0) {
        final dateTp = TextPainter(
          text: TextSpan(text: c.time.split(' ').last, style: const TextStyle(color: Color(0xFF787B86), fontSize: 8)),
          textDirection: TextDirection.ltr,
        )..layout();
        dateTp.paint(canvas, Offset(x - (dateTp.width / 2), size.height - padBottom + 6));
      }
    }

    // خط تراز آخرین قیمت لحظه‌ای (Dashed Price Line)
    final lastC = candles.last;
    final lastY = padTop + chartHeight - ((lastC.close - minP) / range * chartHeight);
    final lastPaint = Paint()..color = lastC.isBullish ? bullColor : bearColor..strokeWidth = 1.0;
    
    // کشیدن خط تراز نقطه‌چین
    double dashX = 0;
    while (dashX < chartWidth) {
      canvas.drawLine(Offset(dashX, lastY), Offset(dashX + 4, lastY), lastPaint);
      dashX += 8;
    }

    // بج آخرین قیمت روی محور عمودی سمت راست
    final lastStr = isToman ? (lastC.close > 1000 ? lastC.close.toInt().toString() : lastC.close.toStringAsFixed(0)) : lastC.close.toStringAsFixed(2);
    final badgeTp = TextPainter(
      text: TextSpan(text: lastStr, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(chartWidth + 2, lastY - 9, badgeTp.width + 8, 18),
      const Radius.circular(4),
    );
    canvas.drawRRect(badgeRect, lastPaint);
    badgeTp.paint(canvas, Offset(chartWidth + 6, lastY - 6));

    // کراس‌هیر لمسی (Crosshair)
    if (crosshairPoint != null) {
      final cx = crosshairPoint!.dx.clamp(0.0, chartWidth);
      final cy = crosshairPoint!.dy.clamp(padTop, padTop + chartHeight);

      final crossPaint = Paint()..color = Colors.white.withOpacity(0.5)..strokeWidth = 1.0;
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height - padBottom), crossPaint);
      canvas.drawLine(Offset(0, cy), Offset(chartWidth, cy), crossPaint);

      // برچسب قیمت نقطه لمس شده روی محور راست
      final touchPrice = maxP - ((cy - padTop) / chartHeight * range);
      final touchStr = isToman ? touchPrice.toInt().toString() : touchPrice.toStringAsFixed(2);
      final touchTp = TextPainter(
        text: TextSpan(text: touchStr, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(chartWidth + 2, cy - 9, touchTp.width + 8, 18), const Radius.circular(4)),
        Paint()..color = const Color(0xFFFFD700),
      );
      touchTp.paint(canvas, Offset(chartWidth + 6, cy - 6));
    }
  }

  @override
  bool shouldRepaint(covariant InteractiveCandlePainter oldDelegate) => true;
}
