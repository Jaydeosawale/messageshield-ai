import 'package:flutter/material.dart';

import '../../core/services/analysis_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/message_analysis.dart';
import '../../widgets/app_background.dart';
import '../../widgets/analysis_result_card.dart';

class HomeScreen extends StatefulWidget {
  final void Function(MessageAnalysis analysis) onAnalysisComplete;
  final VoidCallback? onOpenSafety;

  // Text received from Scan/OCR.
  final String? scannedText;

  // Called after scanned text is inserted into the input field.
  final VoidCallback? onScannedTextConsumed;

  const HomeScreen({
    super.key,
    required this.onAnalysisComplete,
    this.onOpenSafety,
    this.scannedText,
    this.onScannedTextConsumed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  MessageAnalysis? _analysis;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scannedText != null &&
        widget.scannedText != oldWidget.scannedText) {
      _messageController.text = widget.scannedText!;

      widget.onScannedTextConsumed?.call();
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_refresh);
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _analyzeMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        _errorMessage = 'Paste or scan a message first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final analysis = await AnalysisService.analyze(
        message: message,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _analysis = analysis;
      });

      widget.onAnalysisComplete(analysis);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearMessage() {
    _messageController.clear();

    setState(() {
      _errorMessage = null;
      _analysis = null;
    });
  }

  void _openSafety() {
    if (widget.onOpenSafety != null) {
      widget.onOpenSafety!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SafetyGuidelinesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isPhone = width < 700;
        final isNarrowPhone = width < 380;

        final pagePadding = isNarrowPhone
            ? 14.0
            : isPhone
                ? 18.0
                : 32.0;

        // Keep the Home content pinned to the TOP.
        // Center() was vertically centering the whole scrollable screen on
        // tall mobile displays, which created the large empty space above
        // the MessageShield AI header.
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                pagePadding,
                isPhone ? 18 : 28,
                pagePadding,
                isPhone ? 28 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(
                    isPhone: isPhone,
                    isNarrowPhone: isNarrowPhone,
                  ),

                  // Keep the original Home-screen spacing after the header.
                  SizedBox(
                    height: isPhone ? 24 : 38,
                  ),

                  Text(
                    'Stay Protected.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isNarrowPhone
                          ? 27
                          : isPhone
                              ? 30
                              : 38,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Check suspicious messages safely before you act.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isPhone ? 14 : 17,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),

                  // Extra breathing room on mobile keeps the message/analyze
                  // area visually centered without changing the Home design.
                  SizedBox(
                    height: isPhone ? 46 : 30,
                  ),

                  _buildMessageCard(
                    isPhone: isPhone,
                    isNarrowPhone: isNarrowPhone,
                  ),

                  if (_analysis != null) ...[
                    SizedBox(
                      height: isPhone ? 16 : 20,
                    ),
                    AnalysisResultCard(
                      analysis: _analysis!,
                      isPhone: isPhone,
                    ),
                  ],

                  SizedBox(
                    height: isPhone ? 16 : 20,
                  ),

                  _buildSafetyCard(
                    isPhone: isPhone,
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader({
    required bool isPhone,
    required bool isNarrowPhone,
  }) {
    return Row(
      children: [
        Container(
          width: isPhone ? 46 : 52,
          height: isPhone ? 46 : 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.teal,
                AppColors.green,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text.rich(
            TextSpan(
              children: const [
                TextSpan(
                  text: 'Message',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: 'Shield',
                  style: TextStyle(
                    color: AppColors.tealSoft,
                  ),
                ),
                TextSpan(
                  text: ' AI',
                  style: TextStyle(
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isNarrowPhone
                  ? 20
                  : isPhone
                      ? 22
                      : 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard({
    required bool isPhone,
    required bool isNarrowPhone,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isPhone ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft.withValues(
          alpha: 0.88,
        ),
        borderRadius: BorderRadius.circular(
          isPhone ? 18 : 24,
        ),
        border: Border.all(
          color: AppColors.teal.withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // No Scan icon.
          // No "Scan a message" title.
          // Input starts directly.

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF102B34),

              // Less curved input box.
              borderRadius: BorderRadius.circular(8),

              border: Border.all(
                color: const Color(0xFF1D4A56),
              ),
            ),
            child: TextField(
              controller: _messageController,
              minLines: isPhone ? 5 : 4,
              maxLines: isPhone ? 8 : 7,
              enabled: !_isLoading,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
              decoration: const InputDecoration(
                hintText:
                    'Paste the message you received here...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 10),

            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(height: 14),

          SizedBox(
            height: isPhone ? 58 : 58,
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : _analyzeMessage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.shield_rounded,
                      size: 20,
                    ),
              label: Text(
                _isLoading
                    ? 'ANALYZING...'
                    : 'ANALYZE MESSAGE',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          if (_messageController.text.isNotEmpty)
            Center(
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : _clearMessage,
                child: const Text(
                  'Clear message',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard({
    required bool isPhone,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openSafety,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: EdgeInsets.all(
            isPhone ? 14 : 18,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundSoft.withValues(
              alpha: 0.75,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.teal.withValues(
                alpha: 0.14,
              ),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: AppColors.tealSoft,
                size: 26,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Safety guidelines',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SAFETY GUIDELINES
// ============================================================================

class SafetyGuidelinesScreen extends StatelessWidget {
  final bool embedded;

  const SafetyGuidelinesScreen({
    super.key,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = _SafetyContent(
      embedded: embedded,
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: content,
        ),
      ),
    );
  }
}

class _SafetyContent extends StatelessWidget {
  final bool embedded;

  const _SafetyContent({
    required this.embedded,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        Icons.password_rounded,
        'OTP and passwords',
        'Never share OTPs, passwords, PINs or CVV values.'
      ),
      (
        Icons.link_rounded,
        'Suspicious links',
        'Avoid unknown links and verify organisations through official channels.'
      ),
      (
        Icons.payments_outlined,
        'Payment scams',
        'Verify payment requests before sending money.'
      ),
      (
        Icons.person_search_outlined,
        'Verify the sender',
        'A familiar name does not guarantee that a message is genuine.'
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  if (!embedded)
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),

                  const SizedBox(width: 8),

                  const Text(
                    'Safety guidelines',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSoft.withValues(
                          alpha: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            item.$1,
                            color: AppColors.tealSoft,
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.$2,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  item.$3,
                                  style: const TextStyle(
                                    color:
                                        AppColors.textSecondary,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
