import 'package:flutter/material.dart';
import 'package:stock_flow/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Usuario de Stock Flow');
  final _phoneController = TextEditingController(text: '+52 55 1234 5678');
  final _emailController = TextEditingController(text: 'usuario@ejemplo.com');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Ocultar teclado
      
      // Simular guardado y mostrar feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: AppTheme.spacingSm),
              Text('Perfil actualizado correctamente'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppTheme.neutral,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatarEditor(),
                const SizedBox(height: AppTheme.spacingXl),
                
                // Formulario
                _buildFormSection(
                  title: 'Información Personal',
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nombre Completo',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingLg),
                
                _buildFormSection(
                  title: 'Autenticación',
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      label: 'Correo Electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.info.withOpacity(0.3)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                          SizedBox(width: AppTheme.spacingSm),
                          Expanded(
                            child: Text(
                              'El correo electrónico se utiliza para iniciar sesión. Si necesitas cambiarlo, contacta al administrador.',
                              style: TextStyle(
                                color: AppTheme.textMedium,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingXl),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Guardar Cambios'),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarEditor() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary, width: 3),
            boxShadow: AppTheme.elevatedShadow,
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Simular apertura de galería o cámara
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.tertiary,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.neutral, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.tertiary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppTheme.textOnPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? AppTheme.textDark : AppTheme.textLight,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? AppTheme.primary : AppTheme.textLight),
        fillColor: enabled ? AppTheme.surface : AppTheme.neutral,
      ),
      validator: (value) {
        if (enabled && (value == null || value.trim().isEmpty)) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }
}
