import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debate_provider.dart';

class FeedbackPanel extends StatefulWidget {
  const FeedbackPanel({super.key});

  @override
  _FeedbackPanelState createState() => _FeedbackPanelState();
}

class _FeedbackPanelState extends State<FeedbackPanel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DebateProvider>(context, listen: false);
    final userTotal = provider.userTotalScore;
    final avg = (userTotal / provider.totalRounds).toStringAsFixed(1);
    final raw = provider.finalFeedback;

    // Split raw feedback into performance tips
    final analysisTips = raw
        .split(RegExp(r'\d+\.\s*'))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();

    // Collect per-round rephrase suggestions from each DebateArgument
    final rephraseSuggestions = provider.userArguments
        .map((arg) {
          final parts = arg.feedback.split('\n\n');
          return parts.length > 1 ? parts.last.trim() : '';
        })
        .where((s) => s.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Debate Feedback',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF8F6135),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your Score: ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9BE1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$avg/100',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                // Page 1: Performance Analysis
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Performance Analysis',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: analysisTips.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 20, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(analysisTips[i])),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Page 2: Rephrase Suggestions
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How could you say it differently?',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: rephraseSuggestions.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.edit,
                                      size: 20, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(rephraseSuggestions[i])),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dots Indicator
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                2,
                (idx) => AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double selected = 0;
                    if (_pageController.hasClients) {
                      selected = (_pageController.page ?? 0) - idx;
                    }
                    final width = (1 - selected.abs()).clamp(0.0, 1.0) * 16 + 4;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: width,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.completeDebate(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9BE1A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child:
                const Text('Complete Debate', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
