import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/sectionHistory.dart';
import 'package:vac_dashboard_app/models/therapy_session.dart';
import 'package:vac_dashboard_app/services/api_service.dart';
import 'package:vac_dashboard_app/services/ble_service.dart';
import 'package:vac_dashboard_app/services/therapy_receiver.dart';
import 'package:vac_dashboard_app/component/menu.dart';
import 'package:vac_dashboard_app/component/splitButton.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

class HistoryScreens extends StatefulWidget {
  const HistoryScreens({super.key});

  @override
  State<HistoryScreens> createState() => _HistoryScreensState();
}

class _HistoryScreensState extends State<HistoryScreens> {
  final _scrollController = ScrollController();
  final _ble = BleService();

  List<TherapySession> _sessions = [];
  String? _selectedYear;

  static const _monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _loadFromBackend();
    _ble.startScan();
    _ble.onTherapy.listen((payload) async {
      await TherapyReceiver.save(payload);
      _loadFromBackend();
    });
  }

  Future<void> _loadFromBackend() async {
    try {
      final all = await apiService.getSessions();
      final years =
          all.map((s) => s.sessionDate.substring(0, 4)).toSet().toList()
            ..sort((a, b) => b.compareTo(a));
      if (!mounted) return;
      setState(() {
        _sessions = all;
        _selectedYear ??= years.isNotEmpty ? years.first : null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  List<String> get _years =>
      _sessions.map((s) => s.sessionDate.substring(0, 4)).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

  List<Map<String, dynamic>> get _sections {
    if (_selectedYear == null) return [];
    final filtered = _sessions
        .where((s) => s.sessionDate.startsWith(_selectedYear!))
        .toList();

    final byMonth = <String, List<TherapySession>>{};
    for (final s in filtered) {
      final key = s.sessionDate.substring(0, 7);
      byMonth.putIfAbsent(key, () => []).add(s);
    }

    final keys = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.map((k) {
      final parts = k.split('-');
      final label = '${_monthNames[int.parse(parts[1])]} ${parts[0]}';
      final items = byMonth[k]!
          .map(
            (s) => {
              'title': s.title,
              'date': s.date,
              'mode': s.mode,
              'duration': s.duration,
            },
          )
          .toList();
      return {'date': label, 'therapies': items};
    }).toList();
  }

  List<Widget> get _yearMenuItems => _years
      .map(
        (y) => AppMenuItem(
          label: y,
          onPressed: () {
            setState(() => _selectedYear = y);
            Navigator.of(context).pop();
          },
        ),
      )
      .toList();

  @override
  void dispose() {
    _scrollController.dispose();
    _ble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'History',
        variant: AppHeaderVariant.compactTitle3,
        leading: Container(
          width: 44,
          height: 44,
          decoration: ShapeDecoration(
            color: context.colors.backgroundsPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: context.colors.labelsPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        trailing: SplitButton(
          label: _selectedYear ?? 'Year',
          size: SplitButtonSize.small,
          variant: SplitButtonVariant.outline,
          onPressed: () {},
          menuItems: _yearMenuItems,
        ),
      ),
      backgroundColor: context.colors.backgroundsPrimary,
      body: _sessions.isEmpty
          ? const Center(child: Text('Belum ada data terapi'))
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(34),
              itemCount: _sections.length,
              itemBuilder: (context, i) {
                final section = _sections[i];
                final therapies = (section['therapies'] as List)
                    .map((t) => Map<String, String>.from(t as Map))
                    .toList();
                return SectionHistory(
                  date: section['date'] as String,
                  items: therapies,
                );
              },
            ),
    );
  }
}
