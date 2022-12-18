import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:translator/translator.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'பாதையறி',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );

  }
}

class Splash extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 8,
      navigateAfterSeconds: new Home(),
      title: new Text('பாதையறி',textScaleFactor: 2,),
      image: new Image.asset('assets/LogoImage.jpg'),
      loadingText: Text("உங்கள் பாதையை அறிந்துகொள்ளுங்கள்"),
      photoSize: 100.0,
      loaderColor: Colors.lightBlue,
    );
  }
}

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

bool _scancheck = false;
String _text = '';
var decodedData;
String tamTransliterations = '';
var translation;
GoogleTranslator translator = GoogleTranslator();
String fintext = '';


class _HomeState extends State<Home> {

  File? _image;
  bool isLoading = false;



  _imgFromCamera() async {
    File image = (await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    ));

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = (await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    ));

    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('புகைப்பட தொகுப்பு'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('ஒளிப்படக்கருவி (கேமரா)'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text('பாதையறி'),),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 32,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.file(
                    _image as File,
                    width: 400,
                    height: 400,
                    fit: BoxFit.fitHeight,
                  ),
                )
                    : Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50)),
                    width: 400,
                    height: 400,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("படத்தை தேர்ந்தெடுக்கவும்"),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(

        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        onPressed: () async {
          setState(() {
            _scancheck = true;

          });
          _text =
          await FlutterTesseractOcr.extractText(_image!.path);
          setState(() {
            _scancheck = false;
          });
          print(_text);
          //_text = _rewriter();
          Navigator.push(context, MaterialPageRoute(builder: (context) => output()), );
        },
        label: Text('மொழிபெயர்'),
      ),
    );
  }
}
class output extends StatefulWidget {
  @override
  _outputState createState() => _outputState();

}
class _outputState extends State<output> {

  late WebScraper webScraper;
  bool loaded = false;
  String txt_uses = '';
  String txt_info = '';
  String txt_directions = '';

  var tamtxt;
  String ttext = '';


  @override
  void initState(){
    super.initState();
    _getdata();
  }
  String New_result = '';
  _getdata() async {
    webScraper = WebScraper('https://www.livechennai.com');
    if (await webScraper.loadWebPage('/'+_text+'.asp')) {
      List<Map<String, dynamic>> result = webScraper.getElement("td", []);
      print("---------------");

      //print(result);
      New_result = result[0]['title'] +'\norigin: ' + result[8]['title'] + '\ndestination:' + result[9]['title'] + '\ntravel duration:' + result[10]['title'] + '\nsub stops:' + result[15]['title'] + ','+ result[17]['title'] + ',' + result[19]['title'] + ','+ result[21]['title'] + ','+ result[23]['title'] + ','+ result[25]['title'] + ','+ result[27]['title'] + ','+ result[29]['title'];
      print(New_result);
      setState(() {
        loaded = true;
        txt_uses = New_result;

      });
    }

    await translator.translate(txt_uses, from: 'en', to: 'ta').then((value){
      setState(() {
        tamtxt = value;
      });
    });
    print(tamtxt);
  }

  FlutterTts Tts = FlutterTts();
  // Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('பாதையறி'),
          backgroundColor: Colors.lightBlue),
      body:

      Container(

        alignment: Alignment.center,

        child: Column(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(child: Text(tamtxt == null ? "தயவுசெய்து காத்திருக்கவும்..." : tamtxt.toString(), textAlign: TextAlign.center,)),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.lightBlue,
                textStyle: const TextStyle(fontSize: 10),
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Home()));
              },
              child: Text('பின் செல்'),
            ),
            TextButton(
              style: TextButton.styleFrom(
              foregroundColor: Colors.lightBlue,
              textStyle: const TextStyle(fontSize: 10),
              ),
              onPressed: () async {
                var isGoodLanguage = await Tts.isLanguageAvailable("ta");
                print(isGoodLanguage);
                await Tts.setLanguage("ta");
                Tts.speak(tamtxt == null ? "தயவுசெய்து காத்திருக்கவும்..." : tamtxt.toString());
                setState(() {

                });
              },
              child: Text('குரல் மூலம் ொழிபெயர்க்க'),
            ),
          ],
        ),
      ),
    );
  }
}
