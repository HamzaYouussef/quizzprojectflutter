import 'package:flutter/material.dart';
import 'package:voyage/main.dart';
import 'package:voyage/menu/drawer.widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GallerieDetailsPage extends StatefulWidget {
  final String q;

  GallerieDetailsPage(this.q);

  @override
  State<GallerieDetailsPage> createState() => _GallerieDetailsPageState();
}

class _GallerieDetailsPageState extends State<GallerieDetailsPage> {
  int currentPage = 1;
  int size = 10;
  List<dynamic> hits = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  int totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getGallerieData(widget.q);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          currentPage < totalPages) {
        currentPage++;
        getGallerieData(widget.q);
      }
    });
  }

  Future<void> getGallerieData(String q) async {
    setState(() {
      isFetchingMore = true;
    });

    final url =
        "https://pixabay.com/api/?key=15646595-375eb91b3408e352760ee72c8&q=$q&page=$currentPage&per_page=$size";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newHits = data['hits'];

        setState(() {
          if (currentPage == 1) hits.clear();
          hits.addAll(newHits);
          totalPages = (data['totalHits'] / size).ceil();
          isLoading = false;
        });
      } else {
        print("Erreur de chargement: ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur: $e");
    } finally {
      setState(() {
        isFetchingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          totalPages == 0
              ? 'Pas de résultats'
              : "${widget.q}, Page $currentPage / $totalPages",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          ListView.builder(
            itemCount: hits.length + (isFetchingMore ? 1 : 0),
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (index == hits.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final item = hits[index];
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.0)),
                        child: Image.network(
                          item['largeImageURL'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          item['tags'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,

                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              child: Icon(Icons.arrow_upward),
              onPressed: () {
                _scrollController.animateTo(0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
