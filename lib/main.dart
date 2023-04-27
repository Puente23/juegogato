import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:gato/pvscom.dart';

import 'appbar.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tres en raya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TicTacToe(),
    );
  }
}

class TicTacToe extends StatefulWidget {
  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  late List<String> _gameState;
  late String _currentPlayer;
  late bool _gameOver;
  String? _winner;
  AudioPlayer audioPlayer = AudioPlayer();
  late AudioCache player;

  //para el audio de background del juego
  ambienton() async {
    String audioasset = "assets/sounds/juego.mp3";
    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    Uint8List audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await audioPlayer.playBytes(audiobytes);
    if (result == 1) {
      //play success
      print("audio is playing.");
    } else {
      print("Error while playing audio.");
    }
  }

  ambientoff() async {
    int result = await audioPlayer.stop();
    if (result == 1) {
      //play success
      print("audio is stopping.");
    } else {
      print("Error while playing audio.");
    }
  }

  //game win
  win() async {
    String audioasset = "assets/sounds/win.wav";
    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    Uint8List audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await audioPlayer.playBytes(audiobytes);
    if (result == 1) {
      //play success
      print("audio is playing.");
    } else {
      print("Error while playing audio.");
    }
  }

  //game empate
  empate() async {
    String audioasset = "assets/sounds/empate.wav";
    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    Uint8List audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await audioPlayer.playBytes(audiobytes);
    if (result == 1) {
      //play success
      print("audio is playing.");
    } else {
      print("Error while playing audio.");
    }
  }

  //game tap del gato
  Future<void> gato() async {
    String audioasset = "assets/sounds/tap.mp3";
    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    Uint8List audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    AudioPlayer audioPlayer = await player.playBytes(audiobytes);
    await Future.delayed(Duration(milliseconds: 700)); // wait for 2 seconds
    audioPlayer.stop();
  }

  @override
  void initState() {
    super.initState();
    _newGame();
    player = AudioCache();
  }

  void _newGame() {
    setState(() {
      _gameState = List.filled(9, '');
      _currentPlayer = 'X';
      _gameOver = false;
      _winner = null;
      ambienton();
    });
  }

  void _onTap(int index) {
    //gato();
    if (!_gameOver && _gameState[index] == '') {
      setState(() {
        _gameState[index] = _currentPlayer;

        // Check for winner
        List<List<int>> winningLines = [
          [0, 1, 2],
          [3, 4, 5],
          [6, 7, 8],
          [0, 3, 6],
          [1, 4, 7],
          [2, 5, 8],
          [0, 4, 8],
          [2, 4, 6],
        ];

        for (var line in winningLines) {
          if (_gameState[line[0]] != '' &&
              _gameState[line[0]] == _gameState[line[1]] &&
              _gameState[line[1]] == _gameState[line[2]]) {
            _gameOver = true;
            _winner = _gameState[line[0]];
            break;
          }
        }

        if (!_gameOver) {
          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  Widget _buildSquare(int index) {
    bool highlight = _winner != null &&
        (_gameState[index] == _winner ||
            (_gameState[index] == '' && _currentPlayer != _winner));
    return GestureDetector(
      onTap: () => _onTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromARGB(255, 143, 143, 143),
            width: 1.0,
          ),
          color: highlight ? Color.fromARGB(255, 95, 89, 33) : null,
        ),
        child: Center(
          child: Text(
            _gameState[index],
            style: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _checkGameOver() {
    // Check if a player has won or the game is tied
    if (_gameOver) {
      // condition for winning
      ambientoff();
      win();
      // play sound when a player wins
    } else if (!_gameOver && _gameState.contains('')) {
      // condition for tie
      // play sound when the game ends in a tie
    } else if (!_gameOver && !_gameState.contains('')) {
      ambientoff();
      empate();
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkGameOver();
    return Scaffold(
      appBar: AnimatedAppBar(),
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/fondo.png'), // Ruta de la imagen de fondo
            fit: BoxFit.cover, // Ajuste de la imagen al contenedor
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: List.generate(9, (index) => _buildSquare(index)),
            ),
            SizedBox(height: 16.0),
            if (_gameOver)
              Text(
                '${_winner} GANO!',
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            if (!_gameOver && _gameState.contains(''))
              Text(
                'Jugador $_currentPlayer elige',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!_gameOver && !_gameState.contains(''))
              Text(
                'Empate!',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _newGame,
              child: Text('Nuevo juego'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TicTacToe(),
    );
  }
}

class TicTacToe extends StatefulWidget {
  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  late List<String> _gameState;
  late String _currentPlayer;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _gameState = List.filled(9, '');
      _currentPlayer = 'X';
    });
  }

  void _onTap(int index) {
    setState(() {
      _gameState[index] = _currentPlayer;
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GridView.builder(
            shrinkWrap: true,
            itemCount: _gameState.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  if (_gameState[index] == '') {
                    _onTap(index);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 153, 152, 152),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _gameState[index],
                      style: TextStyle(
                        fontSize: 48.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            child: Text('New Game'),
            onPressed: _newGame,
          ),
        ],
      ),
    );
  }
}
*/