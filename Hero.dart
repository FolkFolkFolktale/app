import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:untitled5/final.dart';

class HeroScreen extends StatelessWidget {
  final titleController = TextEditingController();
  final startSentenceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '이로봇',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(147, 24, 190, 1.0),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '제목을 만들어주세요',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(147, 24, 190, 1.0),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '제목을 입력하세요',
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '시작문장을 적어주세요',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(147, 24, 190, 1.0),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
                controller: startSentenceController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '시작문장을 입력하세요',
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final storyId = await createStory(
                  titleController.text,
                  startSentenceController.text,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryScreen(storyId: storyId),
                  ),
                );
              },
              child: Text("이야기 시작하기"),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> createStory(String title, String startSentence) async {
    final response = await http.post(
      Uri.parse('http://3.36.125.253:3000/api/story'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'start_sentence': startSentence,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('스토리를 생성하는 데 실패했습니다');
    }
  }
}
