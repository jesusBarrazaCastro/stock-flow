import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  // ── Estado ────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _error;

  DashboardKpis? _kpis;
  List<ActividadItem> _actividad = [];
  DashboardInsights? _insights;

  // ── Getters ───────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardKpis? get kpis => _kpis;
  List<ActividadItem> get actividad => _actividad;
  DashboardInsights? get insights => _insights;

  // ── Carga ─────────────────────────────────────────────────────

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getKpis(),
        _service.getActividad(limit: 5),
        _service.getInsights(),
      ]);

      _kpis = results[0] as DashboardKpis;
      _actividad = results[1] as List<ActividadItem>;
      _insights = results[2] as DashboardInsights;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[DashboardProvider.loadAll] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadAll();
}
