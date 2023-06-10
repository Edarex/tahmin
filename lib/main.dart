import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_cardgame/components/info_card.dart';

class Game {
  final Color hiddenCard = Colors.red;
  List<Color>? gameColors;
  List<String>? gameImg;
  List<Color> cards = [
    Colors.green,
    Colors.yellow,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.blue
  ];
  final String hiddenCardpath = "assets/images/hidden.png";
  List<String> cards_list = [
    "assets/images/circle.png",
    "assets/images/triangle.png",
    "assets/images/circle.png",
    "assets/images/heart.png",
    "assets/images/star.png",
    "assets/images/triangle.png",
    "assets/images/star.png",
    "assets/images/heart.png",
    "assets/images/circle.png",
    "assets/images/heart.png",
    "assets/images/circle.png",
    "assets/images/star.png",
    "assets/images/star.png",
    "assets/images/triangle.png",
    "assets/images/heart.png",
    "assets/images/triangle.png",
  ];
  final int cardCount;

  List<bool> cardFlipped = [];
  List<Map<int, String>> matchCheck = [];

  void resetGame() {
    cardFlipped = List.filled(cardCount, false);
    matchCheck.clear();
  }

  Game({this.cardCount = 8});

  void initGame(void Function() setStateCallback) {
    gameColors = List.generate(cardCount, (index) => cards[index % 6]);
    gameImg = List.generate(
        cardCount, (index) => cards_list[index % cards_list.length]);

    // Gizleme işlemi için 2 saniye bekleyin
    Timer(Duration(seconds: 2), () {
      if (gameColors != null && gameImg != null) {
        gameColors = List.generate(cardCount, (index) => hiddenCard);
        gameImg = List.generate(cardCount, (index) => hiddenCardpath);

        // Durumu güncellemek için setStateCallback kullanın
        setStateCallback();
      }
    });
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hafiza Oyunu',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextStyle whiteText = TextStyle(color: Colors.white);
  bool hideTest = false;
  Game _game = Game();
  bool showNextLevelButton = true;

  //eşleşen kartlara tekrar tıklanmaması için indexlerinin tutulması gerekiyor, onun için bir değişken atadım.
  Set<int> matchedIndexes = {};

  int tries = 0;
  int score = 0;
  int level = 1;

  @override
  void initState() {
    super.initState();
    _game.initGame(() {
      setState(() {});
    });
  }

  void resetGame() {
    setState(() {
      tries = 0;
      score = 0;
      level = 1;
      _game.resetGame();
      _game.initGame(() {
        matchedIndexes.clear(); // matchedIndexes'i temizleme
        setState(() {});
      });
    });
  }

  void nextLevel() {
    if (tries <= 10 && score >= 400) {
      setState(() {
        tries = 0;
        level = 2;
        _game.resetGame();
        matchedIndexes.clear(); // matchedIndexes'i temizleme
        _game = Game(cardCount: 16);
        _game.initGame(() {
          setState(() {});
        });
        showNextLevelButton = false; // Sonraki Bölüm butonunu gizledim
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Hata"),
            content: Text(
                "2. seviyeye geçebilmek için 400 puanı en fazla 10 hamlede tamamlamalısınız."),
            actions: [
              TextButton(
                child: Text("Tamam"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE55870),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Hafıza Oyunu",
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 24.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              info_card("Deneme \n  Sayısı", "$tries"),
              info_card("Toplam \n  Skor", "$score"),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: GridView.builder(
              itemCount: _game.cardCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                if (index < _game.gameImg!.length) {
                  return GestureDetector(
                    onTap: () {
                      print(_game.matchCheck);
                      setState(() {
                        // Eşleşen kutulara bir daha tıklandığında hiçbir şey yapma
                        if (matchedIndexes.contains(index)) {
                          return;
                        }

                        // Deneme sayısını artır
                        tries++;

                        // Kartı aç
                        _game.gameImg![index] = _game.cards_list[index];

                        // Eşleşme kontrolü
                        _game.matchCheck.add({index: _game.cards_list[index]});
                        print(_game.matchCheck.first);
                      });

                      if (_game.matchCheck.length == 2) {
                        if (_game.matchCheck[0].values.first ==
                            _game.matchCheck[1].values.first) {
                          print("true");

                          score += 100;
                          matchedIndexes.add(_game.matchCheck[0].keys.first);
                          matchedIndexes.add(_game.matchCheck[1].keys.first);
                          _game.matchCheck.clear();
                        } else {
                          print("false");

                          Future.delayed(Duration(milliseconds: 500), () {
                            print(_game.gameColors);
                            setState(() {
                              _game.gameImg![_game.matchCheck[0].keys.first] =
                                  _game.hiddenCardpath;
                              _game.gameImg![_game.matchCheck[1].keys.first] =
                                  _game.hiddenCardpath;
                              _game.matchCheck.clear();
                            });
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFB46A),
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: AssetImage(_game.gameImg![index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: resetGame,
                child: Text("Tekrar Dene"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orangeAccent,
                ),
              ),
              SizedBox(width: 16.0),
              if (showNextLevelButton)
                ElevatedButton(
                  onPressed: nextLevel,
                  child: Text("Sonraki Bölüm"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orangeAccent,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
