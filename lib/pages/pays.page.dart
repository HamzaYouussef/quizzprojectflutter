import 'package:flutter/material.dart';
import 'package:voyage/main.dart';
import 'package:voyage/menu/drawer.widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaysPage extends StatefulWidget {
  @override
  _PaysPageState createState() => _PaysPageState();
}

class _PaysPageState extends State<PaysPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _countries = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Map<int, bool> _expandedStates = {};

  Future<void> _searchCountry() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _expandedStates.clear();
    });

    try {
      final response = await http.get(
        Uri.parse('https://restcountries.com/v2/name/${_searchController.text}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _countries = json.decode(response.body);
          for (int i = 0; i < _countries.length; i++) {
            _expandedStates[i] = false;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Pays non trouvé';
          _countries = [];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de connexion';
        _countries = [];
      });
    }
  }

  Widget _buildCountryCard(dynamic country, int index) {
    final theme = Theme.of(context);
    final isExpanded = _expandedStates[index] ?? false;

    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _expandedStates[index] = !isExpanded;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      country['name'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:  Colors.blue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      country['flags']['png'],
                      width: 80,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.flag, size: 50, color:  Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoRow(Icons.location_city, 'Capitale', country['capital']),
              _buildInfoRow(Icons.map, 'Région', '${country['region']} (${country['subregion']})'),
              _buildInfoRow(Icons.people, 'Population', _formatNumber(country['population'])),
              _buildInfoRow(Icons.terrain, 'Superficie', country['area'] != null ? '${_formatNumber(country['area'])} km²' : 'N/A'),
              _buildInfoRow(Icons.attach_money, 'Monnaie', '${country['currencies'][0]['name']} (${country['currencies'][0]['symbol']})'),
              _buildInfoRow(Icons.language, 'Langues', country['languages'].map((lang) => lang['name']).join(', ')),

              if (isExpanded) ...[
                SizedBox(height: 16),
                _buildInfoRow(Icons.schedule, 'Fuseaux horaires', country['timezones'].join(', ')),
                _buildInfoRow(Icons.code, 'Codes', '${country['alpha2Code']} / ${country['alpha3Code']}'),
                _buildInfoRow(Icons.phone, 'Indicatif', country['callingCodes'].join(', ')),
                _buildInfoRow(Icons.public, 'Domaine internet', country['topLevelDomain'].join(', ')),
                _buildInfoRow(Icons.my_location, 'Coordonnées', 'Lat: ${country['latlng'][0]}, Lng: ${country['latlng'][1]}'),

                if (country['borders']?.isNotEmpty ?? false) ...[
                  SizedBox(height: 16),
                  Text(
                    'Pays frontaliers:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: country['borders']
                        .map<Widget>((border) => Chip(
                      label: Text(border),
                      backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                    ))
                        .toList(),
                  ),
                ],

                SizedBox(height: 16),
                Text(
                  'Traductions:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildTranslationChips(country['translations'], theme),
                ),
              ],

              SizedBox(height: 16),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color:  Colors.blue.withOpacity(0.1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    isExpanded ? 'Réduire' : 'Voir plus de détails',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color:  Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTranslationChips(Map<String, dynamic> translations, ThemeData theme) {
    final List<Widget> chips = [];
    final Map<String, String> languageNames = {
      'de': 'Allemand',
      'es': 'Espagnol',
      'fr': 'Français',
      'ja': 'Japonais',
      'it': 'Italien',
      'br': 'Breton',
      'pt': 'Portugais',
      'nl': 'Néerlandais',
      'hr': 'Croate',
      'fa': 'Persan',
    };

    translations.forEach((key, value) {
      if (value != null && languageNames.containsKey(key)) {
        chips.add(
          Chip(
            label: Text('${languageNames[key]}: $value'),
            backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
          ),
        );
      }
    });

    return chips;
  }

  String _formatNumber(dynamic number) {
    if (number == null) return 'N/A';
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 15,
                ),

                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  TextSpan(
                    text: value.isNotEmpty ? value : 'N/A',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Recherche de pays'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un pays...',
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  suffixIcon: Material(
                    color:  Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                    child: IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: _searchCountry,
                    ),
                  ),
                ),
                onSubmitted: (_) => _searchCountry(),
              ),
            ),
          ),
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation( Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Recherche en cours...',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.red),
                    ),
                    if (_errorMessage == 'Pays non trouvé')
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _errorMessage = '';
                          });
                        },
                        child: Text(
                          'Réessayer',
                          style: TextStyle(color: Colors.blue),
                        ),

                      ),
                  ],
                ),
              ),
            )
          else if (_countries.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.public, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Recherchez un pays',
                        style: theme.textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Entrez le nom d\'un pays pour voir ses informations',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _searchCountry,
                  color:  Colors.blue,
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 16),
                    itemCount: _countries.length,
                    itemBuilder: (context, index) {
                      return _buildCountryCard(_countries[index], index);
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}