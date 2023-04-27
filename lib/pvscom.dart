import 'package:flutter/material.dart';
import 'dart:math';

class Psvscom extends StatefulWidget {
  const Psvscom({super.key});

  @override
  _PsvscomScreenState createState() => _PsvscomScreenState();
}

class _PsvscomScreenState extends State<Psvscom> {
  late List<String> _gameState;
  late bool _gameOver;
  late String _currentPlayer;
  late String _winner;
  late bool _isSinglePlayer;
  late bool _isPlayerX;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _gameState = List.filled(9, '');
      _gameOver = false;
      _winner = '';
      _currentPlayer = 'X';
      _isSinglePlayer = true;
      _isPlayerX = true;
    });
  }

  void _onTap(int index) {
    if (!_gameOver && _gameState[index] == '') {
      setState(() {
        _gameState[index] = _currentPlayer;

        if (_checkForWinner()) {
          _gameOver = true;
          _winner = _currentPlayer;
        } else if (!_gameState.contains('')) {
          _gameOver = true;
        } else {
          _currentPlayer = (_currentPlayer == 'X') ? 'O' : 'X';
        }

        if (!_gameOver && _isSinglePlayer && _currentPlayer == 'O') {
          _makeAiMove();
        }
      });
    }
  }

  bool _checkForWinner() {
    // Check rows
    for (int i = 0; i < 9; i += 3) {
      if (_gameState[i] != '' &&
          _gameState[i] == _gameState[i + 1] &&
          _gameState[i] == _gameState[i + 2]) {
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (_gameState[i] != '' &&
          _gameState[i] == _gameState[i + 3] &&
          _gameState[i] == _gameState[i + 6]) {
        return true;
      }
    }

    // Check diagonals
    if (_gameState[0] != '' &&
        _gameState[0] == _gameState[4] &&
        _gameState[0] == _gameState[8]) {
      return true;
    }

    if (_gameState[2] != '' &&
        _gameState[2] == _gameState[4] &&
        _gameState[2] == _gameState[6]) {
      return true;
    }

    return false;
  }

  Widget _buildSquare(int index) {
    return GestureDetector(
      onTap: () => _onTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            _gameState[index],
            style: TextStyle(fontSize: 48.0),
          ),
        ),
      ),
    );
  }

  Future<void> _makeAiMove() async {
// Get a list of all empty squares
    await Future.delayed(Duration(seconds: 2));
    List<int> emptySquares = [];
    for (int i = 0; i < _gameState.length; i++) {
      if (_gameState[i] == '') {
        emptySquares.add(i);
      }
    }
// Randomly select an empty square and update the game state
    int randomIndex = Random().nextInt(emptySquares.length);
    int aiMove = emptySquares[randomIndex];

    setState(() {
      _gameState[aiMove] = 'O';

      if (_checkForWinner()) {
        _gameOver = true;
        _winner = 'O';
      } else if (!_gameState.contains('')) {
        _gameOver = true;
      } else {
        _currentPlayer = 'X';
      }
    });
  }

  void _startSinglePlayer() {
    setState(() {
      _isSinglePlayer = true;
    });
  }

  void _choosePlayerX() {
    setState(() {
      _isPlayerX = true;
      _currentPlayer = 'X';
    });
  }

  void _choosePlayerO() {
    setState(() {
      _isPlayerX = false;
      _currentPlayer = 'O';
      _makeAiMove();
    });
  }

  Widget _buildSinglePlayerOptions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Choose your symbol:',
          style: TextStyle(fontSize: 24.0),
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _choosePlayerX,
              child: Text('X'),
            ),
            SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: _choosePlayerO,
              child: Text('O'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isSinglePlayer) {
      //return _buildSinglePlayerOptions();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: _startSinglePlayer,
          child: null,
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          children: List.generate(9, (index) => _buildSquare(index)),
        ),
        SizedBox(height: 16.0),
        if (_gameOver)
          Text(
            '${_winner} wins!',
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            'Current player: ${_currentPlayer}',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _newGame,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
