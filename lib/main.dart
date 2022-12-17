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


var details = {'paracetamol':'பெயர்: பாராசிப்-500 பாராசிட்டமால் மாத்திரை. \nமருந்தளவு:500 மி.கி. \nபரிந்துரைக்கப்பட்டது: பெரியவருகளுக்கு மட்டும். காய்ச்சல் மற்றும் தலைவலிக்கு ஏற்றது. \n12 வயதுக்குட்பட்ட குழந்தைகளுக்கு மாத்திரை பயன்படுத்த குடாது. ஒவ்வொரு டோஸுக்கும் இடையில் 4 முதல் 6 மணிநேர இடைவெளியை கடைபிடிக்க வேண்டும், மேலும் ஒரு நாளைக்கு 4 மாத்திரைகளுக்கு மேல் எடுக்கக்கூடாது.',
  'cetrizine':'பெயர்: செட்ரிசின். \nமருந்தளவு: 1 மி.கி. \nபரிந்துரைக்கப்பட்டது:  ஒவ்வாமைக்கு இரவு நேரத்தில் எடுத்துக் கொள்ளுங்கள். \nஉணவுடன் அல்லது உணவு இல்லாமலும் எடுத்துக் கொள்ளலாம். மாத்திரையை முழுவதுமாக விழுங்குங்கள். அதை மெல்லவோ அல்லது உடைக்கவோ வேண்டாம். மேலும் 24 மணி நேரத்தில் 10 மில்லி கிராமிற்கு மேல் எடுக்கக்கூடாது. \n6 மாத வயதிற்கு கீழ் உள்ள குழந்தைகளை தவிர மீதி எல்லா வயதினரும் எடுத்துக்கொள்ளலாம்.',
  'meftal':'பெயர்: மெஃப்டல்-500. \nமருந்தளவு: 500 மி.கி. \nபரிந்துரைக்கப்பட்டது: வயிற்று வலிக்கு ஏற்றது. \nமாதவிடாய் வலி மற்றும் பிடிப்புகளின் அறிகுறிகளை நீக்குகிறது. உணவுடன் எடுத்துக் கொள்ளுமாறு பரிந்துரைக்கப்படுகிறது. \n6 மாத வயதிற்கு கீழ் உள்ள குழந்தைகளை தவிர மீதி எல்லா வயதினரும் எடுத்துக்கொள்ளலாம். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம்.',
  'azithromycintablets':'பெயர்: அசித்ரோமைசின். \nமருந்தளவு: 500 மி.கி. \nநுண்ணுயிர்க்கொல்லி மாத்திரையாகும். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம். 5 மாத வயது குழந்தைகளை தவிர அதற்கு மேற்பட்ட குழந்தைகள், பெரியவருகள் எடுத்துக்கொள்ளலாம்.',
  'vominorm':'பெயர்: வொமிநொர்ம். \nபரிந்துரைக்கப்பட்டது: வாந்தி உணர்வை குணப்படுத்த ஏற்றது. \n13 வயதிற்கு கீழ் உள்ள குழந்தைகளை தவிர மீதி எல்லா வயதினரும் எடுத்துக்கொள்ளலாம். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம்.',
  'atorvastatin':'பெயர்: அடோர்வாஸ்டாடின். \nமருந்தளவு:10 மி.கி. \nபரிந்துரைக்கப்பட்டது: கல்லீரல் அல்லது சிறுநீரகப் பிரச்சனை உள்ளவர்கள், கர்ப்பிணிகள், நுரையீரல் நோய் உள்ளவர்கள் இதை எடுத்துக் கொள்ளலாம். \n10 வயதிற்கு கீழ் உள்ள குழந்தைகளை தவிர மீதி எல்லா வயதினரும் எடுத்துக்கொள்ளலாம். கர்ப்பிணிப் பெண்கள் எடுத்துக்கொள்ளலாம்.',
  'omnacortil':'பெயர்: ஓம்னகார்டில். \nமருந்தளவு:5 மி.கி. \nபரிந்துரைக்கப்பட்டது: ஒவ்வாமை, மூட்டு வீக்கம், சுவாச பிரச்சனைகள் கண் நோய்கள், புற்றுநோய், குடல் பிரச்சினைகள் உள்ளவர்கள் எடுத்துக் கொள்ளலாம் \n18 வயதுக்குட்பட்ட குழந்தைகளுக்கு எச்சரிக்கையுடன் பயன்படுத்தப்பட வேண்டும். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம்.',
  'sinarest':'பெயர்: சினாரெஸ்ட். \nமருந்தளவு: பாராசிட்டமால் - 500 மி.கி., ஃபைனிலெஃப்ரின் - 10 மி.கி. மற்றும் குளோர்பெனிரமைன் - 2 மி.கி. சேர்ந்த கலவை.  \nபரிந்துரைக்கப்பட்டது: தும்மல், மூக்கு ஒழுகுதல் / அடைப்பு, காய்ச்சல், தலைவலி, உடல் வலி, நெரிசல் அல்லது கண்களில் நீர் வடிதல் போன்ற ஒவ்வாமை உள்ளவர்கள். \n தொடர்ச்சியாக 7 நாட்களுக்கும் (பெரியவர்களுக்கு), 5 நாட்களுக்கும் (4 வயதுக்கு மேற்பட்ட குழந்தைகளுக்கு) எடுத்துக்கொள்ள வேண்டாம்.கர்ப்பிணிப் பெண்களும் எடுத்துக்கொள்ளலாம்..',
  'pan':'பெயர்: பான்டோபிரசோல் காஸ்ட்ரோ எதிர்ப்பு மாத்திரை (பான்-40). \nமருந்தளவு:40 மி.கி. \nபரிந்துரைக்கப்பட்டது: வயிற்று அமிலத்தை குறைக்க உதவுகிறது. \n 12 வயது மற்றும் அதற்கு மேற்பட்ட பெரியவர்கள் மற்றும் குழந்தைகளுக்கு பரிந்துரைக்கப்படுகிறது. \n ஒரு நாளைக்கு இரண்டு முறை, காலை உணவுக்கு முன் 1 மாத்திரை மற்றும் இரவு உணவிற்கு முன் 1 மாத்திரை எடுத்துக் கொள்ளுங்கள்.கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம்.',
  'zerodol':'பெயர்: ஜீரோடோல். \nமருந்தளவு:10 மி.கி. \nபரிந்துரைக்கப்பட்டது: ஒவ்வாமை, மூட்டு வீக்கம், சுவாச பிரச்சனைகள் கண் நோய்கள், புற்றுநோய், குடல் பிரச்சினைகள் உள்ளவர்கள் எடுத்துக் கொள்ளலாம் \n18 வயதுக்குட்பட்ட குழந்தைகளுக்கு எச்சரிக்கையுடன் பயன்படுத்தப்பட வேண்டும். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம்.',
  'raricap':'பெயர்: ராரிகாப். \nமருந்தளவு:40 மி.கி. \nபரிந்துரைக்கப்பட்டது:இரத்த சோகைக்கு சிகிச்சையளிக்கப் பயன்படுகிறது. பயன்: இரும்புச்சத்து குறைபாட்டை குறைக்கிறது. \n12 வயதிற்குட்பட்ட குழந்தைக்கு கடுமையான மருத்துவ மேற்பார்வையின் கீழ் கொடுக்கப்பட வேண்டும். இந்த மாத்திரைக்கும் இடையே 1-2 மணிநேர இடைவெளியை வைத்திருங்கள். கர்ப்ப காலத்தில் பயன்படுத்த பாதுகாப்பற்றதாக இருக்கலாம். தயவுசெய்து உங்கள் மருத்துவரை அணுகவும்.',
  'okamet':'பெயர்: ஒகமெட். \nமருந்தளவு: 500 மி.கி. \nபரிந்துரைக்கப்பட்டது: அதிகரித்த இரத்த குளுக்கோஸ் அளவைக் குறைக்க எடுத்துக்கொள்ளலாம். \n10 வயதுக்குட்பட்ட குழந்தைகளில் பயன்படுத்தக்கூடாது. கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம். \nமாத்திரையை உணவுடனோ அல்லது உணவு இல்லாமலோ எடுத்துக்கொள்ளப்படலாம். மாத்திரையை முழுவதுமாக விழுங்குங்கள்.',
  'loparet':'பெயர்: லோபரெட். \nமருந்தளவு:2 மி.கி. \nபரிந்துரைக்கப்பட்டது: வயிற்றுப்போக்கை குறைக்க உதவுகிறது. \n9 வயது மற்றும் அதற்கு மேற்பட்டவர்கள் எடுத்துக்கொள்ளலாம். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம். \nமாத்திரையை உணவுடனோ அல்லது உணவு இல்லாமலோ எடுத்துக்கொள்ளப்படலாம். மாத்திரையை முழுவதுமாக விழுங்குங்கள். அதை மெல்லவோ அல்லது உடைக்கவோ வேண்டாம். ',
  'doxofylline':'பெயர்: டோக்ஸோபிலின். \nமருந்தளவு:400 மி.கி. \nபரிந்துரைக்கப்பட்டது: ஆஸ்துமா மற்றும் நாள்பட்ட தடுப்பு நுரையீரல் நோய் அறிகுறிகளைத் தடுக்கவும் சிகிச்சையளிக்கவும் பயன்படுகிறது \n18 வயதுக்குட்பட்ட குழந்தைகளுக்கு எச்சரிக்கையுடன் பயன்படுத்தப்பட வேண்டும். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம்.',
  'theo-asthalin':'பெயர்: தியோ-அஸ்தலின். \nமருந்தளவு: சல்பூட்டமால் 2 மி.கி. மற்றும் தியோபிலின் 100 மி.கி. சேர்ந்த கலவை. \nபரிந்துரைக்கப்பட்டது: ஆஸ்துமா மற்றும் நாள்பட்ட தடுப்பு நுரையீரல் நோய் உள்ளவர்கள் எடுத்துக் கொள்ளலாம். \n2 வயதுக்குட்பட்ட குழந்தைகளுக்கு பரிந்துரைக்கப்படவில்லை. கர்ப்ப காலத்தில் பயன்படுத்த பாதுகாப்பற்றதாக இருக்கலாம். தயவுசெய்து உங்கள் மருத்துவரை அணுகவும்.'
};

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

  // _webcheck() async {
  //    final response = await http.Client().get(
  //        Uri.parse('https://www.apollopharmacy.in/medicine/meftal-spas-tablet'));
  //    final rawUrl =
  //        'https://www.apollopharmacy.in/medicine/meftal-spas-tablet';
  //
  //    final endpoint = rawUrl.replaceAll(r'https://www.apollopharmacy.in', '');
  //    final webScraper = WebScraper('https://www.apollopharmacy.in');
  //    if (await webScraper.loadWebPage(endpoint)) {
  //      //Getting the html document from the response
  //      var document = parser.parse(response.body);
  //      try {
  //        //Scraping the first article title
  //        var responseString1 = webScraper.getElement("div.Pdp_mdContainer__3jrYI > div.PdpWeb_container__aXFbu > div.PdpWeb_medicineDetailsPage__f2CII > div.PdpWeb_medicineDetailsGroup__-jIcW > div.MuiGrid-root > div.MuiGrid-root > div.PdpWeb_whiteBox__3x-ga > div.PdpWeb_productDetailed__2P_5V > div.ProductDetailsGeneric_descListing__2pet9 > h2.H2",
  //        []);
  //
  //        print(responseString1);
  //
  //        //Scraping the second article title
  //        // String data_from_webview =  await flutterWebViewPlugin.evalJavaScript("document.getElementById('#someElement').innerText");
  //        var responseString2 = document
  //            .getElementsByClassName('context-text')[7];
  //            // .children[2]
  //            // .children[0]
  //            // .children[0];
  //
  //        print(responseString2.text.trim());
  //
  //        return responseString1.toString();
  //      }
  //      catch (e) {
  //        return ['', '', 'ERROR!'];
  //      }
  //    } else {
  //      return ['', '', 'ERROR: ${response.statusCode}.'];
  //    }
  //  }

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

  _rewriter(){
    String result = '';
    final  validCharacters = RegExp(r'^[a-zA-Z0-9-]+$');
    String test = _text.toLowerCase();
    test = test.trim();
    test.runes.forEach((int rune) {
    var character=new String.fromCharCode(rune);
    if(validCharacters.hasMatch(character)){
          result = result + character;
    }

    });
    if(result.substring(result.length-1)=='0'){
      return result+'mg-tablet';
    }else{
      return result+'-tablet';
    }
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
          _text = _rewriter();
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

  _getdata()async{
    webScraper = WebScraper('https://www.apollopharmacy.in');
    if(await webScraper.loadWebPage('/medicine/'+_text)) {
      List<Map<String, dynamic>> result = webScraper.getElement(
          "div.ProductDetailsGeneric_txtListing__1g4QG", []);
      print("---------------");

      print(result);
      setState(() {
        loaded = true;
        txt_uses = result[2]["title"] as String;
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
          title: const Text('மருந்தறி'),
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
              child: Text('குரல் மூலம் மொழிபெயர்க்க'),
            ),
          ],
        ),
      ),
    );
  }
}
