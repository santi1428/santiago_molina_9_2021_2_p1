import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'models/character.dart';
import 'character_details.dart';

void main() {
  runApp(const HarryPotterApp());
}

class HarryPotterApp extends StatelessWidget {
  const HarryPotterApp({Key? key}) : super(key: key);
  static const String _title = "Harry Potter's App";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
        home: const CharactersList(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'HarryPotter'));
  }
}

class CharactersList extends StatefulWidget {
  const CharactersList({Key? key}) : super(key: key);

  @override
  _CharactersListState createState() => _CharactersListState();
}

class _CharactersListState extends State<CharactersList> {
  List<dynamic> _listOfCharacters = [];
  bool _isLoadingData = true;
  String _listOfCharactersLength = 'Loading';
  bool _internetConnection = true;
  bool _isFiltered = false;
  String _search = '';

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<bool> checkInternetConnection() async {
    if (await hasNetwork()) {
      return true;
    }
    setState(() {
      _internetConnection = false;
    });
    return false;
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
      _search = '';
    });
  }

  void _filter() {
    if (_search != '') {
      setState(() {
        _isFiltered = true;
      });
    } else {
      setState(() {
        _isFiltered = false;
      });
    }
    Navigator.of(context).pop();
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text('Filter caracters'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Type the character\'s name'),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                        hintText: 'Character\'s name',
                        labelText: 'Search',
                        suffixIcon: Icon(Icons.search)),
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                      });
                    },
                    controller: TextEditingController(text: _search))
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _search = '';
                    });
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => _filter(), child: const Text('Filter')),
            ],
          );
        });
  }

  void fetchData() async {
    if (await checkInternetConnection()) {
      var url =
          Uri.https('hp-api.herokuapp.com', '/api/characters', {'q': '{http}'});
      // Await the http get response, then decode the json-formatted response.
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _listOfCharacters = jsonDecode(response.body);
          _isLoadingData = false;
          _listOfCharactersLength = _listOfCharacters.length.toString();
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
        setState(() {
          _listOfCharacters = [];
          _isLoadingData = false;
          _listOfCharactersLength = '0';
        });
      }
    }
  }

  Widget listOfCharacters() {
    return !_isLoadingData
        ? Expanded(
            child: ListView(
              children: _listOfCharacters
                  .where((c) => Character.fromJson(c)
                      .name
                      .toLowerCase()
                      .contains(_search))
                  .map((c) {
                Character character = Character.fromJson(c);
                return Container(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CharacterDetails(character: character)),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: CachedNetworkImage(
                              imageUrl: character.image == ''
                                  ? 'https://static.thenounproject.com/png/2415889-200.png'
                                  : character.image,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                              height: 70,
                              width: 70,
                              placeholder: (context, url) => const Image(
                                image:
                                    AssetImage('assets/images/placeholder.png'),
                                fit: BoxFit.cover,
                                height: 80,
                                width: 80,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(character.name),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                character.house == ''
                                    ? const Text('')
                                    : Row(
                                        children: <Widget>[
                                          const Text(
                                            'House: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(character.house)
                                        ],
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              _internetConnection == false
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(Icons.signal_wifi_connected_no_internet_4),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Internet connection is required'),
                      ],
                    )
                  : const Text('Loading characters'),
            ],
          );
  }

  Widget header() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Characters: ',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            _internetConnection ? _listOfCharactersLength : '0',
            style: const TextStyle(fontSize: 18),
          )
        ],
      ),
      padding: const EdgeInsets.only(top: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    fetchData();
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xff212529),
          title: const Center(child: Text('Harry Potter\'s characters')),
          actions: <Widget>[
            _isFiltered
                ? IconButton(
                    onPressed: _removeFilter,
                    icon: const Icon(Icons.filter_none))
                : IconButton(
                    onPressed: _showFilter, icon: const Icon(Icons.filter_alt))
          ]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[header(), listOfCharacters()],
      ),
    );
  }
}
