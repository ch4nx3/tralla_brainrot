import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'character_provider.dart';
import 'main.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final characterProvider = Provider.of<CharacterProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              '상점',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/gem.png', width: 80),
            const SizedBox(height: 10),
            Text(
              '보석: ${characterProvider.player.gems}',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              '코인: ${characterProvider.player.coins}',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (characterProvider.player.gems >= 1) {
                  characterProvider.addCoins(10);
                  characterProvider.addGems(-1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('보석 1개로 코인 10개 구매!')),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('보석이 부족합니다!')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                '보석 1개 → 코인 10개',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const Spacer(),
            ElevatedButton(
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
                '돌아가기',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
