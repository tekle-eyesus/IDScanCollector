import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  String _result = "";
  bool _isLoading = false;
  String _currentQuote = "";
  String _currentBibleVerse = "";
  String _currentBibleRef = "";
  List<String> _recommendations = [];
// Add this helper function
  List<String> _getRecommendations(
      String emotion, String sentiment, double confidence) {
    final recommendations = <String>[];

    // General stress/anxiety recommendations
    if (emotion.toLowerCase().contains('stress') ||
        emotion.toLowerCase().contains('anxiety')) {
      recommendations.addAll([
        '🌬️ Try 4-7-8 Breathing: Inhale for 4s, hold for 7s, exhale for 8s. Repeat 3x.',
        '🎧 Listen to Calming Music: Tap to play a soothing playlist.',
        '📝 Journaling: Write down 3 things you can control right now.',
      ]);
      if (confidence > 0.7) {
        recommendations.add(
            '💡 High Stress Detected: Consider a 5-minute guided meditation.');
      }
    }

    // Sadness/low mood
    if (sentiment == 'negative' && emotion.toLowerCase().contains('sad')) {
      recommendations.addAll([
        '☀️ Get Sunlight: Step outside for 5 minutes.',
        '📞 Reach Out: Call a trusted friend (tap to suggest contacts).',
        '🎥 Watch Uplifting Video: Tap for a funny/motivational clip.',
      ]);
    }

    // Positive reinforcement
    if (sentiment == 'positive') {
      recommendations.addAll([
        '🌟 Celebrate: Do a small joyful activity (e.g., dance break!).',
        '💌 Gratitude Practice: Write down 3 things you’re grateful for.',
      ]);
    }

    // Default fallback
    if (recommendations.isEmpty) {
      recommendations.addAll([
        '🧘 Mindful Breathing: Focus on your breath for 1 minute.',
        '🚶 Move Your Body: Take a short walk or stretch.',
      ]);
    }

    return recommendations;
  }

  Future<void> _analyzeText() async {
    setState(() => _isLoading = true);

    try {
      // Load API key from .env
      await dotenv.load(fileName: ".env");
      final apiKey = dotenv.env['GEMINI_API_KEY']!;

      // Initialize Gemini
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      // System prompt to enforce JSON output
      // Inside _analyzeText():
      const systemPrompt = '''
Analyze the text and return a JSON object with:
- "sentiment" (positive/neutral/negative)
- "emotion" (e.g., stress, sadness, joy)
- "confidence" (0-1)
- "recommendations" (3 actionable steps)
- "quote" (motivational quote)
- "bible_verse" (a Bible verse and passage addressing the emotion. Example: 
  { 
    "text": "Do not be anxious about anything...", 
    "reference": "Philippians 4:6-7" 
  })

Guidelines:
- Recommendations should vary each time.
- Bible verses should vary each time.
- Bible verses MUST be real and contextually relevant to the emotion and bible verses should vary each time.
- Avoid generic verses (e.g., John 3:16 for stress).
''';

      // Call Gemini API
      final response = await model.generateContent([
        Content.text('$systemPrompt\nUser input: ${_textController.text}'),
      ]);

      // Parse JSON response

// Inside the try block after getting the response:
      final rawText = response.text ?? '{}';
      final cleanedText =
          rawText.replaceAll('```json', '').replaceAll('```', '').trim();

      try {
        final data = jsonDecode(cleanedText);
        final sentiment = data['sentiment'];
        final emotion = data['emotion'];
        final confidence = data['confidence'];
        final recommendations =
            List<String>.from(data['recommendations'] ?? []);
        final quote = data['quote'] ?? "";
        final bibleVerse = data['bible_verse']?['text'] ?? "";
        final bibleReference = data['bible_verse']?['reference'] ?? "";

        setState(() {
          _result = "Emotion: $emotion | Sentiment: $sentiment";
          _recommendations = recommendations;
          _currentQuote = quote;
          _currentBibleVerse = bibleVerse;
          _currentBibleRef = bibleReference;
        });
        //       setState(() {
        //         _result = '''
        //   Emotion: ${data['emotion']}
        //   Sentiment: ${data['sentiment']}
        //   Confidence: ${data['confidence']}
        //   ''';
        //      final bibleVerse = data['bible_verse']?['text'] ?? "";
        //   final bibleReference = data['bible_verse']?['reference'] ?? "";
        //         _recommendations = List<String>.from(data['recommendations'] ?? []);
        //         _currentQuote = data['quote'] ?? "Stay strong!";
        //          _currentBibleVerse = bibleVerse;
        // _currentBibleRef = bibleReference;
        //       });
      } catch (e) {
        setState(() {
          _result = "Error parsing response. Raw output:\n$cleanedText";
        });
      }

      // final text = response.text ?? '{}';

      // final rawText = response.text ?? '{}';
      // final cleanedText =
      //     rawText.replaceAll('```json', '').replaceAll('```', '').trim();
      // final data = jsonDecode(cleanedText);
      // final data = jsonDecode(text);

      // setState(() {
      //   _result = '''
      //   Sentiment: ${data['sentiment']}
      //   Emotion: ${data['emotion']}
      //   Confidence: ${data['confidence']}
      //   ''';
      // });

      // final sentiment = data['sentiment']?.toString() ?? 'neutral';
      // final emotion = data['emotion']?.toString() ?? 'neutral';
      // final confidence = double.tryParse(data['confidence'].toString()) ?? 0.5;

      // setState(() {
      //   _recommendations = _getRecommendations(emotion, sentiment, confidence);
      // });
    } catch (e) {
      print(e);
      setState(() => _result = "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MoodGuardian',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A8DEE), Color(0xFF4B66EA)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded, color: Colors.white),
            onPressed: () {}, // Future profile/account feature
          ),
        ],
        elevation: 8,
        shadowColor: Colors.blue.withOpacity(0.3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 3,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  label: const Text(
                    '🎤 How are you feeling today?',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  hintText: 'Type or speak your thoughts...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            // Add this below the input field (hidden until voice feature is ready)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 0.5, // Indicates coming soon
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(Icons.mic, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Voice input coming soon!',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            //button part
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              bottom: 30,
              right: MediaQuery.of(context).size.width / 2 -
                  40, // Center horizontally
              child: FloatingActionButton.extended(
                onPressed: _isLoading ? null : _analyzeText,
                backgroundColor: const Color(0xFF4B66EA),
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          children: [
                            Icon(Icons.psychology_alt_rounded,
                                color: Colors.white),
                            SizedBox(width: 8),
                            Text('Analyze',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Replace the Text(_result) widget with:
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... existing analysis result ...

                  // Motivational quote
                  // For Quotes
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _currentQuote.isEmpty
                        ? const SizedBox()
                        : Card(
                            margin: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                            color: Colors.blue.withOpacity(0.08),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.format_quote_rounded,
                                          color: Colors.blue[300]),
                                      const Text('  Daily Wisdom',
                                          style: TextStyle(
                                              color: Colors.blueGrey)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _currentQuote,
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),

// For Bible Verse (Same structure with different color scheme)
// Use Colors.green.withOpacity(0.08) and cross icon,

                  if (_currentBibleVerse.isNotEmpty)
                    _buildInspirationCard(
                      '⛪ Bible Verse (${_currentBibleRef})',
                      _currentBibleVerse,
                      backgroundColor: Colors.green[50],
                    ),
                  // Bible Verse
                  // Recommendations list
                  const SizedBox(height: 20),
                  Text("Recommended Actions:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _recommendations.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.emoji_objects),
                          title: Text(_recommendations[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInspirationCard(String title, String text,
      {Color? backgroundColor}) {
    return Card(
      color: backgroundColor ?? Colors.blue[50],
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue[800]),
            ),
            SizedBox(height: 8),
            Text(text, style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
