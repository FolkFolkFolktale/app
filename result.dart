import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoryScreen extends StatefulWidget {
  final String title;
  final String startSentence;

  StoryScreen({required this.title, required this.startSentence});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late Future<Map<String, dynamic>> storyData;

  @override
  void initState() {
    super.initState();
    storyData = fetchStory(widget.title, widget.startSentence);
  }

  Future<Map<String, dynamic>> fetchStory(String title, String startSentence) async {
    final response = await http.post(
      Uri.parse('http://3.36.125.253:3000/api'), // 백엔드 URL 추가
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'start_sentence': startSentence,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('스토리를 불러오는 데 실패했습니다');
    }
  }

  void onOptionSelected(String option) {
    setState(() {
      storyData = fetchStory(widget.title, option);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이야기 생성'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: storyData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            final imageUrl = data['image_url'];
            final storyText = data['story'];
            final options = data['options'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (imageUrl != null) Image.network(imageUrl),
                  SizedBox(height: 20),
                  Text(
                    storyText,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ...options.map<Widget>((option) {
                    return ElevatedButton(
                      onPressed: () => onOptionSelected(option),
                      child: Text(option),

                    );
                  }).toList(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("이야기 다시 만들기"),

                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
