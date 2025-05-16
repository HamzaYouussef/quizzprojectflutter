import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:voyage/pages/quiz.page.dart';
import 'package:voyage/pages/parametres.page.dart';
import 'package:voyage/pages/gallerie.page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomeContentPage(),
    GalleriePage(),
    ParametresPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildElegantNavBar(),
    );
  }

  Widget _buildElegantNavBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6C5CE7),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Performances',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContentPage extends StatefulWidget {
  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> with TickerProviderStateMixin {
  List<TriviaCategory> categories = [];
  Map<String, int> categoryScores = {};
  int lastScore = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _setupAnimations();
    _loadScores();
  }
  void _showQuizOptionsDialog(TriviaCategory category) {
    int questionCount = 10;
    String difficulty = 'medium';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Options du Quiz'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nombre de questions:'),
                Slider(
                  value: questionCount.toDouble(),
                  min: 5,
                  max: 20,
                  divisions: 3,
                  label: questionCount.toString(),
                  onChanged: (value) => setState(() => questionCount = value.toInt()),
                ),
                SizedBox(height: 20),
                Text('Difficulté:'),
                DropdownButton<String>(
                  value: difficulty,
                  items: ['easy', 'medium', 'hard']
                      .map((level) => DropdownMenuItem<String>(
                    value: level,
                    child: Text(level[0].toUpperCase() + level.substring(1)),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => difficulty = value!),
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(
                        category: category,
                        questionCount: questionCount,
                        difficulty: difficulty,
                      ),
                    ),
                  );
                },
                child: Text('Commencer'),
              ),
            ],
          );
        },
      ),
    );
  }
  void _loadScores() {
    setState(() {
      lastScore = 92;
      categoryScores = {
        'General Knowledge': 85,
        'Science': 72,
        'History': 68,
        'Entertainment: Film': 91,
        'Sports': 78,
        'Geography': 82,
        'Art': 65,
        'Mathematics': 88,
      };
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCirc,
      ),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..forward();

    _animationController.forward();
    _slideController.forward();
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categories = (data['trivia_categories'] as List)
            .map((category) => TriviaCategory.fromJson(category))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6C5CE7).withOpacity(0.03),
            Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.only(top: 20.0),
      child: categories.isEmpty
          ? Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 24),
              SlideTransition(
                position: _slideAnimation,
                child: _buildLastScoreCard(),
              ),
              SizedBox(height: 32),
              _buildCategoryScoresSection(),
              SizedBox(height: 32),
              _buildCategoriesSection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastScoreCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Color(0xFF6C5CE7),
              Color(0xFFA29BFE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6C5CE7).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 24,
              top: 24,
              child: Icon(Icons.emoji_events,
                  size: 80,
                  color: Colors.white.withOpacity(0.15)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Nouveau score',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$lastScore',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 0.9,
                          ),
                        ),
                        TextSpan(
                          text: '%',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: lastScore / 100,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${lastScore}% complété',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Excellent travail !',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
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

  Widget _buildCategoryScoresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'Performances',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,


                ),
              ),
              Spacer(),
              Text(
                'Voir tout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 180,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 24, right: 8),
            itemCount: categoryScores.length,
            itemBuilder: (context, index) {
              final category = categoryScores.keys.elementAt(index);
              final score = categoryScores.values.elementAt(index);
              final color = _getCategoryColor(index);

              return AnimatedBuilder(
                animation: _slideController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 40 * (1 - _slideController.value)),
                    child: Opacity(
                      opacity: _slideController.value,
                      child: Transform.scale(
                        scale: 0.9 + _slideController.value * 0.1,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: color.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                _getCategoryIcon(category),
                                color: color,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Flexible(
                            child: Text(
                              _shortenCategoryName(category),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                color: Theme.of(context).textTheme.bodyLarge?.color,

                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '$score%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: score / 100,
                              backgroundColor: color.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Catégories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
        SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(
            height: 135,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlay: true,
            viewportFraction: 0.75,
            autoPlayInterval: Duration(seconds: 4),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            pauseAutoPlayOnTouch: true,
          ),
          items: categories.map((category) {
            final color = _getCategoryColor(categories.indexOf(category) % 6);

            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => _showQuizOptionsDialog(category),
                  child: AnimatedBuilder(
                    animation: _scaleController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + _scaleController.value * 0.2,
                        child: child,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.9),
                                color.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 16,
                                top: 16,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getCategoryIcon(category.name),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Spacer(),
                                    Text(
                                      _shortenCategoryName(category.name),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 6,
                                            color: Colors.black.withOpacity(0.2),
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${(categories.indexOf(category) * 12 + 15)} quiz disponibles',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
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
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
  String _shortenCategoryName(String name) {
    return name
        .replaceAll('Entertainment: ', '')
        .replaceAll('Science: ', '')
        .replaceAll('General ', '');
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Color(0xFF6C5CE7),
      Color(0xFF00B894),
      Color(0xFFFD79A8),
      Color(0xFFFDCB6E),
      Color(0xFF0984E3),
      Color(0xFFE17055),
      Color(0xFF00CEC9),
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Science')) return Icons.science;
    if (category.contains('History')) return Icons.history;
    if (category.contains('Film')) return Icons.movie;
    if (category.contains('Sports')) return Icons.sports;
    if (category.contains('Geography')) return Icons.map;
    if (category.contains('Art')) return Icons.palette;
    if (category.contains('Mathematics')) return Icons.calculate;
    return Icons.menu_book;
  }
}

class TriviaCategory {
  final int id;
  final String name;

  TriviaCategory({required this.id, required this.name});

  factory TriviaCategory.fromJson(Map<String, dynamic> json) {
    return TriviaCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}