import 'dart:async';
import 'dart:convert';

import 'package:dictionary/models/owlbot.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final String _url = 'https://owlbot.info/api/v4/dictionary/';
  final String _token = '';

  late StreamController<OwlBot> _streamController;
  late Stream<OwlBot> _stream;

  @override
  void initState() {
    super.initState();

    _streamController = StreamController<OwlBot>();
    _stream = _streamController.stream;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.04),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: TextFormField(
                    onChanged: (value) {},
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Search for word',
                      contentPadding: EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _search,
                icon: const Icon(Icons.search, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<OwlBot>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const Center(child: Text('Enter a search word'));
            }

            if (snapshot.data!.errorMessage.isNotEmpty) {
              return Center(child: Text(snapshot.data!.errorMessage));
            }

            return ListView.builder(
              itemCount: snapshot.data!.definitions.length,
              itemBuilder: (context, index) {
                return ListBody(
                  children: [
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot
                                .data!.definitions[index].imageUrl.isEmpty
                            ? Text(snapshot.data!.definitions[index].emoji)
                            : CircleAvatar(
                                backgroundImage: NetworkImage(
                                    snapshot.data!.definitions[index].imageUrl),
                              ),
                        title: Text(
                            '${snapshot.data!.word} (${snapshot.data!.definitions[index].type})'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(snapshot.data!.definitions[index].example),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _search() async {
    if (_controller.text.isEmpty) {
      _streamController.add(OwlBot());
      return;
    }

    http.Response response = await http.get(
      Uri.parse(_url + _controller.text.trim()),
      headers: {
        'Authorization': 'Token $_token',
      },
    );

    debugPrint(response.body);
    switch (response.statusCode) {
      case 200:
        OwlBot obj = OwlBot.fromJson(jsonDecode(response.body));
        _streamController.add(obj);
        break;
      case 401:
        _streamController.add(
          OwlBot(
            errorMessage: 'Invalid token.',
          ),
        );
        break;
      case 404:
        _streamController.add(
          OwlBot(
            errorMessage: 'No definition',
          ),
        );
        break;
      case 429:
        _streamController.add(
          OwlBot(
            errorMessage:
                'Request was throttled. Expected available in 58 seconds',
          ),
        );
        break;
      default:
    }
  }
}
