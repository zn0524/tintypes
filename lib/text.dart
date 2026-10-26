import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/text_detector.dart';

class TextCheckerScreen extends StatefulWidget {
  const TextCheckerScreen({super.key});

  @override
  State<TextCheckerScreen> createState() => _TextCheckerScreenState();
}

class _TextCheckerScreenState extends State<TextCheckerScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AiDetector _detector = AiDetector();

  bool _modelLoading = true;
  bool _detecting = false;

  String? _error;

  String _aiPercentage = '--%';
  String _realPercentage = '--%';

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      print('AI DETECTOR SCREEN: initializing detector...');

      await _detector.initialize();

      if (!mounted) return;

      setState(() {
        _modelLoading = false;
        _error = null;
      });

      print('AI DETECTOR SCREEN: detector initialized successfully');
    } catch (e, stackTrace) {
      print('AI DETECTOR SCREEN: initialization failed');
      print(e);
      print(stackTrace);

      if (!mounted) return;

      setState(() {
        _modelLoading = false;
        _error = 'Could not load AI detector: $e';
      });
    }
  }

  void _dismissKeyboard() {
    _focusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _detectText() async {
    print('AI DETECTOR SCREEN: Detect button pressed');

    // Close the keyboard as soon as Detect is pressed
    _dismissKeyboard();

    final text = _controller.text.trim();

    print('AI DETECTOR SCREEN: text length = ${text.length}');

    if (text.isEmpty) {
      setState(() {
        _error = 'Please enter some text first.';
      });
      return;
    }

    if (_modelLoading) {
      return;
    }

    setState(() {
      _detecting = true;
      _error = null;
    });

    try {
      print('AI DETECTOR SCREEN: calling detector...');

      final result = await _detector.detect(text);

      print('AI DETECTOR SCREEN: detection finished!');
      print('AI probability: ${result.aiProbability}');
      print('Human probability: ${result.humanProbability}');

      if (!mounted) return;

      setState(() {
        _aiPercentage = '${(result.aiProbability * 100).round()}%';

        _realPercentage = '${(result.humanProbability * 100).round()}%';

        _detecting = false;
      });
    } catch (e, stackTrace) {
      print('AI DETECTOR SCREEN: detection error');
      print(e);
      print(stackTrace);

      if (!mounted) return;

      setState(() {
        _detecting = false;
        _error = 'Detection failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _detector.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tapping anywhere outside the text field closes the keyboard
      behavior: HitTestBehavior.opaque,
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: const Color(0xFF051F20),
        appBar: AppBar(
          title: Text(
            'Check Text',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: const Color(0xFFDAF1DE),
            ),
          ),
          backgroundColor: const Color(0xFF051F20),
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Color(0xFF8EB69B),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            // Dragging/scrolling also closes the keyboard
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Paste some text from an email, article, or essay and see how much of your text was likely written by AI. For the most accuracy please use at least one paragraph of text.',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFDAF1DE),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  // Tapping outside the field (including on buttons) unfocuses it
                  onTapOutside: (_) => _dismissKeyboard(),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFDAF1DE),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'paste some text ...',
                    hintStyle: GoogleFonts.outfit(
                      color: const Color(0xFF8EB69B).withOpacity(0.7),
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0B2B2C),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF8EB69B),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFDAF1DE),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: (_modelLoading || _detecting) ? null : _detectText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8EB69B),
                    foregroundColor: const Color(0xFF051F20),
                    disabledBackgroundColor:
                        const Color(0xFF8EB69B).withOpacity(0.4),
                    disabledForegroundColor:
                        const Color(0xFF051F20).withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _detecting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF051F20),
                          ),
                        )
                      : Text(
                          _modelLoading ? 'Loading model...' : 'Detect',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      _error!,
                      style: GoogleFonts.outfit(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2B2C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF8EB69B).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'AI: $_aiPercentage',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDAF1DE),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: const Color(0xFF8EB69B).withOpacity(0.5),
                      ),
                      Text(
                        'Real: $_realPercentage',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDAF1DE),
                        ),
                      ),
                    ],
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