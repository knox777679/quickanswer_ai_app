
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickAnswer AI',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        primaryColor: Colors.blue[700],
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.black87),
        ),
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue[300],
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrangeAccent,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white70),
        ),
        cardColor: Colors.grey[800],
      ),
      home: HomePage(
        onThemeChanged: toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode themeMode;

  HomePage({required this.onThemeChanged, required this.themeMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String _extractedText = "";
  String _answer = "";
  bool _loading = false;

  final picker = ImagePicker();
  final textRecognizer = TextRecognizer();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _image = File(pickedFile.path);
      _extractedText = "";
      _answer = "";
    });
    await performOCR(_image!);
  }

  Future performOCR(File imageFile) async {
    setState(() {
      _loading = true;
    });
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    setState(() {
      _extractedText = text;
    });
    await queryOpenAI(text);

    setState(() {
      _loading = false;
    });
  }

  Future queryOpenAI(String question) async {
    const apiKey = 'YOUR_OPENAI_API_KEY_HERE';

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");
    final response = await http.post(url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": question}
          ],
          "max_tokens": 200,
          "temperature": 0.5
        }));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String answer = data['choices'][0]['message']['content'];
      setState(() {
        _answer = answer.trim();
      });
    } else {
      setState(() {
        _answer = "Failed to get answer.";
      });
    }
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = widget.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('QuickAnswer AI'),
        actions: [
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              Switch(
                value: isDark,
                onChanged: (value) {
                  widget.onThemeChanged(value);
                },
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            ElevatedButton.icon(
              onPressed: _loading ? null : pickImage,
              icon: Icon(Icons.image),
              label: Text('Pick Question Screenshot'),
            ),
            SizedBox(height: 12),
            if (_image != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.file(_image!, height: 200),
                ),
              ),
            SizedBox(height: 12),
            if (_loading) Center(child: CircularProgressIndicator()),
            if (_extractedText.isNotEmpty) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Extracted Question:',
                          style: Theme.of(context).textTheme.headline6),
                      SizedBox(height: 10),
                      Text(_extractedText),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
            if (_answer.isNotEmpty) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Answer:',
                          style: Theme.of(context).textTheme.headline6),
                      SizedBox(height: 10),
                      Text(_answer),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
