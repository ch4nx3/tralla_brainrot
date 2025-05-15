import 'character.dart';

class Player {
  String nickname = '';
  int level = 1;
  int coins = 0;
  int gems = 0;
  List<String> boxes = [];
  List<Character> ownedCharacters = []; // Ensure this is a growable list

  List<Character> getUnlockedCharacters() {
    return allCharacters.where((character) {
      return character.starLevel <= level ~/ 3;
    }).toList();
  }

  void dropBoxes() {
    boxes.add('Box');
  }
}
