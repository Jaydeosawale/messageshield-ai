import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'models/message_analysis.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/home/home_screen.dart';
import 'widgets/app_background.dart';

// ============================================================
// APP START
// ============================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..initialize(),
      child: const MessageShieldApp(),
    ),
  );
}

// ============================================================
// MAIN APP
// ============================================================

class MessageShieldApp extends StatelessWidget {
  const MessageShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MessageShield',
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

// ============================================================
// AUTH GATE
//
// Controls the first screen when the application starts.
//
// 1. Checking saved session → Loading screen
// 2. No valid user         → Login screen
// 3. Valid user            → AppShell
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // ----------------------------------------------------------
    // Still checking token / backend session
    // ----------------------------------------------------------

    if (!auth.isInitialized) {
      return const AppLoadingScreen();
    }

    // ----------------------------------------------------------
    // User is not authenticated
    // ----------------------------------------------------------

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // ----------------------------------------------------------
    // User is authenticated
    // ----------------------------------------------------------

    return const AppShell();
  }
}

// ============================================================
// APP LOADING SCREEN
// ============================================================

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(
          color: AppColors.teal,
        ),
      ),
    );
  }
}

// ============================================================
// APP SECTIONS
// ============================================================

enum AppSection {
  home,
  history,
  safety,
  profile,
}

// ============================================================
// APP SHELL
// ============================================================

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection _selected = AppSection.home;

  MessageAnalysis? _latestAnalysis;

  // Text received from scanner/OCR.
  String? _scannedText;

  // ==========================================================
  // ANALYSIS COMPLETE
  // ==========================================================

  void _handleAnalysisComplete(
    MessageAnalysis analysis,
  ) {
    setState(() {
      _latestAnalysis = analysis;
    });
  }

  // ==========================================================
  // SELECT SECTION
  // ==========================================================

  void _selectSection(
    AppSection section,
  ) {
    setState(() {
      _selected = section;
    });
  }

  // ==========================================================
  // OPEN SAFETY
  // ==========================================================

  void _openSafety(
    BuildContext context,
  ) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 700) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const SafetyGuidelinesScreen(),
        ),
      );
    } else {
      _selectSection(AppSection.safety);
    }
  }

  // ==========================================================
  // SCAN
  //
  // Currently:
  // Manual text input
  //
  // Future:
  // Camera OCR
  // Screenshot OCR
  // Gallery image OCR
  // ==========================================================

  Future<void> _openScan() async {
    final controller = TextEditingController();

    final result =
        await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom:
                  MediaQuery.of(sheetContext)
                          .viewInsets
                          .bottom +
                      16,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D2028),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.teal.withValues(
                    alpha: 0.25,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Scan icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          AppColors.teal.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      color: AppColors.tealSoft,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Scan message',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'OCR camera and screenshot scanning will be connected here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Manual scan text input
                  TextField(
                    controller: controller,
                    minLines: 3,
                    maxLines: 6,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'For now, paste scanned text here to test the flow...',
                      hintStyle: const TextStyle(
                        color:
                            AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor:
                          const Color(0xFF102B34),
                      contentPadding:
                          const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(0xFF1D4A56),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final text =
                            controller.text.trim();

                        if (text.isNotEmpty) {
                          Navigator.pop(
                            sheetContext,
                            text,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.check_rounded,
                      ),
                      label: const Text(
                        'USE THIS TEXT',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    controller.dispose();

    if (!mounted ||
        result == null ||
        result.isEmpty) {
      return;
    }

    setState(() {
      _scannedText = result;

      // Open Home after scanning.
      _selected = AppSection.home;
    });
  }

  // ==========================================================
  // CURRENT PAGE
  // ==========================================================

  Widget _buildCurrentPage(
    BuildContext context,
  ) {
    switch (_selected) {
      case AppSection.home:
        return HomeScreen(
          onAnalysisComplete:
              _handleAnalysisComplete,

          onOpenSafety: () =>
              _openSafety(context),

          // Scanned text enters Home input automatically.
          scannedText: _scannedText,

          // Clear after Home consumes it.
          onScannedTextConsumed: () {
            setState(() {
              _scannedText = null;
            });
          },
        );

      case AppSection.history:
        return const HistoryScreen();

      case AppSection.safety:
        return const SafetyGuidelinesScreen(
          embedded: true,
        );

      case AppSection.profile:
        return const ProfilePlaceholderScreen();
    }
  }

  // ==========================================================
  // MAIN APP SHELL UI
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final width =
        MediaQuery.sizeOf(context).width;

    final isMobile = width < 700;

    final isTablet =
        width >= 700 && width < 1100;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // ------------------------------------------------------
        // BODY
        // ------------------------------------------------------

        body: isMobile
            ? SafeArea(
                bottom: false,
                child:
                    _buildCurrentPage(context),
              )
            : SafeArea(
                child: Row(
                  children: [
                    // ------------------------------------------------
                    // TABLET NAVIGATION
                    // ------------------------------------------------

                    if (isTablet)
                      _SideNavigation(
                        selected: _selected,
                        onSelected:
                            _selectSection,
                        onScan: _openScan,
                        extended: false,
                      )

                    // ------------------------------------------------
                    // DESKTOP NAVIGATION
                    // ------------------------------------------------

                    else
                      _SideNavigation(
                        selected: _selected,
                        onSelected:
                            _selectSection,
                        onScan: _openScan,
                        extended: true,
                      ),

                    Container(
                      width: 1,
                      color:
                          AppColors.teal.withValues(
                        alpha: 0.12,
                      ),
                    ),

                    // ------------------------------------------------
                    // PAGE CONTENT
                    // ------------------------------------------------

                    Expanded(
                      child:
                          _buildCurrentPage(context),
                    ),
                  ],
                ),
              ),

        // ------------------------------------------------------
        // MOBILE BOTTOM NAVIGATION
        // ------------------------------------------------------

        bottomNavigationBar: isMobile
            ? _buildMobileBottomNavigation()
            : null,
      ),
    );
  }

  // ==========================================================
  // MOBILE BOTTOM NAVIGATION
  // ==========================================================

  Widget _buildMobileBottomNavigation() {
    final selectedIndex = switch (_selected) {
      AppSection.home => 0,
      AppSection.history => 2,
      AppSection.safety => 0,
      AppSection.profile => 3,
    };

    return NavigationBar(
      backgroundColor: AppColors.background,
      height: 72,
      selectedIndex: selectedIndex,

      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            _selectSection(
              AppSection.home,
            );
            break;

          case 1:
            _openScan();
            break;

          case 2:
            _selectSection(
              AppSection.history,
            );
            break;

          case 3:
            _selectSection(
              AppSection.profile,
            );
            break;
        }
      },

      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon:
              Icon(Icons.home_rounded),
          label: 'Home',
        ),

        NavigationDestination(
          icon:
              Icon(Icons.document_scanner_outlined),
          selectedIcon:
              Icon(Icons.document_scanner_rounded),
          label: 'Scan',
        ),

        NavigationDestination(
          icon:
              Icon(Icons.history_outlined),
          selectedIcon:
              Icon(Icons.history_rounded),
          label: 'History',
        ),

        NavigationDestination(
          icon:
              Icon(Icons.person_outline_rounded),
          selectedIcon:
              Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ============================================================
// DESKTOP / TABLET SIDE NAVIGATION
// ============================================================

class _SideNavigation extends StatelessWidget {
  final AppSection selected;

  final ValueChanged<AppSection> onSelected;

  final VoidCallback onScan;

  final bool extended;

  const _SideNavigation({
    required this.selected,
    required this.onSelected,
    required this.onScan,
    required this.extended,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      minWidth: 76,
      minExtendedWidth: 220,

      selectedIndex: switch (selected) {
        AppSection.home => 0,
        AppSection.history => 2,
        AppSection.safety => 0,
        AppSection.profile => 3,
      },

      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            onSelected(AppSection.home);
            break;

          case 1:
            onScan();
            break;

          case 2:
            onSelected(
              AppSection.history,
            );
            break;

          case 3:
            onSelected(
              AppSection.profile,
            );
            break;
        }
      },

      destinations: const [
        NavigationRailDestination(
          icon:
              Icon(Icons.home_outlined),
          selectedIcon:
              Icon(Icons.home_rounded),
          label: Text('Home'),
        ),

        NavigationRailDestination(
          icon: Icon(
            Icons.document_scanner_outlined,
          ),
          selectedIcon: Icon(
            Icons.document_scanner_rounded,
          ),
          label: Text('Scan'),
        ),

        NavigationRailDestination(
          icon:
              Icon(Icons.history_outlined),
          selectedIcon:
              Icon(Icons.history_rounded),
          label: Text('History'),
        ),

        NavigationRailDestination(
          icon: Icon(
            Icons.person_outline_rounded,
          ),
          selectedIcon:
              Icon(Icons.person_rounded),
          label: Text('Profile'),
        ),
      ],
    );
  }
}

// ============================================================
// PROFILE PLACEHOLDER
// ============================================================

class ProfilePlaceholderScreen
    extends StatelessWidget {
  const ProfilePlaceholderScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}