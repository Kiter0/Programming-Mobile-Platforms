import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class CreateEditScreen extends StatefulWidget {
  final ApiService apiService;
  final User? user;

  const CreateEditScreen({
    super.key,
    required this.apiService,
    this.user,
  });

  @override
  State<CreateEditScreen> createState() => _CreateEditScreenState();
}

class _CreateEditScreenState extends State<CreateEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.user?.name ?? '',
    );
    _emailController = TextEditingController(
      text: widget.user?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.user?.phone ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть email';
    }

    final emailRegex = RegExp(
      r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Введіть коректний email';
    }

    return null;
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final existingUser = widget.user;

    final user = User(
      id: existingUser?.id ?? 0,
      name: _nameController.text.trim(),
      username: existingUser?.username ?? '',
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      website: existingUser?.website ?? '',
      address: existingUser?.address ??
          Address(
            street: '',
            suite: '',
            city: '',
            zipcode: '',
            geo: Geo(lat: '', lng: ''),
          ),
      company: existingUser?.company ??
          Company(
            name: '',
            catchPhrase: '',
            bs: '',
          ),
    );

    try {
      final savedUser = _isEditing
          ? await widget.apiService.updateUser(
              existingUser!.id,
              user,
            )
          : await widget.apiService.createUser(user);

      if (!mounted) return;

      Navigator.pop(context, savedUser);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка збереження: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Редагувати користувача' : 'Новий користувач',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Ім’я',
                controller: _nameController,
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введіть ім’я';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              _buildTextField(
                label: 'Телефон',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введіть номер телефону';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveUser,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(
                    _isSaving
                        ? 'Збереження...'
                        : _isEditing
                            ? 'Зберегти зміни'
                            : 'Створити користувача',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
