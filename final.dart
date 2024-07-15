import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:untitled5/result.dart';

class StoryScreen extends StatefulWidget {
  final String storyId;

  StoryScreen({required this.storyId});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late Future<Map<String, dynamic>> storyData;

  @override
  void initState() {
    super.initState();
    storyData = fetchStory(widget.storyId);
  }

  Future<Map<String, dynamic>> fetchStory(String storyId) async {
    final response = await http.get(
      Uri.parse('http://3.36.125.253:3000/api/story/$storyId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('스토리를 불러오는 데 실패했습니다');
    }
  }

  Future<Map<String, dynamic>> continueStory(String storyId, int choiceIndex) async {
    final response = await http.post(
      Uri.parse('http://3.36.125.253:3000/api/story/$storyId/continue/$choiceIndex'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('스토리를 이어가는 데 실패했습니다');
    }
  }

  void onOptionSelected(int choiceIndex) {
    setState(() {
      storyData = continueStory(widget.storyId, choiceIndex);
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
                  ...options.asMap().entries.map<Widget>((entry) {
                    int idx = entry.key;
                    String option = entry.value;
                    return ElevatedButton(
                      onPressed: () => onOptionSelected(idx),
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
