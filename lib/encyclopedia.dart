import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'character_provider.dart';
import 'character.dart';
import 'upgrade_screen.dart';
import 'main.dart';

class EncyclopediaScreen extends StatelessWidget {
  const EncyclopediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final characterProvider = Provider.of<CharacterProvider>(context);
    final unlockedCharacters = characterProvider.player.getUnlockedCharacters();
    final ownedCharacters = characterProvider.player.ownedCharacters;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF69B4), Color(0xFF800080)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Encyclopedia',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allCharacters.length,
                  itemBuilder: (context, index) {
                    final character = allCharacters[index];
                    final isUnlocked = unlockedCharacters.contains(character);
                    final isOwned = ownedCharacters.contains(character);
                    final unlockLevel = (index ~/ 3) * 3 + 1;
                    final purchaseCost =
                        index >= 1 && index <= 9
                            ? 30 + (index - 1) * (20 ~/ 8)
                            : null;

                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            isUnlocked
                                ? Image.asset(
                                  character.image,
                                  width: 80,
                                  height: 80,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Text(
                                            'NO IMAGE',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                )
                                : const Icon(
                                  Icons.lock,
                                  size: 80,
                                  color: Colors.white70,
                                ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    character.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    character.description,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Upgrade Level: ${character.starLevel} stars',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isUnlocked
                                        ? 'Unlocked at Level $unlockLevel'
                                        : 'Unlocks at Level $unlockLevel',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (!isOwned && purchaseCost != null)
                                    Text(
                                      'Cost: $purchaseCost coins',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                if (isOwned)
                                  ElevatedButton(
                                    onPressed: () {
                                      characterProvider.selectCharacter(
                                        character,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${character.name} selected',
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                    ),
                                    child: const Text(
                                      'Select',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                if (isOwned) const SizedBox(height: 8),
                                if (isOwned)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => UpgradeScreen(
                                                character: character,
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                    ),
                                    child: const Text(
                                      'Upgrade',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                if (!isOwned &&
                                    purchaseCost != null &&
                                    isUnlocked)
                                  ElevatedButton(
                                    onPressed: () {
                                      bool purchased = characterProvider
                                          .purchaseCharacter(
                                            character,
                                            purchaseCost,
                                          );
                                      if (purchased) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${character.name} purchased!',
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Not enough coins!'),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellow,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                    ),
                                    child: const Text(
                                      'Buy',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Back to Main',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
