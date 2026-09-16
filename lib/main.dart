import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'data/plant_data.dart';
import 'firebase_options.dart';
import 'models/plant.dart';

const String apiUrl = 'http://localhost:8000/predict';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LeafCareApp());
}

/* ============================================================
   APP
   ============================================================ */

class LeafCareApp extends StatelessWidget {
  const LeafCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafCare AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F9F3),
        fontFamily: 'Arial',
      ),
      home: const LoginScreen(),
    );
  }
}

/* ============================================================
   GLOBAL APP STATE
   ============================================================ */

class AppState {
  static String language = 'English';

  static final List<Plant> history = [];
}

/* ============================================================
   LOGIN SCREEN
   ============================================================ */

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password.'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC8E6C9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 65,
                    color: Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'LeafCare AI',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Smart plant identification and leaf health analysis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton(
                    onPressed: login,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

SizedBox(
  width: double.infinity,
  height: 58,
  child: OutlinedButton(
   onPressed: () {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const MainNavigationScreen(),
    ),
  );
},
    child: const Text(
      'Farmer Login',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

const SizedBox(height: 15),

const Text(
  'Demo login: enter any email and password',
  style: TextStyle(
    color: Colors.grey,
    fontSize: 13,
  ),
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   MAIN NAVIGATION
   ============================================================ */

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    ScanLeafScreen(),
    PlantsScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Plants',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   HOME SCREEN
   ============================================================ */

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LeafCare AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showLanguageDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 45,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Welcome to LeafCare AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Identify plants and analyze leaf health using AI.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _HomeCard(
                    icon: Icons.document_scanner,
                    title: 'Scan Leaf',
                    subtitle: 'Analyze with AI',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScanLeafScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _HomeCard(
                    icon: Icons.local_florist,
                    title: 'Plants',
                    subtitle: 'Browse plants',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlantsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _HomeCard(
                    icon: Icons.history,
                    title: 'History',
                    subtitle: 'Previous scans',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _HomeCard(
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'Your settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    color: Color(0xFF2E7D32),
                    size: 45,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'AI-Powered Leaf Health',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload a clear leaf image to identify the plant and check for possible health conditions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   HOME CARD
   ============================================================ */

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 175,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E7D32),
                size: 28,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   SCAN LEAF SCREEN
   ============================================================ */

class ScanLeafScreen extends StatefulWidget {
  const ScanLeafScreen({super.key});

  @override
  State<ScanLeafScreen> createState() => _ScanLeafScreenState();
}

class _ScanLeafScreenState extends State<ScanLeafScreen> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? selectedImageBytes;
  bool isLoading = false;

  Future<void> takePhoto() async {
    try {
      setState(() {
        isLoading = true;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImageBytes = bytes;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo captured successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera error: $e'),
        ),
      );
    }
  }

  Future<void> chooseFromGallery() async {
    try {
      setState(() {
        isLoading = true;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImageBytes = bytes;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gallery error: $e'),
        ),
      );
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Image',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.camera_alt,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: const Text('Take a Photo'),
                  subtitle: const Text('Use your camera'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    takePhoto();
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.photo_library,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select a leaf photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    chooseFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> analyzeLeaf() async {
    if (selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select or capture a leaf image first.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrl),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          selectedImageBytes!,
          filename: 'leaf.jpg',
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      if (!mounted) return;

      Map<String, dynamic> data;

      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Invalid response from backend: ${response.body}',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['message']?.toString() ??
              'Server returned ${response.statusCode}',
        );
      }

      if (data['success'] != true) {
        throw Exception(
          data['message']?.toString() ??
              'Leaf analysis failed.',
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LeafAnalysisResultScreen(
            imageBytes: selectedImageBytes!,
            result: data,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 7),
          content: Text(
            'Analysis failed:\n$e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void openPlant(Plant plant) {
    if (!AppState.history.contains(plant)) {
      AppState.history.add(plant);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantInformationScreen(
          plant: plant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan a Leaf',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            15,
            18,
            30,
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFB7DDB9),
                    width: 2,
                  ),
                ),
                child: selectedImageBytes == null
                    ? const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.document_scanner_outlined,
                            size: 72,
                            color: Color(0xFF2E7D32),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Leaf Scanner',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Text(
                              'Take a photo or choose a leaf image to detect the plant and identify possible disease.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(26),
                        child: Image.memory(
                          selectedImageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 280,
                        ),
                      ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed:
                      isLoading ? null : showImageOptions,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    selectedImageBytes == null
                        ? 'Take / Select Leaf'
                        : 'Change Leaf',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2E7D32),
                    disabledBackgroundColor:
                        const Color(0xFF81A984),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed:
                      isLoading ? null : chooseFromGallery,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  label: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF2E7D32),
                    side: const BorderSide(
                      color: Color(0xFF78977A),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              if (selectedImageBytes != null) ...[
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton.icon(
                    onPressed:
                        isLoading ? null : analyzeLeaf,
                    icon: isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.auto_awesome,
                          ),
                    label: Text(
                      isLoading
                          ? 'Analyzing Leaf...'
                          : 'Analyze Leaf',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1565C0),
                      disabledBackgroundColor:
                          const Color(0xFF789AC0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'AI will analyze the uploaded leaf automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      size: 45,
                      color: Color(0xFF2E7D32),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Smart Leaf Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload a clear leaf image. LeafCare AI will identify the plant and analyze its health condition using the AI service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Available Plants',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Browse plant information separately.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 15),

              ...plants.map(
                (plant) => Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor:
                          Color(0xFFE8F5E9),
                      child: Icon(
                        Icons.eco,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    title: Text(
                      plant.names['English'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle:
                        Text(plant.scientificName),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      openPlant(plant);
                    },
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

/* ============================================================
   LEAF ANALYSIS RESULT SCREEN
   ============================================================ */

class LeafAnalysisResultScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final Map<String, dynamic> result;

  const LeafAnalysisResultScreen({
    super.key,
    required this.imageBytes,
    required this.result,
  });

  // ------------------------------------------------------------
  // Get text safely from API response
  // ------------------------------------------------------------

  String value(
    String key, [
    String fallback = 'Information unavailable',
  ]) {
    final item = result[key];

    if (item == null) {
      return fallback;
    }

    final text = item.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  // ------------------------------------------------------------
  // Get number safely from API response
  // ------------------------------------------------------------

  double numberValue(String key) {
    final item = result[key];

    if (item is num) {
      return item.toDouble();
    }

    return double.tryParse(
          item?.toString() ?? '',
        ) ??
        0.0;
  }

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // PLANT INFORMATION
    // ==========================================================

    final plant = value(
      'plant',
      'Unknown plant',
    );

    final commonName = value(
      'common_name',
      plant,
    );

    final scientificName = value(
      'scientific_name',
      'Scientific name unavailable',
    );

    final identificationStatus = value(
      'identification_status',
      'Identification completed',
    );

    // ==========================================================
    // DISEASE INFORMATION
    // ==========================================================

    final disease = value(
      'disease',
      'Disease information unavailable',
    );

    final diseaseConfidence = numberValue(
      'disease_confidence',
    );

    final healthyProbability = numberValue(
      'healthy_probability',
    );

    final severity = value(
      'severity',
      'Not evaluated',
    );
    // ==========================================================
// SYMPTOMS
// ==========================================================

final symptoms = value(
  'symptoms',
  '',
);


// ==========================================================
// TREATMENT
// ==========================================================

final treatment =
    result['treatment'] is List
        ? List<String>.from(
            result['treatment'],
          )
        : <String>[];


// ==========================================================
// PREVENTION
// ==========================================================

final prevention =
    result['prevention'] is List
        ? List<String>.from(
            result['prevention'],
          )
        : <String>[];

    // ==========================================================
    // CONFIDENCE
    // ==========================================================

    final plantConfidence = numberValue(
      'plant_confidence',
    );

    // ==========================================================
    // MESSAGE
    // ==========================================================

    final message = value(
      'message',
      'Plant analysis completed.',
    );

    // ==========================================================
    // ALTERNATIVE IDENTIFICATIONS
    // ==========================================================

    final alternatives =
        result['alternatives'] is List
            ? result['alternatives'] as List
            : <dynamic>[];

    // ==========================================================
    // DETERMINE WHETHER THIS IS A DISEASE RESULT
    // ==========================================================

    final diseaseUnavailable =
        disease.toLowerCase().contains(
              'disease detection is not available',
            ) ||
        disease.toLowerCase().contains(
              'not available',
            );

    final isHealthy =
        disease.toLowerCase().contains(
              'healthy',
            ) ||
        disease.toLowerCase().contains(
              'no clear disease',
            );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaf Analysis Result',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          18,
          15,
          18,
          35,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // UPLOADED IMAGE
            // ==================================================

            Container(
              width: double.infinity,
              height: 250,

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(25),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.08),

                    blurRadius: 12,

                    offset: const Offset(
                      0,
                      5,
                    ),
                  ),
                ],
              ),

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(25),

                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // PAGE TITLE
            // ==================================================

            const Text(
              'Leaf Analysis Result',

              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // MAIN RESULT CARD
            // ==================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(24),
              ),

              child: Column(
                children: [

                  // ------------------------------------------
                  // COMMON NAME
                  // ------------------------------------------

                  _ResultRow(
                    icon: Icons.eco,
                    label: 'Plant',
                    value: commonName,
                  ),

                  const Divider(
                    height: 25,
                  ),

                  // ------------------------------------------
                  // SCIENTIFIC NAME
                  // ------------------------------------------

                  _ResultRow(
                    icon:
                        Icons.science_outlined,
                    label: 'Scientific Name',
                    value: scientificName,
                    italic: true,
                  ),

                  const Divider(
                    height: 25,
                  ),

                  // ------------------------------------------
                  // PLANT CONFIDENCE
                  // ------------------------------------------

                  _ResultRow(
                    icon:
                        Icons.analytics_outlined,

                    label:
                        'Plant Confidence',

                    value:
                        '${plantConfidence.toStringAsFixed(2)}%',
                  ),

                  const Divider(
                    height: 25,
                  ),

                  // ------------------------------------------
                  // IDENTIFICATION STATUS
                  // ------------------------------------------

                  _ResultRow(
                    icon:
                        Icons.verified_outlined,

                    label:
                        'Identification',

                    value:
                        identificationStatus,
                  ),

                  const Divider(
                    height: 25,
                  ),

                  // ------------------------------------------
                  // DISEASE / STATUS
                  // ------------------------------------------

                  _ResultRow(
                    icon: diseaseUnavailable
                        ? Icons.info_outline
                        : isHealthy
                            ? Icons
                                .check_circle_outline
                            : Icons
                                .coronavirus_outlined,

                    label:
                        'Disease / Status',

                    value: disease,
                  ),

                  // ------------------------------------------
                  // DISEASE CONFIDENCE
                  // ------------------------------------------

                  if (!diseaseUnavailable) ...[
                    const Divider(
                      height: 25,
                    ),

                    _ResultRow(
                      icon:
                          Icons.health_and_safety_outlined,

                      label:
                          'Disease Confidence',

                      value:
                          '${diseaseConfidence.toStringAsFixed(2)}%',
                    ),
                  ],

                  // ------------------------------------------
                  // HEALTHY PROBABILITY
                  // ------------------------------------------

                  if (!diseaseUnavailable) ...[
                    const Divider(
                      height: 25,
                    ),

                    _ResultRow(
                      icon:
                          Icons.favorite_outline,

                      label:
                          'Healthy Probability',

                      value:
                          '${healthyProbability.toStringAsFixed(2)}%',
                    ),
                  ],

                  // ------------------------------------------
                  // SEVERITY
                  // ------------------------------------------

                  if (!diseaseUnavailable) ...[
                    const Divider(
                      height: 25,
                    ),

                    _ResultRow(
                      icon:
                          Icons.speed_outlined,

                      label:
                          'Severity',

                      value: severity,
                    ),
                  ],
                  if (!diseaseUnavailable && symptoms.isNotEmpty) ...[
  const SizedBox(height: 18),

  Text(
    'Symptoms: $symptoms',
    style: const TextStyle(
      fontSize: 16,
    ),
  ),
],
// TREATMENT
if (!diseaseUnavailable && treatment.isNotEmpty) ...[
  const SizedBox(height: 18),

  const Text(
    'Treatment',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 8),

  ...treatment.map(
    (item) => Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        '• $item',
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    ),
  ),
],


// PREVENTION
if (!diseaseUnavailable && prevention.isNotEmpty) ...[
  const SizedBox(height: 18),

  const Text(
    'Prevention',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 8),

  ...prevention.map(
    (item) => Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        '• $item',
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    ),
  ),
],
            // ==================================================
            // ANALYSIS MESSAGE
            // ==================================================

            _ResultSection(
              icon:
                  Icons.info_outline,

              title:
                  'Analysis Message',

              child: Text(
                message,

                style: const TextStyle(
                  fontSize: 16,
                  height: 1.55,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // AI INTERPRETATION
            // ==================================================

            _ResultSection(
              icon:
                  Icons.psychology_outlined,

              title:
                  'AI Interpretation',

              child: Text(
                _interpretation(
                  commonName: commonName,
                  scientificName:
                      scientificName,
                  identificationStatus:
                      identificationStatus,
                  plantConfidence:
                      plantConfidence,
                  disease:
                      disease,
                  diseaseUnavailable:
                      diseaseUnavailable,
                  isHealthy:
                      isHealthy,
                  severity:
                      severity,
                  diseaseConfidence:
                      diseaseConfidence,
                ),

                style: const TextStyle(
                  fontSize: 16,
                  height: 1.55,
                  color: Colors.black87,
                ),
              ),
            ),

            // ==================================================
            // ALTERNATIVE IDENTIFICATIONS
            // ==================================================

            if (alternatives.isNotEmpty) ...[
              const SizedBox(height: 16),

              _ResultSection(
                icon:
                    Icons.list_alt_outlined,

                title:
                    'Other Possible Identifications',

                child: Column(
                  children: [
                    for (
                      int i = 0;
                      i < alternatives.length;
                      i++
                    )
                      _AlternativePlant(
                        index: i + 1,
                        data: alternatives[i],
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            // ==================================================
            // WARNING / DISCLAIMER
            // ==================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(17),

              decoration: BoxDecoration(
                color:
                    Colors.orange.shade50,

                borderRadius:
                    BorderRadius.circular(18),

                border: Border.all(
                  color:
                      Colors.orange.shade200,
                ),
              ),

              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'AI plant identification is not guaranteed to be correct. Image quality, leaf appearance, plant variety, and similar species can affect the result. For important agricultural decisions, verify the identification with a qualified agricultural professional.',

                      style: TextStyle(
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

             // ==================================================
// SCAN ANOTHER LEAF
// ==================================================

SizedBox(
  width: double.infinity,
  height: 56,

  child: FilledButton.icon(
    onPressed: () {
      Navigator.pop(context);
    },

    icon: const Icon(
      Icons.camera_alt_outlined,
    ),

    label: const Text(
      'Scan Another Leaf',

      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    style: FilledButton.styleFrom(
      backgroundColor: const Color(
        0xFF2E7D32,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          17,
        ),
      ),
    ),
  ),
),

                            ],
        ),
      ),
    ],
  ),
));
}

  // ============================================================
  // AI INTERPRETATION
  // ============================================================
  String _interpretation({
    required String commonName,
    required String scientificName,
    required String identificationStatus,
    required double plantConfidence,
    required String disease,
    required bool diseaseUnavailable,
    required bool isHealthy,
    required String severity,
    required double diseaseConfidence,
  }) {

    final confidenceText =
        '${plantConfidence.toStringAsFixed(2)}%';

    if (diseaseUnavailable) {
      return 'The AI identified this plant as '
          '"$commonName" with the scientific name '
          '"$scientificName". '
          'The identification confidence is '
          '$confidenceText, and the identification '
          'status is "$identificationStatus".\n\n'
          'The current Pl@ntNet identification request '
          'does not perform plant disease diagnosis. '
          'Therefore, this result should not be interpreted '
          'as proof that the plant is healthy or unhealthy.';
    }

    if (isHealthy) {
      return 'The AI identified this plant as '
          '"$commonName" ($scientificName) with '
          '$confidenceText identification confidence.\n\n'
          'No clear disease was identified in the '
          'analysis. Continue monitoring the plant for '
          'spots, discoloration, wilting, unusual growth, '
          'or other visible changes.';
    }

    return 'The AI identified "$commonName" '
        '($scientificName) with approximately '
        '$confidenceText identification confidence.\n\n'
        'The reported condition is "$disease" with '
        '${diseaseConfidence.toStringAsFixed(2)}% '
        'confidence. The reported severity is '
        '"$severity".\n\n'
        'Use this result as an indication rather than '
        'a guaranteed diagnosis.';
  }
}


/* ============================================================
   ALTERNATIVE PLANT
   ============================================================ */

class _AlternativePlant
    extends StatelessWidget {

  final int index;
  final dynamic data;

  const _AlternativePlant({
    required this.index,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {

    if (data is! Map) {
      return const SizedBox.shrink();
    }

    final item =
        Map<String, dynamic>.from(data);

    final name =
        item['name']?.toString() ??
            'Unknown plant';

    final scientificName =
        item['scientific_name']
                ?.toString() ??
            'Scientific name unavailable';

    final confidenceValue =
        item['confidence'];

    double confidence = 0;

    if (confidenceValue is num) {
      confidence =
          confidenceValue.toDouble();
    } else {
      confidence =
          double.tryParse(
                confidenceValue
                        ?.toString() ??
                    '',
              ) ??
              0;
    }

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color:
            const Color(0xFFF5F9F5),

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color:
              const Color(0xFFE0E0E0),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ----------------------------------------------
          // NUMBER
          // ----------------------------------------------

          Container(
            width: 32,
            height: 32,

            alignment:
                Alignment.center,

            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFE8F5E9),
              shape:
                  BoxShape.circle,
            ),

            child: Text(
              '$index',

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,

                color:
                    Color(0xFF2E7D32),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ----------------------------------------------
          // PLANT INFORMATION
          // ----------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  name,

                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF1B5E20),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  scientificName,

                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontStyle:
                        FontStyle.italic,
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${confidence.toStringAsFixed(2)}% confidence',

                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/* ============================================================
   RESULT ROW
   ============================================================ */

class _ResultRow
    extends StatelessWidget {

  final IconData icon;
  final String label;
  final String value;
  final bool italic;

  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        // ----------------------------------------------------
        // ICON
        // ----------------------------------------------------

        Container(
          width: 46,
          height: 46,

          decoration:
              BoxDecoration(
            color:
                const Color(0xFFE8F5E9),

            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),

          child: Icon(
            icon,
            color:
                const Color(0xFF2E7D32),
          ),
        ),

        const SizedBox(width: 14),

        // ----------------------------------------------------
        // TEXT
        // ----------------------------------------------------

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                label,

                style:
                    const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,

                  fontStyle: italic
                      ? FontStyle.italic
                      : FontStyle.normal,

                  color:
                      const Color(
                    0xFF1B5E20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


/* ============================================================
   RESULT SECTION
   ============================================================ */

class _ResultSection
    extends StatelessWidget {

  final IconData icon;
  final String title;
  final Widget child;

  const _ResultSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Icon(
                icon,
                color:
                    const Color(
                  0xFF2E7D32,
                ),
                size: 27,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,

                  style:
                      const TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}


/* ============================================================
   RESULT ROW
   ============================================================ */

/* ============================================================
   RESULT SECTION
   ============================================================ */

/* ============================================================
   PLANTS SCREEN
   ============================================================ */

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.all(14),
              leading: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.local_florist,
                  color: Color(0xFF2E7D32),
                  size: 30,
                ),
              ),
              title: Text(
                plant.names['English'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              subtitle:
                  Text(plant.scientificName),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 17,
              ),
              onTap: () {
                if (!AppState.history
                    .contains(plant)) {
                  AppState.history.add(plant);
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PlantInformationScreen(
                      plant: plant,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/* ============================================================
   PLANT INFORMATION SCREEN
   ============================================================ */

class PlantInformationScreen extends StatefulWidget {
  final Plant plant;

  const PlantInformationScreen({
    super.key,
    required this.plant,
  });

  @override
  State<PlantInformationScreen> createState() =>
      _PlantInformationScreenState();
}

class _PlantInformationScreenState
    extends State<PlantInformationScreen> {
  String get language => AppState.language;

  @override
  void initState() {
    super.initState();

    if (!AppState.history
        .contains(widget.plant)) {
      AppState.history.add(widget.plant);
    }
  }

  String getText(Map<String, String> data) {
    return data[language] ??
        data['English'] ??
        'Information unavailable.';
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showLanguageDialog(
                context,
                refresh: () {
                  setState(() {});
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration:
                        const BoxDecoration(
                      color: Color(0xFFC8E6C9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF2E7D32),
                      size: 55,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    plant.names[language] ??
                        plant.names['English'] ??
                        '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    plant.scientificName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle:
                          FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE8F5E9),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Traditional Plant',
                      style: TextStyle(
                        color:
                            Color(0xFF2E7D32),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _InformationCard(
              icon: Icons.favorite_outline,
              title:
                  'What is it traditionally used for?',
              content: getText(plant.uses),
            ),

            _InformationCard(
              icon: Icons.local_cafe_outlined,
              title:
                  'How people traditionally use it',
              content:
                  getText(plant.preparation),
            ),

            _InformationCard(
              icon: Icons.schedule,
              title: 'Typical traditional use',
              content:
                  getText(plant.duration),
            ),

            _InformationCard(
              icon: Icons.shield_outlined,
              title: 'Safety information',
              content:
                  getText(plant.safety),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color:
                      Colors.orange.shade200,
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This information describes traditional uses. It does not diagnose disease or guarantee a cure. For serious or persistent symptoms, consult a qualified healthcare professional.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   INFORMATION CARD
   ============================================================ */

class _InformationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InformationCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                    const Color(0xFF2E7D32),
                size: 27,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   HISTORY SCREEN
   ============================================================ */

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState
    extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final history =
        AppState.history.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
              ),
              onPressed: () {
                setState(() {
                  AppState.history.clear();
                });
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No scans yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Your plant scans will appear here.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(18),
              itemCount: history.length,
              itemBuilder:
                  (context, index) {
                final plant =
                    history[index];

                return Card(
                  color: Colors.white,
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    leading:
                        const CircleAvatar(
                      backgroundColor:
                          Color(0xFFE8F5E9),
                      child: Icon(
                        Icons.eco,
                        color:
                            Color(0xFF2E7D32),
                      ),
                    ),
                    title: Text(
                      plant.names[
                              AppState
                                  .language] ??
                          plant.names[
                              'English'] ??
                          '',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      plant.scientificName,
                    ),
                    trailing:
                        const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlantInformationScreen(
                            plant: plant,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

/* ============================================================
   PROFILE SCREEN
   ============================================================ */

class ProfileScreen
    extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(25),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor:
                  Color(0xFFC8E6C9),
              child: Icon(
                Icons.person,
                size: 55,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'LeafCare User',
              style: TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading:
                  const Icon(Icons.language),
              title:
                  const Text('Language'),
              subtitle:
                  Text(AppState.language),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                showLanguageDialog(
                  context,
                );
              },
            ),

            const Divider(),

            ListTile(
              leading:
                  const Icon(Icons.info_outline),
              title: const Text(
                'About LeafCare AI',
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName:
                      'LeafCare AI',
                  applicationVersion:
                      '1.0.0',
                  applicationIcon:
                      const Icon(
                    Icons.eco,
                    color:
                        Color(0xFF2E7D32),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   LANGUAGE DIALOG
   ============================================================ */

void showLanguageDialog(
  BuildContext context, {
  VoidCallback? refresh,
}) {
  const languages = [
    'English',
    'Telugu',
    'Hindi',
    'Tamil',
    'Kannada',
    'Malayalam',
    'Urdu',
  ];

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Choose Language',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder:
                (context, index) {
              final language =
                  languages[index];

              final isSelected =
                  AppState.language ==
                      language;

              return ListTile(
                title: Text(language),
                leading: Icon(
                  isSelected
                      ? Icons
                          .radio_button_checked
                      : Icons
                          .radio_button_unchecked,
                  color: isSelected
                      ? const Color(
                          0xFF2E7D32,
                        )
                      : Colors.grey,
                ),
                selected: isSelected,
                selectedTileColor:
                    const Color(
                  0xFFE8F5E9,
                ),
                onTap: () {
                  AppState.language =
                      language;

                  Navigator.pop(
                    dialogContext,
                  );

                  refresh?.call();

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Language changed to $language',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );
}
class FarmerLoginScreen extends StatelessWidget {
  const FarmerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Login'),
      ),
      body: const Center(
        child: Text(
          'Farmer Login Screen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}