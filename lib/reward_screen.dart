import 'package:flutter/material.dart';
import 'character.dart';

class RewardScreen extends StatelessWidget {
  final String rewardResult;

  const RewardScreen({super.key, required this.rewardResult});

  @override
  Widget build(BuildContext context) {
    String rewardType = rewardResult.split(':')[0];
    String rewardValue = rewardResult.split(':')[1];

    Widget rewardWidget;

    switch (rewardType) {
      case 'coin':
        rewardWidget = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/coin.png', width: 100),
            const SizedBox(height: 20),
            Text(
              '$rewardValue 코인을 획득했어요!',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        );
        break;
      case 'gem':
        rewardWidget = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/gem.png', width: 100),
            const SizedBox(height: 20),
            Text(
              '보석 $rewardValue개 획득!',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        );
        break;
      case 'character':
        final character = allCharacters.firstWhere(
          (c) => c.name == rewardValue,
        );
        rewardWidget = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(character.image, width: 150),
            const SizedBox(height: 20),
            Text(
              '${character.name} 획득!',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        );
        break;
      default:
        rewardWidget = const Text(
          '알 수 없는 보상입니다.',
          style: TextStyle(fontSize: 24, color: Colors.white),
        );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '보상 결과',
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(height: 30),
              rewardWidget,
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
