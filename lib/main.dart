import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Map<String, dynamic> previousPrices = {};
  Map<String, dynamic> news3DaysData = {};
  String errorMessage = "";
  Timer? _liveAutoRefreshTimer;
  late TabController _tabController;

  Set<String> readNewsTitles = {};
  bool showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReadNews();
    fetchData();

    _liveAutoRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchData(isSilent: true);
    });
  }

  Future<void> _loadReadNews() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('read_news_titles') ?? [];
    if (mounted) {
      setState(() {
        readNewsTitles = list.toSet();
      });
    }
  }

  Future<void> _markNewsAsRead(String title) async {
    if (title.isEmpty || readNewsTitles.contains(title)) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      readNewsTitles.add(title);
    });
    await prefs.setStringList('read_news_titles', readNewsTitles.toList());
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
      final pRes = await http.get(Uri.parse('$baseUrl/api/prices')).timeout(const Duration(seconds: 4));

      if (!isSilent || news3DaysData.isEmpty) {
        final nRes = await http.get(Uri.parse('$baseUrl/api/news-3days')).timeout(const Duration(seconds: 4));
        if (nRes.statusCode == 200 && mounted) {
          news3DaysData = json.decode(utf8.decode(nRes.bodyBytes));
        }
      }

      if (pRes.statusCode == 200 && mounted) {
        final newPrices = json.decode(utf8.decode(pRes.bodyBytes));
        setState(() {
          previousPrices = pricesData;
          pricesData = newPrices;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!isSilent && mounted) {
        setState(() {
          errorMessage = "خطا در دریافت نرخ‌های زنده. اتصال اینترنت را چک کنید.";
          isLoading = false;
        });
      }
    }
  }

  Future<void> _openExternalChart(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD700), size: 20),
                                SizedBox(width: 8),
                                Text('پایش هوشمند اخبار موثر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  showUnreadOnly = !showUnreadOnly;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: showUnreadOnly ? const Color(0xFF00E676).withOpacity(0.2) : Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: showUnreadOnly ? const Color(0xFF00E676) : Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      showUnreadOnly ? Icons.mark_email_unread_rounded : Icons.filter_list_rounded,
                                      size: 14,
                                      color: showUnreadOnly ? const Color(0xFF00E676) : Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      showUnreadOnly ? 'فقط خوانده‌نشده' : 'همه اخبار',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: showUnreadOnly ? const Color(0xFF00E676) : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            if (_tabController.index == 0) {
                              return _buildNewsList(todayList, "رویداد موثری برای نمایش وجود ندارد.");
                            } else if (_tabController.index == 1) {
                              return _buildNewsList(yesterdayList, "رویدادی برای روز قبل در آرشیو نیست.");
                            } else {
                              return _buildNewsList(twoDaysAgoList, "رویدادی برای ۲ روز قبل در آرشیو نیست.");
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
      return const Center(child: Text('درحال اتصال به تابلوی زنده...', style: TextStyle(color: Colors.grey)));
    }
    final prevAssets = previousPrices['assets'] != null ? Map<String, dynamic>.from(previousPrices['assets']) : {};

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
        final prevItem = prevAssets[key] != null ? Map<String, dynamic>.from(prevAssets[key]) : null;

        return LiveTickerCard(
          assetKey: key,
          item: item,
          prevItem: prevItem,
          accentColor: _getAssetColor(key),
          iconData: _getAssetIcon(key),
          onTap: () => _showAssetSheet(key, item),
        );
      },
    );
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
                            const Text('🔻 کف روزانه (Low)', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                            const Text('🔺 سقف روزانه (High)', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                      backgroundColor: isTradingView ? const Color(0xFF2962FF) : const Color(0xFFFF9800),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openExternalChart(chartUrl);
                    },
                    icon: Icon(isTradingView ? Icons.candlestick_chart_rounded : Icons.insights_rounded, color: Colors.white),
                    label: Text(
                      isTradingView ? 'مشاهده زنده چارت در TradingView' : 'مشاهده زنده چارت در TGJU',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsList(List<dynamic> list, String emptyMessage) {
    final filteredList = showUnreadOnly
        ? list.where((item) {
            final t = (item['structured']?['title'] ?? '').toString();
            return !readNewsTitles.contains(t);
          }).toList()
        : list;

    if (filteredList.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.center,
        child: Text(
          showUnreadOnly ? "همه اخبار این بخش را مطالعه کرده‌اید! 🎉" : emptyMessage,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, idx) {
        final item = filteredList[idx];
        final structured = item['structured'] ?? {};
        final timeStr = item['timestamp']?.toString() ?? '';
        final title = (structured['title'] ?? '').toString();
        final isRead = readNewsTitles.contains(title);

        return _buildNewsCard(structured, timeStr, isRead, () => _markNewsAsRead(title));
      },
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> n, String timestamp, bool isRead, VoidCallback onExpanded) {
    final title = n['title']?.toString() ?? 'گزارش تحلیلی بازار';
    final importance = n['importance']?.toString() ?? '🟡 متوسط';
    final affected = n['affected']?.toString() ?? '#طلا #دلار #سکه';
    final direction = n['direction']?.toString() ?? '⚪️ نوسانی';
    final newsSummary = n['news_summary']?.toString() ?? 'خلاصه رویداد در دست نیست.';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.white10 : const Color(0xFFFFD700).withOpacity(0.5),
          width: isRead ? 1.0 : 1.4,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (isOpen) {
            if (isOpen) onExpanded();
          },
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          collapsedIconColor: isRead ? Colors.white54 : const Color(0xFFFFD700),
          iconColor: const Color(0xFFFFD700),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF00E676).withOpacity(0.6)),
                  ),
                  child: const Text('🟢 جدید', style: TextStyle(color: Color(0xFF00E676), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: isRead ? Colors.white70 : Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
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
                    style: TextStyle(
                      fontSize: 10,
                      color: isRead ? Colors.grey : const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                    ),
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
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2962FF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2962FF).withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description_rounded, size: 16, color: Color(0xFF90CAF9)),
                      SizedBox(width: 6),
                      Text('📄 خلاصه متن و اصل رویداد:', style: TextStyle(color: Color(0xFF90CAF9), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(newsSummary, style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 14),
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

class LiveTickerCard extends StatefulWidget {
  final String assetKey;
  final Map<String, dynamic> item;
  final Map<String, dynamic>? prevItem;
  final Color accentColor;
  final IconData iconData;
  final VoidCallback onTap;

  const LiveTickerCard({
    super.key,
    required this.assetKey,
    required this.item,
    required this.prevItem,
    required this.accentColor,
    required this.iconData,
    required this.onTap,
  });

  @override
  State<LiveTickerCard> createState() => _LiveTickerCardState();
}

class _LiveTickerCardState extends State<LiveTickerCard> {
  Color _flashBorderColor = Colors.white.withOpacity(0.08);
  Timer? _resetTimer;

  @override
  void didUpdateWidget(covariant LiveTickerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldRaw = oldWidget.item['raw_num'];
    final newRaw = widget.item['raw_num'];

    if (oldRaw != null && newRaw != null && oldRaw != newRaw) {
      if (newRaw > oldRaw) {
        _triggerFlash(const Color(0xFF00E676));
      } else if (newRaw < oldRaw) {
        _triggerFlash(const Color(0xFFF23645));
      }
    }
  }

  void _triggerFlash(Color color) {
    setState(() {
      _flashBorderColor = color;
    });
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _flashBorderColor = Colors.white.withOpacity(0.08);
        });
      }
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final change = item['change']?.toString() ?? '۰.۰٪';
    final isNegative = change.contains('-');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF131922),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _flashBorderColor, width: _flashBorderColor != Colors.white.withOpacity(0.08) ? 1.8 : 1.0),
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
                    Icon(widget.iconData, color: widget.accentColor, size: 18),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: widget.accentColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        item['symbol']?.toString() ?? '',
                        style: TextStyle(color: widget.accentColor, fontSize: 10, fontWeight: FontWeight.bold),
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
  }
}
