import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'models/character.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
              children: _listOfCharacters.map((c) {
                Character character = Character.fromJson(c);
                return Container(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Card(
                    child: InkWell(
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
              SizedBox(
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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[header(), listOfCharacters()],
      ),
    );
  }
}
