import 'package:flutter/material.dart';
import 'package:voyage/main.dart';
import 'package:voyage/menu/drawer.widget.dart';
import 'package:voyage/pages/gallerie-details.page.dart';

class GalleriePage extends StatelessWidget {
  @override
  TextEditingController txt_recherche = new TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('GalleriePage'),
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

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Gallerie",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Effectuez une recherche.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: txt_recherche,
                decoration: InputDecoration(
                  hintText: "Keyword",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),


              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _onGetGallerieDetails(context),
                child: Text(
                  "Chercher",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _onGetGallerieDetails(BuildContext context) {
    String v=txt_recherche.text;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>GallerieDetailsPage(v)));
    txt_recherche.text = "";
  }
}


