import 'package:epst_windows_app/pages/accueil.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin/admin_controller.dart';
import 'archive/archive_controller.dart';
import 'controllers/plainte_controller.dart';
import 'load_mag/update_controller.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

const double _loginFormWidth = 300;
const double _logoSize = 300;
const double _inputLabelFontSize = 16;
const double _loginTitleFontSize = 40;
const double _spacingLarge = 30;
const double _spacingMedium = 10;
const double _borderRadius = 10;

const Color _primaryColor = Colors.blue;
const Color _textColor = Colors.black;
const Color _hintColor = Colors.grey;

// ============================================================================
// LOGIN SCREEN
// ============================================================================

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _matriculeController;
  late TextEditingController _mdpController;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _matriculeController = TextEditingController();
    _mdpController = TextEditingController();
    _initializeControllers();
  }

  @override
  void dispose() {
    _matriculeController.dispose();
    _mdpController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    if (!Get.isRegistered<PlainteController>()) {
      Get.put(PlainteController());
    }
    if (!Get.isRegistered<ArchiveController>()) {
      Get.put(ArchiveController());
    }
    if (!Get.isRegistered<UpdateController>()) {
      Get.put(UpdateController());
    }
    if (!Get.isRegistered<AdminController>()) {
      Get.put(AdminController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(child: _buildLogoSection()),
          _buildLoginForm(),
          const Padding(padding: EdgeInsets.only(right: 100)),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: SizedBox(
        height: _logoSize,
        width: _logoSize,
        child: Image.asset(
          "assets/logo_min_edu_nc.png",
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SizedBox(
      width: _loginFormWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(),
          const SizedBox(height: _spacingLarge),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildMatriculeField(),
                const SizedBox(height: _spacingMedium),
                _buildPasswordField(),
              ],
            ),
          ),
          if (_errorMessage != null) _buildErrorBanner(),
          const SizedBox(height: _spacingMedium),
          _buildLoginButton(),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: _spacingMedium),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          CupertinoIcons.person,
          size: MediaQuery.of(context).size.width / 9,
        ),
        const Text(
          "Connexion",
          style: TextStyle(
            color: _hintColor,
            fontSize: _loginTitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMatriculeField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Matricule",
            style: TextStyle(
              color: _textColor,
              fontSize: _inputLabelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: _spacingMedium),
        TextFormField(
          controller: _matriculeController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Le matricule est obligatoire";
            }
            return null;
          },
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            contentPadding: const EdgeInsets.only(top: 14),
            prefixIcon: const Icon(CupertinoIcons.person, color: _primaryColor),
            hintText: "Matricule",
            label: const Text("Matricule"),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Mot de passe",
            style: TextStyle(
              color: _textColor,
              fontSize: _inputLabelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: _spacingMedium),
        TextFormField(
          controller: _mdpController,
          keyboardType: TextInputType.text,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onFieldSubmitted: (_) => _handleLogin(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Le mot de passe est obligatoire";
            }
            return null;
          },
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            contentPadding: const EdgeInsets.only(top: 14),
            prefixIcon: const Icon(Icons.vpn_key, color: _primaryColor),
            hintText: "Mot de passe",
            label: const Text("Mot de passe"),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: _spacingMedium),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return _primaryColor.withOpacity(0.6);
          }
          return _primaryColor;
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
      child: SizedBox(
        height: 45,
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  "Connexion",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _inputLabelFontSize,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final result = await Connexion.utilisateur_login(
      _matriculeController.text,
      _mdpController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result["ok"] == true) {
      final user = result["user"] as Map<String, dynamic>?;
      if (user == null || user["matricule"] == null) {
        setState(() {
          _errorMessage =
              "La session n'a pas pu être établie. Veuillez réessayer.";
        });
        return;
      }
      Get.offAll(() => Accueil(user));
    } else {
      setState(() {
        _errorMessage = result["message"] as String? ??
            "Connexion impossible. Veuillez réessayer.";
      });
    }
  }
}
