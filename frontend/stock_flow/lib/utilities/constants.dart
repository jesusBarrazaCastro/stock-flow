import 'package:flutter/material.dart';
import '../app_theme.dart';

class Constants {

  static Color getColorForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppTheme.primary;
      case 'supervisor':
        return AppTheme.tertiary;
      case 'tecnico':
        return AppTheme.secondary;
      default:
        return AppTheme.textLight;
    }
  }

  static IconData getIconForRole(String status) {
    switch (status.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'supervisor':
        return Icons.manage_accounts;
      case 'tecnico':
        return Icons.build_circle;
      default:
        return Icons.help;
    }
  }


}
