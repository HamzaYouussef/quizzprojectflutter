import 'package:flutter/material.dart';
import 'package:voyage/main.dart';
import 'package:voyage/menu/drawer.widget.dart';
import 'package:voyage/pages/meteo-details.page.dart';

class MeteoPage extends StatelessWidget {

  TextEditingController txt_ville = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Météo'),
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
                "Méteo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Choisir une ville.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: txt_ville,
                decoration: InputDecoration(
                  hintText: "Ville",
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),


              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _onGetMeteoDetails(context),
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
  void _onGetMeteoDetails(BuildContext context) {
    String v=txt_ville.text;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MeteoDetailsPage(v)));
    txt_ville.text = "";
  }
}
