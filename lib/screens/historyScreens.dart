import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/sectionHistory.dart';
import 'package:vac_dashboard_app/models/therapy_session.dart';
import 'package:vac_dashboard_app/services/api_service.dart';
import 'package:vac_dashboard_app/services/ble_service.dart';
import 'package:vac_dashboard_app/component/menu.dart';
import 'package:vac_dashboard_app/component/splitButton.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/network/api_interceptor.dart';
import 'package:vac_dashboard_app/screens/welcomeScreens.dart';
import 'package:vac_dashboard_app/db/database_helper.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'dart:async';

class HistoryScreens extends StatefulWidget {
  const HistoryScreens({super.key});

  @override
  State<HistoryScreens> createState() => _HistoryScreensState();
}

class _HistoryScreensState extends State<HistoryScreens> {
  final _scrollController = ScrollController();
  final _ble = bleService;
  late final StreamSubscription _therapySub;

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

  void _handleAuthException() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreens()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _syncAndLoadData();
    _therapySub = _ble.onTherapy.listen((_) async {
      // BleService.handleIncomingBytes already saves globally — just reload
      try {
        await _syncAndLoadData();
      } on AuthException {
        _handleAuthException();
      } catch (e) {
        if (!mounted) return;
        debugPrint('Gagal memuat data: $e');
      }
    });
  }

  Future<void> _syncAndLoadData() async {
    try {
      // Load local offline data first
      final localData = await DatabaseHelper.instance.getAll();
      if (localData.isNotEmpty && mounted) {
        final localSessions = localData
            .map(
              (e) => TherapySession(
                id: e['id'] as int? ?? 0,
                sessionDate: e['session_date'] as String,
                title: e['title'] as String,
                date: e['date'] as String,
                mode: e['mode'] as String,
                duration: e['duration'] as String,
              ),
            )
            .toList();
        setState(() {
          _sessions = localSessions;
          if (_selectedYear == null) {
            final y =
                localSessions
                    .map((s) => s.sessionDate.substring(0, 4))
                    .toSet()
                    .toList()
                  ..sort((a, b) => b.compareTo(a));
            _selectedYear = y.isNotEmpty ? y.first : null;
          }
        });
      }

      // Sync with backend
      final all = await apiService.getSessions();
      final years =
          all.map((s) => s.sessionDate.substring(0, 4)).toSet().toList()
            ..sort((a, b) => b.compareTo(a));
      if (!mounted) return;
      setState(() {
        _sessions = all;
        _selectedYear ??= years.isNotEmpty ? years.first : null;
      });
    } on AuthException {
      _handleAuthException();
    } catch (e) {
      if (!mounted) return;
      debugPrint('Gagal memuat data: $e');
    }
  }

  List<String> get _years =>
      _sessions.map((s) => s.sessionDate.substring(0, 4)).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

  List<Map<String, dynamic>> get _sections {
    if (_selectedYear == null) return [];

    // 1. Sort all sessions chronologically ASCENDING (oldest -> newest) for "Terapi N" numbering
    final sortedAsc = List<TherapySession>.from(_sessions)
      ..sort((a, b) {
        final cmp = a.parsedDateTime.compareTo(b.parsedDateTime);
        if (cmp != 0) return cmp;
        return (a.id ?? 0).compareTo(b.id ?? 0);
      });

    // 2. Map using session id (or session instance fallback) for collision-safe lookup
    final sessionTitleMap = <Object, String>{};
    for (int i = 0; i < sortedAsc.length; i++) {
      final session = sortedAsc[i];
      final key = session.id ?? session;
      sessionTitleMap[key] = 'Terapi ${i + 1}';
    }

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

      // 3. Sort sessions inside this month DESCENDING (newest at top, oldest at bottom)
      final monthSessions = List<TherapySession>.from(byMonth[k]!)
        ..sort((a, b) {
          final cmp = b.parsedDateTime.compareTo(a.parsedDateTime); // Descending (newest first)
          if (cmp != 0) return cmp;
          return (b.id ?? 0).compareTo(a.id ?? 0);
        });

      final items = monthSessions
          .map(
            (s) => {
              'title': sessionTitleMap[s.id ?? s] ?? s.title,
              'date': s.date,
              'mode': s.mode,
              'duration': s.duration,
              'pressure': s.pressure,
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
    _therapySub.cancel();
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
