import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../data/database_helper.dart';
import '../../providers/controllers/auth_controller.dart';
import '../../providers/controllers/product_controller.dart';

class LoginScreen extends StatefulWidget {
  final String? returnToRoute;

  const LoginScreen({super.key, this.returnToRoute});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordModal() {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    int step = 1; // 1: Pedir correo, 2: Código y nueva clave
    String? generatedCode;
    String? modalError;
    bool isModalLoading = false;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Indicador de arrastre
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDED5C8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Encabezado
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF8A6721)
                                .withValues(alpha: 0.12),
                            border: Border.all(
                              color: const Color(0xFFC5A059)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Color(0xFF8A6721),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recuperar Contraseña',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF281E17),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Maison Elora • Seguridad',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8A7E73),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF8A7E73),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFECE3D4), height: 1),
                    const SizedBox(height: 18),

                    if (modalError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.dangerRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppTheme.dangerRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                modalError!,
                                style: const TextStyle(
                                  color: AppTheme.dangerRed,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (step == 1) ...[
                      const Text(
                        'Ingresa el correo electrónico asociado a tu cuenta para verificarla y generar tu código de recuperación.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF5E544A),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: resetEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: Color(0xFF8A6721),
                          ),
                          hintText: 'ejemplo@elora.com',
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: isModalLoading
                            ? null
                            : () async {
                                final email =
                                    resetEmailController.text.trim();
                                if (email.isEmpty || !email.contains('@')) {
                                  setSheetState(() {
                                    modalError =
                                        'Por favor ingresa un correo electrónico válido.';
                                  });
                                  return;
                                }

                                setSheetState(() {
                                  isModalLoading = true;
                                  modalError = null;
                                });

                                final user = await DatabaseHelper.instance
                                    .getUserByEmail(email);

                                if (user == null) {
                                  setSheetState(() {
                                    isModalLoading = false;
                                    modalError =
                                        'No encontramos ninguna cuenta registrada con este correo.';
                                  });
                                  return;
                                }

                                // Generar código aleatorio de 6 dígitos
                                final code =
                                    (100000 + Random().nextInt(900000))
                                        .toString();
                                setSheetState(() {
                                  generatedCode = code;
                                  step = 2;
                                  isModalLoading = false;
                                  modalError = null;
                                  codeController.text = code;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C3A2B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isModalLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Verificar Correo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                              ),
                      ),
                    ] else ...[
                      // Notificación visual del código
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF2E7D32)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.mark_email_read_outlined,
                              color: Color(0xFF2E7D32),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Código de seguridad generado: $generatedCode\n(Enviado a ${resetEmailController.text.trim()})',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF1B5E20),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Código de verificación de 6 dígitos',
                          prefixIcon: Icon(
                            Icons.pin_outlined,
                            color: Color(0xFF8A6721),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'Nueva contraseña',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF8A6721),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 19,
                              color: const Color(0xFF8A7E73),
                            ),
                            onPressed: () {
                              setSheetState(
                                () => obscureNew = !obscureNew,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirmar nueva contraseña',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF8A6721),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 19,
                              color: const Color(0xFF8A7E73),
                            ),
                            onPressed: () {
                              setSheetState(
                                () => obscureConfirm = !obscureConfirm,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: isModalLoading
                            ? null
                            : () async {
                                final enteredCode =
                                    codeController.text.trim();
                                final newPass = newPasswordController.text;
                                final confirmPass =
                                    confirmPasswordController.text;

                                if (enteredCode != generatedCode) {
                                  setSheetState(() {
                                    modalError =
                                        'El código ingresado es incorrecto.';
                                  });
                                  return;
                                }

                                if (newPass.length < 6) {
                                  setSheetState(() {
                                    modalError =
                                        'La contraseña debe tener al menos 6 caracteres.';
                                  });
                                  return;
                                }

                                if (newPass != confirmPass) {
                                  setSheetState(() {
                                    modalError =
                                        'Las contraseñas no coinciden.';
                                  });
                                  return;
                                }

                                setSheetState(() {
                                  isModalLoading = true;
                                  modalError = null;
                                });

                                final authProvider =
                                    Provider.of<AuthProvider>(
                                      context,
                                      listen: false,
                                    );
                                final success = await authProvider
                                    .resetPassword(
                                      resetEmailController.text.trim(),
                                      newPass,
                                    );

                                if (success) {
                                  Navigator.of(ctx).pop();
                                  _emailController.text =
                                      resetEmailController.text.trim();
                                  _passwordController.text = newPass;

                                  if (mounted) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '¡Contraseña restablecida exitosamente! Ya puedes iniciar sesión.',
                                            ),
                                            backgroundColor:
                                                AppTheme.successGreen,
                                            duration: Duration(
                                              seconds: 3,
                                            ),
                                          ),
                                        );
                                  }
                                } else {
                                  setSheetState(() {
                                    isModalLoading = false;
                                    modalError =
                                        authProvider.errorMessage ??
                                            'Error al actualizar la contraseña.';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C3A2B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isModalLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Guardar Nueva Contraseña',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.loadUserFavorites(authProvider.currentUser?.email);

      if (!mounted) return;

      if (authProvider.isAdmin) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.adminCatalog,
          (route) => false,
        );
      } else if (widget.returnToRoute != null) {
        Navigator.of(context).pushReplacementNamed(widget.returnToRoute!);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.catalog,
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAF7F2),
              Color(0xFFF3ECE0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Barra superior minimalista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    if (Navigator.of(context).canPop())
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 19,
                          color: Color(0xFF281E17),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    else
                      const SizedBox(height: 48),
                  ],
                ),
              ),

              // Contenido principal desplazable
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. MEDALLÓN IMPERIAL TOTALMENTE REDONDO
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(
                                color: const Color(0xFFC5A059),
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC5A059)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/elora_logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 42,
                                    color: Color(0xFFC5A059),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 2. TÍTULO DE MARCA CON LA "E" EN FUENTE SERIF DE LUJO
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'E',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFC5A059),
                                    letterSpacing: 4,
                                  ),
                                ),
                                TextSpan(
                                  text: 'LORA',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 31,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 9,
                                    color: Color(0xFF281E17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtítulo con líneas de acento en oro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 1,
                                color: const Color(0xFFC5A059)
                                    .withValues(alpha: 0.6),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'HAUTE PARFUMERIE',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 10.5,
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8A6721),
                                  ),
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 1,
                                color: const Color(0xFFC5A059)
                                    .withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // 3. TARJETA ELEGANTE DEL FORMULARIO
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: const Color(0xFFEDE4D4),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF281E17)
                                      .withValues(alpha: 0.05),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Iniciar Sesión',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF281E17),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Ingresa tus credenciales para acceder a tu cuenta.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8A7E73),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Campo Correo Electrónico
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      color: Color(0xFF281E17),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Correo electrónico',
                                      hintText: 'ejemplo@elora.com',
                                      prefixIcon: const Icon(
                                        Icons.mail_outline_rounded,
                                        color: Color(0xFF8A6721),
                                        size: 21,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFFBF9F6),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE5DDD0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE5DDD0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF8A6721),
                                          width: 1.6,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Ingresa tu correo';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Ingresa un correo válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),

                                  // Campo Contraseña
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      color: Color(0xFF281E17),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: Color(0xFF8A6721),
                                        size: 21,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color(0xFF8A7E73),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFFBF9F6),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE5DDD0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE5DDD0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF8A6721),
                                          width: 1.6,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu contraseña';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),

                                  // Enlace Olvidaste tu contrasena
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _showForgotPasswordModal,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        '¿Olvidaste tu contraseña?',
                                        style: TextStyle(
                                          color: Color(0xFF8A6721),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Botón Iniciar Sesión con Gradiente Oro & Café de Lujo
                                  Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF38291F),
                                          Color(0xFF1E140D),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(26),
                                      border: Border.all(
                                        color: const Color(0xFFC5A059)
                                            .withValues(alpha: 0.5),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF1E140D)
                                              .withValues(alpha: 0.3),
                                          blurRadius: 14,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: authProvider.isLoading
                                          ? null
                                          : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(26),
                                        ),
                                      ),
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Color(0xFFC5A059),
                                                ),
                                              ),
                                            )
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Acceder a mi cuenta',
                                                  style: TextStyle(
                                                    fontSize: 15.5,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    letterSpacing: 0.6,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 18,
                                                  color: Color(0xFFC5A059),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          // Enlace de Registro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿Aún no tienes una cuenta? ',
                                style: TextStyle(
                                  color: Color(0xFF8A7E73),
                                  fontSize: 13.5,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.register);
                                },
                                child: const Text(
                                  'Crear cuenta',
                                  style: TextStyle(
                                    color: Color(0xFF8A6721),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Sello de Marca de Lujo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 14,
                                color: const Color(0xFF8A6721)
                                    .withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Maison de Parfum • Fragancias Exclusivas',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 11,
                                  color: const Color(0xFF8A7E73)
                                      .withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
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
