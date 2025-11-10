import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/presentation/notifiers/auth_notifier.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedPhotoURL;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      _nameController.text = currentUser.displayName ?? '';
      _emailController.text = currentUser.email;
      _selectedPhotoURL = currentUser.photoURL;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: currentUser == null
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Editar perfil',
                                style: AppTypography.titleStyle.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorScheme.color4,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 24),
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                    border: Border.all(
                                      color: AppColorScheme.color2,
                                      width: 3,
                                    ),
                                  ),
                                  child: _selectedPhotoURL != null && _selectedPhotoURL!.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            _selectedPhotoURL!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.grey,
                                              );
                                            },
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColorScheme.color2,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                      onPressed: _changePhoto,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre completo',
                              hintText: 'Tu nombre completo',
                              prefixIcon: const Icon(Icons.person_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColorScheme.color2, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es obligatorio';
                              }
                              if (value.trim().length < 2) {
                                return 'El nombre debe tener al menos 2 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'tu@email.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'El email no se puede cambiar. Contacta con soporte si necesitas cambiarlo.',
                            style: AppTypography.bodyStyle.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _saveProfile(authNotifier),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorScheme.color2,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Guardar cambios',
                                      style: AppTypography.interactiveStyle.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 48,
                            child: TextButton(
                              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: AppTypography.interactiveStyle.copyWith(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _changePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Foto de Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de Galería'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Usar URL'),
              onTap: () {
                Navigator.of(context).pop();
                _enterPhotoURL();
              },
            ),
            if (_selectedPhotoURL != null && _selectedPhotoURL!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedPhotoURL = '';
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _takePhoto() {
    // TODO: Implementar cámara
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'La captura desde cámara estará disponible próximamente. Usa la opción "Usar URL" por ahora.',
        ),
        backgroundColor: Colors.orange.shade600,
      ),
    );
  }

  void _pickFromGallery() {
    // TODO: Implementar galería
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'La selección desde galería estará disponible próximamente. Usa la opción "Usar URL" por ahora.',
        ),
        backgroundColor: Colors.orange.shade600,
      ),
    );
  }

  void _enterPhotoURL() {
    final urlController = TextEditingController(text: _selectedPhotoURL ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('URL de Foto'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'URL de la imagen',
            hintText: 'https://ejemplo.com/foto.jpg',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  _selectedPhotoURL = url;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Usar URL'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile(AuthNotifier authNotifier) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await authNotifier.updateProfile(
        displayName: _nameController.text.trim(),
        photoURL: _selectedPhotoURL,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
