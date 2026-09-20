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
        throw Exception("خطا در پاسخ");
      }
    } catch (e) {
      setState(() {
        errorMessage = "خطا در اتصال به سرور. اینترنت را بررسی کنید.";
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
        builder: (ctx) => NativeCandleChartScreen(
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
                      'مشاهده چارت کندل‌استیک و تحلیل تکنیکال',
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
              tooltip: 'چارت کندل‌استیک',
              onPressed: () {
                final goldData = assets['ons_gold'] != null
                    ? Map<String, dynamic>.from(assets['ons_gold'])
                    : {"name": "انس جهانی طلا", "symbol": "XAU / USD", "unit": "دلار", "current_price": "---", "low": "---", "high": "---", "change": "۰.۰٪"};
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

// مدل داده‌های کندل
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

// صفحه چارت کندل‌استیک تعاملی و بومی
class NativeCandleChartScreen extends StatefulWidget {
  final String initialKey;
  final Map<String, dynamic> initialAsset;
  final String baseUrl;

  const NativeCandleChartScreen({super.key, required this.initialKey, required this.initialAsset, required this.baseUrl});

  @override
  State<NativeCandleChartScreen> createState() => _NativeCandleChartScreenState();
}

class _NativeCandleChartScreenState extends State<NativeCandleChartScreen> {
  late String currentKey;
  bool isLoading = true;
  List<CandleModel> candles = [];
  int? touchedIndex;

  final Map<String, String> symbolNames = {
    "ons_gold": "انس طلا",
    "geram18": "طلای ۱۸ عیار",
    "mesghal": "مظنه آبشده",
    "sekeh": "سکه امامی",
    "dollar": "دلار آزاد",
    "silver_gram": "نقره ۹۹۹",
    "ons_silver": "انس نقره",
  };

  @override
  void initState() {
    super.initState();
    currentKey = widget.initialKey;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    fetchCandles(currentKey);
  }

  Future<void> fetchCandles(String key) async {
    setState(() {
      isLoading = true;
      touchedIndex = null;
    });

    try {
      final res = await http.get(Uri.parse('${widget.baseUrl}/api/history/$key')).timeout(const Duration(seconds: 10));
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

    // داده‌های پیش‌فرض در صورت آفلاین بودن
    _generateFallbackCandles(key);
  }

  void _generateFallbackCandles(String key) {
    final now = DateTime.now();
    double base = key == "ons_gold" ? 2750.0 : (key == "dollar" ? 69000.0 : 4500000.0);
    List<CandleModel> list = [];
    double curr = base * 0.95;
    final diffs = [-0.012, 0.008, 0.015, -0.005, 0.018, -0.009, 0.011, 0.004, -0.007, 0.014];

    for (int i = 20; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final v = diffs[i % diffs.length];
      final op = curr;
      final cl = curr * (1 + v);
      final hi = [op, cl].reduce((a, b) => a > b ? a : b) * 1.006;
      final lo = [op, cl].reduce((a, b) => a < b ? a : b) * 0.994;
      list.add(CandleModel(time: "${d.month}/${d.day}", open: op, high: hi, low: lo, close: cl));
      curr = cl;
    }

    setState(() {
      candles = list;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCandle = (touchedIndex != null && touchedIndex! < candles.length)
        ? candles[touchedIndex!]
        : (candles.isNotEmpty ? candles.last : null);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF131922),
          elevation: 0,
          title: Text('${symbolNames[currentKey] ?? currentKey} - چارت شمعی', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.screen_rotation_rounded, color: Color(0xFFFFD700)),
              tooltip: 'چرخش صفحه',
              onPressed: () {
                final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                if (isLandscape) {
                  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                } else {
                  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // هدر انتخاب سریع نمادها
            Container(
              height: 44,
              color: const Color(0xFF131922),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                children: symbolNames.entries.map((e) {
                  final isSel = currentKey == e.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.black : Colors.white70)),
                      selected: isSel,
                      selectedColor: const Color(0xFFFFD700),
                      backgroundColor: const Color(0xFF1E293B),
                      onSelected: (_) {
                        setState(() => currentKey = e.key);
                        fetchCandles(e.key);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // کادر اطلاعات هوشمند کندل انتخابی (OHLC HUD)
            if (activeCandle != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF0F151E),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('📅 تاریخ: ${activeCandle.time}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(
                          '${activeCandle.changePct >= 0 ? "+" : ""}${activeCandle.changePct.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: activeCandle.isBullish ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _hudItem('باز:', activeCandle.open),
                        _hudItem('بیشترین:', activeCandle.high),
                        _hudItem('کمترین:', activeCandle.low),
                        _hudItem('پایانی:', activeCandle.close, isBold: true),
                      ],
                    ),
                  ],
                ),
              ),

            // بستر ترسیم چارت کندلی
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                  : LayoutBuilder(
                      builder: (ctx, constraints) {
                        return GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            final dx = details.localPosition.dx;
                            final step = constraints.maxWidth / candles.length;
                            final idx = (dx / step).clamp(0, candles.length - 1).toInt();
                            setState(() => touchedIndex = idx);
                          },
                          onTapDown: (details) {
                            final dx = details.localPosition.dx;
                            final step = constraints.maxWidth / candles.length;
                            final idx = (dx / step).clamp(0, candles.length - 1).toInt();
                            setState(() => touchedIndex = idx);
                          },
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: CandlestickChartPainter(
                              candles: candles,
                              selectedIndex: touchedIndex,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hudItem(String label, double val, {bool isBold = false}) {
    final str = val > 1000 ? val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') : val.toStringAsFixed(2);
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(width: 2),
        Text(str, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

// کلاس نقاش حرفه‌ای کندل‌استیک ژاپنی با خطوط راهنما و Crosshair
class CandlestickChartPainter extends CustomPainter {
  final List<CandleModel> candles;
  final int? selectedIndex;

  CandlestickChartPainter({required this.candles, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final double minPrice = candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final double maxPrice = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final double priceRange = (maxPrice - minPrice) == 0 ? 1.0 : (maxPrice - minPrice);

    final double padTop = 20.0;
    final double padBottom = 25.0;
    final double padRight = 60.0;
    final double chartHeight = size.height - padTop - padBottom;
    final double chartWidth = size.width - padRight;

    final stepX = chartWidth / candles.length;

    // خطوط افقی شبکه قیمت
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = padTop + (chartHeight / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      final p = maxPrice - (priceRange / 4) * i;
      final textSpan = TextSpan(
        text: p > 1000 ? p.toInt().toString() : p.toStringAsFixed(2),
        style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 9),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(chartWidth + 6, y - 6));
    }

    // ترسیم هر کندل شمعی
    final greenPaint = Paint()..color = const Color(0xFF00E676)..style = PaintingStyle.fill;
    final redPaint = Paint()..color = const Color(0xFFFF5252)..style = PaintingStyle.fill;

    final wickPaintGreen = Paint()..color = const Color(0xFF00E676)..strokeWidth = 1.5;
    final wickPaintRed = Paint()..color = const Color(0xFFFF5252)..strokeWidth = 1.5;

    for (int i = 0; i < candles.length; i++) {
      final c = candles[i];
      final x = i * stepX + (stepX / 2);

      final yHigh = padTop + chartHeight - ((c.high - minPrice) / priceRange * chartHeight);
      final yLow = padTop + chartHeight - ((c.low - minPrice) / priceRange * chartHeight);
      final yOpen = padTop + chartHeight - ((c.open - minPrice) / priceRange * chartHeight);
      final yClose = padTop + chartHeight - ((c.close - minPrice) / priceRange * chartHeight);

      final isBull = c.isBullish;
      final wickPaint = isBull ? wickPaintGreen : wickPaintRed;
      final bodyPaint = isBull ? greenPaint : redPaint;

      // سایه کندل (Wick)
      canvas.drawLine(Offset(x, yHigh), Offset(x, yLow), wickPaint);

      // بدنه کندل
      final top = isBull ? yClose : yOpen;
      final bottom = isBull ? yOpen : yClose;
      final bodyHeight = (bottom - top).abs() < 2 ? 2.0 : (bottom - top).abs();
      final bodyWidth = (stepX * 0.65).clamp(3.0, 16.0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, top + bodyHeight / 2), width: bodyWidth, height: bodyHeight),
          const Radius.circular(1.5),
        ),
        bodyPaint,
      );
    }

    // خط نشانگر متقاطع لمسی (Crosshair)
    if (selectedIndex != null && selectedIndex! < candles.length) {
      final cx = selectedIndex! * stepX + (stepX / 2);
      final candle = candles[selectedIndex!];
      final cy = padTop + chartHeight - ((candle.close - minPrice) / priceRange * chartHeight);

      final crossPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.6)
        ..strokeWidth = 1.0;

      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height - padBottom), crossPaint);
      canvas.drawLine(Offset(0, cy), Offset(chartWidth, cy), crossPaint);

      final dotPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(Offset(cx, cy), 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CandlestickChartPainter oldDelegate) => true;
}
