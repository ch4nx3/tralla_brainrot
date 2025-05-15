import 'package:flutter/foundation.dart';
import 'character.dart';
import 'player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class CharacterProvider with ChangeNotifier {
  Character? _selectedCharacter;
  final Player _player = Player();
  int _currentStage = 1;
  int _coins = 9;
  int _gems = 0;
  bool _isAdFree = false;
  int _battleCount = 0;

  CharacterProvider() {
    _initializeDefaultCharacter();
    loadProgress();
  }

  void _initializeDefaultCharacter() {
    if (!_player.ownedCharacters.contains(allCharacters[0])) {
      _player.ownedCharacters.add(allCharacters[0]);
    }
    _selectedCharacter = allCharacters[0];
  }

  Character? get selectedCharacter => _selectedCharacter;
  int get currentStage => _currentStage;
  int get coins => _coins;
  int get gems => _gems;
  bool get isAdFree => _isAdFree;
  int get battleCount => _battleCount;

  Player get player => _player;

  void selectCharacter(Character character) {
    _selectedCharacter = character;
    saveProgress();
    notifyListeners();
  }

  void winBattle(int stage) {
    _battleCount++;
    if (stage == _currentStage) {
      _currentStage++;
    }
    _coins += 10;
    _player.level++;
    _player.boxes.add('Box');
    saveProgress();
    notifyListeners();
  }

  void loseBattle() {
    _battleCount++;
    saveProgress();
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    saveProgress();
    notifyListeners();
  }

  void addGems(int amount) {
    _gems += amount;
    saveProgress();
    notifyListeners();
  }

  void purchaseCoinsWithGems(int gemCost, int coinAmount) {
    if (_gems >= gemCost) {
      _gems -= gemCost;
      _coins += coinAmount;
      saveProgress();
      notifyListeners();
    }
  }

  void setAdFree(bool value) {
    _isAdFree = value;
    saveProgress();
    notifyListeners();
  }

  void setNickname(String nickname) {
    _player.nickname = nickname;
    saveProgress();
    notifyListeners();
  }

  void giveFreeBox() {
    _player.boxes.add('Box');
    saveProgress();
    notifyListeners();
  }

  void useBox() {
    if (_player.boxes.isNotEmpty) {
      _player.boxes.removeLast();
    }
    saveProgress();
    notifyListeners();
  }

  int getCoinReward() {
    final List<int> weighted = [1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9];
    weighted.shuffle();
    return weighted.first;
  }

  String openBoxReward() {
    final rand = Random();
    int roll = rand.nextInt(100);

    if (roll < 79) {
      // 코인 확률: 79%
      int coinAmount = getCoinReward();
      addCoins(coinAmount);
      return 'coin:$coinAmount';
    } else if (roll < 99) {
      // 보석 확률: 20% (79~98)
      addGems(1);
      return 'gem:1';
    } else {
      // 캐릭터 확률: 1% (99)
      List<Character> locked =
          allCharacters
              .where((c) => !_player.ownedCharacters.contains(c))
              .toList();
      if (locked.isNotEmpty) {
        Character randomChar = locked[rand.nextInt(locked.length)];
        _player.ownedCharacters.add(randomChar);
        saveProgress();
        notifyListeners();
        return 'character:${randomChar.name}';
      } else {
        addCoins(5);
        return 'coin:5'; // fallback
      }
    }
  }

  bool purchaseCharacter(Character character, int cost) {
    if (_coins >= cost && !_player.ownedCharacters.contains(character)) {
      _coins -= cost;
      _player.ownedCharacters.add(character);
      saveProgress();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool upgradeCharacter(Character character) {
    const int cost = 10;
    if (_coins < cost) return false;
    double successRate = _getUpgradeRate(character.starLevel);
    bool success = _randomSuccess(successRate);
    _coins -= cost;
    if (success) {
      character.starLevel++;
    }
    saveProgress();
    notifyListeners();
    return success;
  }

  double _getUpgradeRate(int star) {
    switch (star) {
      case 6:
        return 0.01;
      case 7:
        return 0.005;
      case 8:
        return 0.001;
      default:
        return 1.0 - star * 0.1;
    }
  }

  bool _randomSuccess(double rate) {
    return (DateTime.now().millisecondsSinceEpoch % 1000) < (1000 * rate);
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? _coins;
    _gems = prefs.getInt('gems') ?? _gems;
    _player.level = prefs.getInt('level') ?? _player.level;
    _player.nickname = prefs.getString('nickname') ?? '';

    List<String> ownedNames = prefs.getStringList('owned') ?? [];
    _player.ownedCharacters =
        allCharacters.where((c) => ownedNames.contains(c.name)).toList();

    // Ensure the first character (level 1) is always owned
    if (!_player.ownedCharacters.contains(allCharacters[0])) {
      _player.ownedCharacters.add(allCharacters[0]);
    }

    if (_player.ownedCharacters.isNotEmpty) {
      _selectedCharacter = _player.ownedCharacters.first;
    }
    notifyListeners();
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setInt('gems', _gems);
    await prefs.setInt('level', _player.level);
    await prefs.setString('nickname', _player.nickname);
    await prefs.setStringList(
      'owned',
      _player.ownedCharacters.map((c) => c.name).toList(),
    );
  }

  void convertGemsToCoins() {
    if (_player.gems > 0) {
      _player.gems -= 1;
      _player.coins += 10;
      saveProgress();
      notifyListeners();
    }
  }
}
