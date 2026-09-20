import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

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
        throw Exception("خطا در پاسخ سرور");
      }
    } catch (e) {
      setState(() {
        errorMessage = "خطا در اتصال به سرور. لطفاً اینترنت را بررسی کنید.";
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

  void _openInteractiveChart(String key, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AdvancedChartScreen(
          assetKey: key,
          assetInfo: item,
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
                        Text(item['name'] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(item['symbol'] ?? '', style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item['current_price']} ${item['unit']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(item['change'] ?? '۰.۰٪', style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)),
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

                // دکمه ورود به چارت تعاملی تریدینگ‌ویو
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.candlestick_chart_rounded, color: Colors.white),
                    label: Text(
                      item['is_global'] == true ? 'چارت پیشرفته تریدینگ‌ویو' : 'چارت کندل‌استیک TradingView',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openInteractiveChart(key, item);
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
              icon: const Icon(Icons.candlestick_chart_rounded, color: Color(0xFF2962FF)),
              tooltip: 'چارت طلا',
              onPressed: () {
                final goldData = assets['ons_gold'] ?? {"name": "انس جهانی طلا", "symbol": "XAU / USD", "is_global": true, "tv_symbol": "OANDA:XAUUSD", "unit": "دلار"};
                _openInteractiveChart("ons_gold", goldData);
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
        final item = assets[key];
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
                            item['symbol'] ?? '',
                            style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.touch_app_outlined, size: 14, color: Colors.grey),
                  ],
                ),
                Text(item['name'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
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

// صفحه چارت چندمنظوره (Lightweight Charts برای داخلی و TradingView برای جهانی)
class AdvancedChartScreen extends StatefulWidget {
  final String assetKey;
  final Map<String, dynamic> assetInfo;
  final String baseUrl;

  const AdvancedChartScreen({super.key, required this.assetKey, required this.assetInfo, required this.baseUrl});

  @override
  State<AdvancedChartScreen> createState() => _AdvancedChartScreenState();
}

class _AdvancedChartScreenState extends State<AdvancedChartScreen> {
  late WebViewController _webController;
  late String currentKey;
  bool isPageLoading = true;

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
    currentKey = widget.assetKey;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initController();
    _loadChartForAsset(currentKey);
  }

  void _initController() {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF090D12))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => isPageLoading = false);
          },
        ),
      );
  }

  Future<void> _loadChartForAsset(String key) async {
    setState(() => isPageLoading = true);

    // برای نمادهای جهانی: ویجت تریدینگ‌ویو جهانی
    if (key == "ons_gold" || key == "ons_silver") {
      final sym = key == "ons_gold" ? "OANDA:XAUUSD" : "TVC:SILVER";
      final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    html, body { width:100%; height:100%; overflow:hidden; background-color:#090D12; }
    #tv_chart { width:100%; height:100%; }
  </style>
</head>
<body>
  <div id="tv_chart"></div>
  <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
  <script type="text/javascript">
    new TradingView.widget({
      "autosize": true,
      "symbol": "$sym",
      "interval": "15",
      "timezone": "Asia/Tehran",
      "theme": "dark",
      "style": "1",
      "locale": "en",
      "toolbar_bg": "#131922",
      "enable_publishing": false,
      "hide_top_toolbar": false,
      "hide_side_toolbar": false,
      "allow_symbol_change": true,
      "container_id": "tv_chart"
    });
  </script>
</body>
</html>
''';
      _webController.loadHtmlString(html, baseUrl: 'https://www.tradingview.com');
      return;
    }

    // برای نمادهای داخلی: موتور TradingView Lightweight Charts همراه با دیتای کندلی سرور
    List<dynamic> candles = [];
    try {
      final res = await http.get(Uri.parse('${widget.baseUrl}/api/history/$key')).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        candles = json.decode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}

    final jsonCandles = json.encode(candles);
    final title = symbolNames[key] ?? key;

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <script src="https://unpkg.com/lightweight-charts@4.1.3/dist/lightweight-charts.standalone.production.js"></script>
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body { background-color:#090D12; font-family:-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; color:#fff; overflow:hidden; }
    #container { width:100vw; height:100vh; position:relative; }
    #legend { position:absolute; top:10px; left:14px; z-index:20; font-size:12px; pointer-events:none; }
    .title { font-size:14px; font-weight:bold; color:#FFD700; margin-bottom:4px; }
    .ohlc { font-family:monospace; font-size:11px; color:#9CA3AF; }
    .ohlc span { margin-right:6px; }
    .up { color:#00E676; }
    .down { color:#FF5252; }
  </style>
</head>
<body>
  <div id="container">
    <div id="legend">
      <div class="title">$title (روزانه)</div>
      <div id="ohlc" class="ohlc">برای مشاهده نوسان، انگشت خود را روی کندل‌ها بکشید</div>
    </div>
  </div>

  <script>
    const container = document.getElementById('container');
    const chart = LightweightCharts.createChart(container, {
      layout: {
        background: { color: '#090D12' },
        textColor: '#9CA3AF',
      },
      grid: {
        vertLines: { color: 'rgba(255, 255, 255, 0.05)' },
        horzLines: { color: 'rgba(255, 255, 255, 0.05)' },
      },
      crosshair: {
        mode: LightweightCharts.CrosshairMode.Normal,
      },
      rightPriceScale: {
        borderColor: 'rgba(255, 255, 255, 0.1)',
      },
      timeScale: {
        borderColor: 'rgba(255, 255, 255, 0.1)',
        timeVisible: true,
      },
    });

    const candleSeries = chart.addCandlestickSeries({
      upColor: '#00E676',
      downColor: '#FF5252',
      borderVisible: false,
      wickUpColor: '#00E676',
      wickDownColor: '#FF5252',
    });

    const rawData = $jsonCandles;
    if (rawData && rawData.length > 0) {
      candleSeries.setData(rawData);
      chart.timeScale().fitContent();
    }

    const ohlcEl = document.getElementById('ohlc');
    function formatOHLC(bar) {
      const isUp = bar.close >= bar.open;
      const cls = isUp ? 'up' : 'down';
      ohlcEl.innerHTML = `
        O: <span class="\${cls}">\${bar.open.toLocaleString()}</span>
        H: <span class="\${cls}">\${bar.high.toLocaleString()}</span>
        L: <span class="\${cls}">\${bar.low.toLocaleString()}</span>
        C: <span class="\${cls}">\${bar.close.toLocaleString()}</span>
      `;
    }

    chart.subscribeCrosshairMove(param => {
      if (!param.time || !param.seriesData.get(candleSeries)) {
        if (rawData.length > 0) formatOHLC(rawData[rawData.length - 1]);
        return;
      }
      const data = param.seriesData.get(candleSeries);
      formatOHLC(data);
    });

    if (rawData.length > 0) formatOHLC(rawData[rawData.length - 1]);

    window.addEventListener('resize', () => {
      chart.applyOptions({ width: window.innerWidth, height: window.innerHeight });
    });
  </script>
</body>
</html>
''';

    _webController.loadHtmlString(html);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF131922),
          elevation: 0,
          title: Text(symbolNames[currentKey] ?? currentKey, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            // تب‌های جابه‌جایی سریع بین نمادها در بالای صفحه
            Container(
              height: 44,
              color: const Color(0xFF131922),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                children: symbolNames.entries.map((e) {
                  final isSelected = currentKey == e.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFFD700),
                      backgroundColor: const Color(0xFF1E293B),
                      onSelected: (_) {
                        setState(() => currentKey = e.key);
                        _loadChartForAsset(e.key);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webController),
                  if (isPageLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2962FF)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
