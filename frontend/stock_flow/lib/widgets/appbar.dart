import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({super.key});

  final SupabaseClient supabase = Supabase.instance.client;

  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.textOnPrimary,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FutureBuilder<String?>(
            future: _getUsername(),
            builder: (context, snapshot) {
              final username = snapshot.data ?? 'Usuario';
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: AppTheme.textOnPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<int>(
                      tooltip: '',
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            children: [
                              Text('Cerrar Sesión'),
                              Spacer(),
                              Icon(Icons.logout),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (int result) async {
                        if (result == 1) {
                          try {
                            await Supabase.instance.client.auth.signOut();
                            context.go('/');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Error al cerrar sesión. Por favor, intente de nuevo.'),
                              ),
                            );
                          }
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primaryDark,
                        radius: 16,
                        child: const Icon(Icons.person, color: AppTheme.textOnPrimary, size: 18),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppTheme.textOnPrimary),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
