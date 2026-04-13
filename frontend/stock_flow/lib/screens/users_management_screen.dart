import 'package:flutter/material.dart';
import 'package:stock_flow/app_theme.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  // Mock data
  final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'name': 'Jesús Barraza',
      'email': 'jesus@ejemplo.com',
      'role': 'Admin',
      'isActive': true,
    },
    {
      'id': 2,
      'name': 'María López',
      'email': 'maria@ejemplo.com',
      'role': 'Empleado',
      'isActive': true,
    },
    {
      'id': 3,
      'name': 'Carlos Ruiz',
      'email': 'carlos@ejemplo.com',
      'role': 'Empleado',
      'isActive': false,
    },
  ];

  void _showRoleDialog(Map<String, dynamic> user) {
    String selectedRole = user['role'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestionar Usuario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.15),
                        child: Text(
                          user['name'][0], 
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)
                        ),
                      ),
                      title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user['email']),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 30),
                    const Text('Asignar Rol', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppTheme.spacingSm),
                    RadioListTile<String>(
                      title: const Text('Administrador'),
                      subtitle: const Text('Acceso total a la configuración y todos los almacenes.'),
                      value: 'Admin',
                      groupValue: selectedRole,
                      activeColor: AppTheme.primary,
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedRole = val);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Empleado'),
                      subtitle: const Text('Acceso limitado al registro de inventario y consultas.'),
                      value: 'Empleado',
                      groupValue: selectedRole,
                      activeColor: AppTheme.primary,
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            user['role'] = selectedRole;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Guardar Cambios'),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.textOnPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Usuarios y Roles',
                style: TextStyle(
                  color: AppTheme.textOnPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryDark, AppTheme.primary],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Icon(
                      Icons.people,
                      size: 200,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Invitar Nuevo Usuario'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = _users[index];
                  final isAdmin = user['role'] == 'Admin';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: ListTile(
                      onTap: () => _showRoleDialog(user),
                      leading: CircleAvatar(
                        backgroundColor: isAdmin ? AppTheme.primary.withOpacity(0.2) : AppTheme.neutral,
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          color: isAdmin ? AppTheme.primary : AppTheme.textMedium,
                        ),
                      ),
                      title: Text(
                        user['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                      ),
                      subtitle: Text(user['email'], style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAdmin ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Text(
                              user['role'],
                              style: TextStyle(
                                color: isAdmin ? AppTheme.primary : AppTheme.textMedium,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.more_vert, color: AppTheme.textLight, size: 20),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _users.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: AppTheme.spacingXl)),
        ],
      ),
    );
  }
}
