import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/analysis_service.dart';
import '../../models/message_analysis.dart';
import '../../providers/auth_provider.dart';
import '../history/history_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  bool _isAnalyzing = false;
  String? _errorMessage;
  MessageAnalysis? _analysis;
 
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _analyzeMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        _errorMessage =
            'Please enter a message to analyze.';
      });

      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _analysis = null;
    });

    try {
      final result =
          await AnalysisService.analyze(
        message: message,
      );

      if (!mounted) return;

      setState(() {
        _analysis = result;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            error.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _clearAnalysis() {
    setState(() {
      _messageController.clear();
      _analysis = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1A315F),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Color(0xFF6EA8FF),
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              'MessageShield',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _clearAnalysis,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            tooltip: 'Clear',
          ),

          IconButton(
            onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(
               builder: (_) => const HistoryScreen(),
             ),
        );
       },
       icon: const Icon(Icons.history_outlined),
       tooltip: 'Analysis History',
        ),


          IconButton(
            onPressed: auth.isLoading
                ? null
                : () async {
                    await context
                        .read<AuthProvider>()
                        .logout();
                  },
            icon: const Icon(
              Icons.logout_rounded,
            ),
            tooltip: 'Logout',
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 820,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _buildHero(),

                  const SizedBox(height: 28),

                  _buildAnalyzerCard(),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    _buildErrorCard(),
                  ],

                  if (_analysis != null) ...[
                    const SizedBox(height: 24),

                    _AnalysisResultCard(
                      analysis: _analysis!,
                    ),
                  ],

                  const SizedBox(height: 32),

                  _buildSecurityNote(),

                  const SizedBox(height: 24),

                  Text(
                    auth.user?.email ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Colors.white54,
                        ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF315EFB),
                Color(0xFF00B8D9),
              ],
            ),
            borderRadius:
                BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55315EFB),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_rounded,
            size: 46,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Check before you trust',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 10),

        Text(
          'Analyze suspicious messages and identify potential fraud, scams, and security threats.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(
                color: Colors.white60,
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildAnalyzerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF6EA8FF),
                ),

                const SizedBox(width: 10),

                Text(
                  'Analyze Message',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Paste a message below. Sensitive information is handled safely.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: Colors.white54,
                  ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _messageController,
              minLines: 6,
              maxLines: 10,
              maxLength: 5000,
              enabled: !_isAnalyzing,
              decoration:
                  const InputDecoration(
                labelText: 'Message',
                hintText:
                    'Paste or type a message here...\n\nExample: Your account will be blocked. Share your OTP immediately.',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _isAnalyzing
                  ? null
                  : _analyzeMessage,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.security_rounded,
                    ),
              label: Text(
                _isAnalyzing
                    ? 'Analyzing Message...'
                    : 'Analyze Message',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1720),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF8F3045),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF7185),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFFFC1CA),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101C32),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF263A5D),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF6EA8FF),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'MessageShield provides a risk assessment using machine learning and security signals. Always verify important requests independently.',
              style: TextStyle(
                color: Colors.white70,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisResultCard extends StatelessWidget {
  final MessageAnalysis analysis;

  const _AnalysisResultCard({
    required this.analysis,
  });

  Color get _riskColor {
    switch (analysis.risk.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFF5C70);

      case 'MEDIUM':
        return const Color(0xFFFFB454);

      case 'LOW':
        return const Color(0xFF42D392);

      default:
        return const Color(0xFF6EA8FF);
    }
  }

  IconData get _riskIcon {
    switch (analysis.risk.toUpperCase()) {
      case 'HIGH':
        return Icons.warning_rounded;

      case 'MEDIUM':
        return Icons.error_outline_rounded;

      case 'LOW':
        return Icons.verified_user_rounded;

      default:
        return Icons.security_rounded;
    }
  }

  String get _riskMessage {
    switch (analysis.risk.toUpperCase()) {
      case 'HIGH':
        return 'This message contains strong indicators of potential fraud or security risk.';

      case 'MEDIUM':
        return 'This message contains suspicious patterns. Verify the request before taking action.';

      case 'LOW':
        return 'No strong scam indicators were detected. Continue to use normal caution.';

      default:
        return 'Risk assessment completed.';
    }
  }

  String _formatSignal(String signal) {
    return signal
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final confidencePercent =
        (analysis.confidence * 100)
            .toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _riskColor.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: _riskColor.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _riskColor.withValues(
                        alpha: 0.18,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _riskIcon,
                      color: _riskColor,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${analysis.risk} RISK',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: _riskColor,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _riskMessage,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _buildSectionTitle(
              context,
              icon: Icons.category_outlined,
              title: 'Classification',
            ),

            const SizedBox(height: 10),

            _buildInfoRow(
              context,
              label: 'Category',
              value: analysis.category,
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(
              context,
              icon: Icons.speed_rounded,
              title: 'Risk Score',
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '${analysis.riskScore}',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(
                          color: _riskColor,
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _riskColor.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    analysis.risk,
                    style: TextStyle(
                      color: _riskColor,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(
              context,
              icon: Icons.psychology_outlined,
              title: 'Model Confidence',
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prediction confidence',
                  style: TextStyle(
                    color: Colors.white60,
                  ),
                ),

                Text(
                  '$confidencePercent%',
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: analysis.confidence.clamp(
                  0.0,
                  1.0,
                ),
                minHeight: 10,
                backgroundColor:
                    Colors.white10,
                color: const Color(0xFF4F8CFF),
              ),
            ),

            if (analysis.signals.isNotEmpty) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(
                context,
                icon:
                    Icons.fact_check_outlined,
                title: 'Detected Signals',
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.signals.map(
                  (signal) {
                    return Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF1D2942),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                        border: Border.all(
                          color:
                              const Color(0xFF30415F),
                        ),
                      ),
                      child: Text(
                        _formatSignal(signal),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF6EA8FF),
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101828),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),

          const Spacer(),

          Flexible(
            child: Text(
              value.replaceAll('_', ' '),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}