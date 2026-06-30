import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vac_dashboard_app/asset/color.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/sectionHistory.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _scrollController = ScrollController();
  Future<List<dynamic>>? _dataFuture;
  String? _selectedYear;
  List<dynamic> _allData = [];

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<List<dynamic>> _loadData() async {
    final raw = await rootBundle.loadString('lib/data/dummyData.json');
    final parsed = jsonDecode(raw) as List<dynamic>;
    final years = parsed.map((e) => e['year'].toString()).toList()
      ..sort((a, b) => b.compareTo(a));
    if (mounted) {
      setState(() {
        _allData = parsed;
        _selectedYear = years.first;
      });
    }
    return parsed;
  }

  List<dynamic> get _filteredSections {
    if (_selectedYear == null) return [];
    final yearData = _allData.firstWhere(
      (e) => e['year'].toString() == _selectedYear,
      orElse: () => null,
    );
    if (yearData == null) return [];
    return yearData['data'] as List<dynamic>;
  }

  List<PopupMenuEntry<String>> get _yearMenuItems {
    final years = _allData.map((e) => e['year'].toString()).toList()
      ..sort((a, b) => b.compareTo(a));
    return years
        .map((y) => PopupMenuItem<String>(value: y, child: Text(y)))
        .toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: AppColors.colorScheme, useMaterial3: true),
      home: Scaffold(
        appBar: Header(
          title: "History",
          splitButtonLabel: _selectedYear ?? '...',
          scrollController: _scrollController,
          splitMenuItems: _yearMenuItems,
          onYearSelected: (year) => setState(() => _selectedYear = year),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: _filteredSections.length,
              itemBuilder: (context, i) {
                final section = _filteredSections[i];
                final therapies = (section['therapies'] as List)
                    .map((t) => Map<String, String>.from(t))
                    .toList();
                return SectionHistory(
                  date: section['Date'] ?? '',
                  items: therapies,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
