import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:stock_flow/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceRegistrationScreen extends StatefulWidget {
  const VoiceRegistrationScreen({super.key});

  @override
  State<VoiceRegistrationScreen> createState() => _VoiceRegistrationScreenState();
}

class _VoiceRegistrationScreenState extends State<VoiceRegistrationScreen> with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Di algo como: "Registrar entrada de 50 sillas de roble..."';
  double _level = 0.0;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    
    _initSpeech();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Acceso al micrófono denegado')),
            );
            Navigator.pop(context);
          }
          return;
        }
      }

      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => print('onError: $val'),
      );
      
      if (available) {
        _startListening();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El reconocimiento de voz no está disponible')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error initializing speech: $e');
    }
  }

  void _startListening() async {
    await _speech.listen(
      onResult: (val) => setState(() {
        _text = val.recognizedWords;
      }),
      onSoundLevelChange: (level) => setState(() {
        _level = level;
      }),
    );
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _level = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.neutral,
              AppTheme.surfaceVariant.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Spacer(),
              _buildAnimatedMic(),
              const SizedBox(height: 40),
              _buildStatusText(),
              const SizedBox(height: 40),
              _buildTranscriptionCard(),
              const Spacer(),
              _buildStopButton(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              _stopListening();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded, color: AppTheme.textDark, size: 28),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  'IA ACTIVA',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40), // Balance
        ],
      ),
    );
  }

  Widget _buildAnimatedMic() {
    // We use _level to influence the size slightly
    double soundImpact = (_level.abs().clamp(0, 10)) / 10.0;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer sound wave circles
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              double scale = _pulseAnimation.value + (index * 0.2) + (soundImpact * 0.3);
              return Container(
                width: 140 * scale,
                height: 140 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: (0.1 / (index + 1)) * (2.0 - _pulseAnimation.value)),
                    width: 2,
                  ),
                ),
              );
            },
          );
        }),
        
        // Pulsing background color
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            double scale = _pulseAnimation.value + (soundImpact * 0.2);
            return Container(
              width: 160 * scale,
              height: 160 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.05 * (2.0 - _pulseAnimation.value)),
              ),
            );
          },
        ),

        // Main white circle
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.mic_rounded,
              size: 64,
              color: _isListening ? AppTheme.primary : AppTheme.textLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    return Column(
      children: [
        Text(
          _isListening ? 'Escuchando...' : 'Pausado',
          style: GoogleFonts.notoSerif(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'STOCK FLOW VOICE ASSISTANT',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppTheme.textLight,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(28),
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDark.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.format_quote_rounded,
              size: 56,
              color: AppTheme.primary.withValues(alpha: 0.08),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text,
                  style: GoogleFonts.manrope(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    height: 1.6,
                  ),
                ),
                if (_isListening)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: List.generate(3, (index) => _buildAnimatedDot(index)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        double delay = index * 0.2;
        double value = (sin((_dotsController.value * 2 * pi) - (delay * pi)) + 1) / 2;
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withValues(alpha: 0.3 + (0.7 * value)),
          ),
        );
      },
    );
  }

  Widget _buildStopButton() {
    return Column(
      children: [
        GestureDetector(
          onTapUp: (_) {
            _stopListening();
            // Handle logical action here or return text
            Navigator.pop(context, _text);
          },
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB71C1C).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.stop_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'DETENER GRABACIÓN',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFB71C1C),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
