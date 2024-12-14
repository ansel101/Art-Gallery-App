import 'package:flutter/material.dart';
import 'arthsare.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CreativeSignupApp());
}

class CreativeSignupApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creative Signup',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      home: SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool _isSignedUp = false;

  void _handleSignup() {
    setState(() {
      _isSignedUp = _usernameController.text.trim().isNotEmpty &&
          _fullNameController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),  // Soft purple
              Color(0xFF764BA2),  // Deep purple
            ],
          ),
        ),
        child: Center(
          child: Padding(  // Added Padding here to prevent edge-to-edge content
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: !_isSignedUp
                ? _buildSignupForm()
                : _buildWelcomeScreen(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Creativity Unleashed',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          _buildAnimatedTextField(
              controller: _fullNameController,
              hintText: 'Your Full Name',
              icon: Icons.person_outline
          ),
          SizedBox(height: 16),
          _buildAnimatedTextField(
              controller: _usernameController,
              hintText: 'Creative Username',
              icon: Icons.alternate_email
          ),
          SizedBox(height: 24),
          _buildElevatedButton(),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState((){}),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Color(0xFF667EEA)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton() {
    final isEnabled = _usernameController.text.trim().isNotEmpty &&
        _fullNameController.text.trim().isNotEmpty;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: isEnabled
              ? [Color(0xFF667EEA), Color(0xFF764BA2)]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: Color(0xFF667EEA).withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 8),
          )
        ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? _handleSignup : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Begin Your Creative Journey',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Welcome, ${_fullNameController.text}!',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '"Creativity is intelligence having fun."',
            style: GoogleFonts.merriweather(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtworkGalleryPage(
                    username: _usernameController.text,
                    fullName: _fullNameController.text,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667EEA),
              minimumSize: Size(250, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: Text(
              'Explore ArtShare',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}