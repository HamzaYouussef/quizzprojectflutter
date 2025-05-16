import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:voyage/pages/home.page.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:audioplayers/audioplayers.dart'; // Add this import

class QuizPage extends StatefulWidget {
  final TriviaCategory category;
  final int questionCount;
  final String difficulty;

  const QuizPage({
    required this.category,
    required this.questionCount,
    required this.difficulty,
    Key? key,
  }) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  List<dynamic> questions = [];
  bool isLoading = true;
  int currentQuestionIndex = 0;
  int score = 0;
  Timer? _timer;
  int _timeLeft = 30;
  String? _selectedAnswer;
  bool _answerSubmitted = false;
  List<List<String>> shuffledAnswers = [];
  bool _showFeedback = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundLoaded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Couleurs personnalisées
  final Color primaryColor = Color(0xFF6C5CE7);
  final Color secondaryColor = Color(0xFFA29BFE);
  final Color accentColor = Color(0xFFFD79A8);
  final Color backgroundColor = Color(0xFFF8F9FA);
  final Color textColor = Color(0xFF2D3436);

  @override
  void initState() {
    super.initState();

    //_loadSound(); // Add this line
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _fetchQuestions();
  }
  Future<void> _loadSound() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/clap.mp3'));
      await _audioPlayer.resume();

      setState(() {
        _isSoundLoaded = true;
      });
    } catch (e) {
      print('Error loading sound: $e');
    }
  }
  @override
  void dispose() {
    _audioPlayer.dispose(); // Add this line
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _vibrateOnWrongAnswer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if ((prefs.getBool('vibrationEnabled') ?? true) &&
        (await Vibration.hasVibrator() ?? false)) {
      Vibration.vibrate(duration: 500);
    }
  }



  void _playClapSound() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('soundEnabled') ?? true) {
      await _audioPlayer.play(AssetSource('sounds/clap.mp3'));
    }
  }

  final player = AudioPlayer();

  void playSound() async {
    try {
      await player.play(AssetSource('sounds/clap.mp3')); // No "assets/" prefix!
      print("Sound playing!");
    } catch (e) {
      print("Playback failed: $e");
    }
  }

  void _startTimer() {
    _timeLeft = 30;
    _selectedAnswer = null;
    _answerSubmitted = false;
    _showFeedback = false;
    _animationController.reset();
    _animationController.forward();

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          if (!_answerSubmitted) {
            _answerQuestion(false);
          }
        }
      });
    });
  }

  Future<void> _fetchQuestions() async {
    final response = await http.get(Uri.parse(
      'https://opentdb.com/api.php?amount=${widget.questionCount}&category=${widget.category.id}&difficulty=${widget.difficulty.toLowerCase()}',
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        questions = data['results'];
        shuffledAnswers = questions.map((question) {
          final answers = [
            ...question['incorrect_answers'],
            question['correct_answer'],
          ]..shuffle();
          return answers.cast<String>();
        }).toList();
        isLoading = false;
        if (questions.isNotEmpty) {
          _startTimer();
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des questions'),
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _answerQuestion(bool isCorrect) async {
    setState(() {
      _answerSubmitted = true;
      _showFeedback = true;
      if (isCorrect) {
        score++;
        _playClapSound();
      } else {
        _vibrateOnWrongAnswer();
      }
      _timer?.cancel();
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
          _startTimer();
        } else {
          _showResults();
        }
      });
    });
  }


  void _showResults() {
    showDialog(
      context: context,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Quiz Terminé!',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Votre score:',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$score/${questions.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (score == questions.length)
                Text(
                  'Parfait! 🎉',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (score > questions.length / 2)
                Text(
                  'Bien joué! 👍',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 20,
                  ),
                )
              else
                Text(
                  'Essayez encore! 💪',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 20,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(String answer, String correctAnswer) {
    if (!_showFeedback) return primaryColor;

    if (answer == correctAnswer) {
      return Colors.green;
    } else if (answer == _selectedAnswer && answer != correctAnswer) {
      return Colors.red;
    }
    return primaryColor.withOpacity(0.6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1),
                  ],
                ),
                child: Text(
                  '$_timeLeft',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      )
          : questions.isEmpty
          ? Center(
        child: Text(
          'Aucune question disponible',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
          ),
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barre de progression en haut

              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(20),
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: secondaryColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 8,
              ),
              SizedBox(height: 20),
              // Contenu principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Numéro de question en petit à gauche
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Question ${currentQuestionIndex + 1}/${questions.length}',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Carte avec la question
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _decodeHtml(questions[currentQuestionIndex]['question']),
                          style: TextStyle(
                            fontSize: 22,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Boutons de réponse
                    ..._buildAnswerButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnswerButtons() {
    final currentQuestion = questions[currentQuestionIndex];
    final correctAnswer = currentQuestion['correct_answer'];
    final answers = shuffledAnswers[currentQuestionIndex];

    return answers.map((answer) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _getButtonColor(answer, correctAnswer),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (!_answerSubmitted)
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
            ],
          ),
          child: InkWell(
            onTap: _answerSubmitted
                ? null
                : () {
              setState(() {
                _selectedAnswer = answer;
              });
              _answerQuestion(answer == correctAnswer);
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _showFeedback
                        ? answer == correctAnswer
                        ? Icons.check_circle
                        : answer == _selectedAnswer
                        ? Icons.cancel
                        : null
                        : null,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _decodeHtml(answer),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  String _decodeHtml(String htmlString) {
    return htmlString
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}