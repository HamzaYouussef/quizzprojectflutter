import 'package:flutter/material.dart';
import 'package:voyage/main.dart';
import 'package:voyage/menu/drawer.widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MeteoDetailsPage extends StatefulWidget {
  String ville = "";
  MeteoDetailsPage(this.ville);

  @override
  State<MeteoDetailsPage> createState() => _MeteoDetailsPageState();
}

class _MeteoDetailsPageState extends State<MeteoDetailsPage> {
  var meteoData;

  @override
  void initState() {
    super.initState();
    getMeteoData(widget.ville);
  }

  Future<void> getMeteoData(String ville) async {
    String url =
        "https://api.openweathermap.org/data/2.5/forecast?q=${ville}&appid=c109c07bc4df77a88c923e6407aef864";
    await http.get(Uri.parse(url)).then((resp) {
      setState(() {
        meteoData = json.decode(resp.body);
      });
    }).catchError((err) {
      print(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Détails météo de ${widget.ville}'),
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
      body:
      meteoData == null?
      Center(
        child: CircularProgressIndicator(),
      ):
      Container(
        padding: EdgeInsets.all(12),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
          itemCount: (meteoData == null ? 0 : meteoData['list'].length),
          itemBuilder: (context, index) {
            var forecast = meteoData['list'][index];
            var date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
            var weather = forecast['weather'][0]['main'];
            var temp = (forecast['main']['temp'] - 273.15).toStringAsFixed(1);

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage(
                        "images/${weather.toString().toLowerCase()}.png",
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('E dd MMM yyyy').format(date),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "${DateFormat('HH:mm').format(date)} - $weather",
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "$temp °C",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
