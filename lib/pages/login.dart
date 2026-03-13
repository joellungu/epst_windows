import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
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
const double _inputHeight = 55;
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
  late TextEditingController _matriculeController;
  late TextEditingController _mdpController;
  bool _isPasswordVisible = false;

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
    Get.put(PlainteController());
    Get.put(ArchiveController());
    Get.put(UpdateController());
    Get.put(AdminController());
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
          _buildMatriculeField(),
          const SizedBox(height: _spacingMedium),
          _buildPasswordField(),
          const SizedBox(height: _spacingLarge),
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
        TextField(
          controller: _matriculeController,
          keyboardType: TextInputType.emailAddress,
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
        )
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _mdpController,
                keyboardType: TextInputType.emailAddress,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_borderRadius),
                  ),
                  contentPadding: const EdgeInsets.only(top: 14),
                  prefixIcon: const Icon(Icons.vpn_key, color: _primaryColor),
                  hintText: "Mot de passe",
                  label: const Text("Mot de passe"),
                ),
              ),
            ),
            IconButton(
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
            )
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
      child: SizedBox(
        height: 45,
        child: Center(
          child: Text(
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
    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;

    // if (!isConnected) {
    //   _showErrorDialog(
    //     "Erreur",
    //     "Vous n'êtes pas connecté à Internet!",
    //   );
    //   return;
    // }

    if (_matriculeController.text.isEmpty || _mdpController.text.isEmpty) {
      _showErrorDialog(
        "Erreur",
        "Veuillez saisir vos identifiants",
      );
      return;
    }

    _showLoginDialog();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check),
          )
        ],
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => Material(
        color: Colors.transparent,
        child: _LoginLoader(
          matricule: _matriculeController.text,
          mdp: _mdpController.text,
          onSuccess: () {
            setState(() {
              _matriculeController.clear();
              _mdpController.clear();
            });
          },
        ),
      ),
    );
  }
}

// ============================================================================
// LOGIN LOADER
// ============================================================================

class _LoginLoader extends StatefulWidget {
  final String matricule;
  final String mdp;
  final VoidCallback onSuccess;

  const _LoginLoader({
    Key? key,
    required this.matricule,
    required this.mdp,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<_LoginLoader> createState() => _LoginLoaderState();
}

class _LoginLoaderState extends State<_LoginLoader> {
  late Future<Map<String, dynamic>> _loginFuture;

  @override
  void initState() {
    super.initState();
    _loginFuture = _performLogin();
  }

  Future<Map<String, dynamic>> _performLogin() async {
    final result =
        await Connexion.utilisateur_login(widget.matricule, widget.mdp);
    widget.onSuccess();
    return result;
  }

  void _handleLoginResult(Map<String, dynamic> result) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      if (result["matricule"] == null) {
        Navigator.of(context).pop();
      } else {
        Get.offAll(Accueil(result));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 500,
        width: 300,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loginFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _handleLoginResult(snapshot.data!);
              return _buildResultWidget(snapshot.data!);
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            }
            return _buildLoadingWidget();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildResultWidget(Map<String, dynamic> result) {
    final isSuccess = result["matricule"] != null;
    return Center(
      child: Container(
        height: 75,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Text(
          isSuccess
              ? "Authentification réussie!"
              : "Votre mot de passe ou matricule n'est pas correct",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSuccess ? Colors.green : Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        height: 75,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Text(
          "Erreur: $error",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
