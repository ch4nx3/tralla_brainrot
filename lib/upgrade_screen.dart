import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'character_provider.dart';
import 'character.dart';
import 'encyclopedia.dart';

class UpgradeScreen extends StatefulWidget {
  final Character character;

  const UpgradeScreen({super.key, required this.character});

  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  String message = '';

  void _upgradeCharacter() {
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );

    if (characterProvider.player.coins < 10) {
      setState(() {
        message = '코인이 부족합니다! (필요: 10 코인)';
      });
      return;
    }

    bool success = characterProvider.upgradeCharacter(widget.character);
    setState(() {
      if (success) {
        message = '강화 성공! ${widget.character.starLevel}성으로 업그레이드되었습니다.';
      } else {
        message = '강화 실패... 다시 시도해보세요.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final characterProvider = Provider.of<CharacterProvider>(context);

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
                  '강화',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              // 캐릭터 정보
              Image.asset(
                widget.character.image,
                width: 120,
                height: 120,
                errorBuilder:
                    (context, error, stackTrace) => const Text(
                      'NO IMAGE',
                      style: TextStyle(color: Colors.white),
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.character.name,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '현재 강화: ${widget.character.starLevel}성',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                '체력: ${widget.character.hp}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                '공격력: ${widget.character.attack}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // 강화 확률 표시
              Text(
                '강화 확률: ${widget.character.starLevel >= 9 ? '최대 레벨' : _getSuccessRate(widget.character.starLevel)}%',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // 현재 코인
              Text(
                '현재 코인: ${characterProvider.player.coins}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // 강화 버튼
              if (widget.character.starLevel < 9)
                ElevatedButton(
                  onPressed: _upgradeCharacter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // 금색 버튼
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    '강화 (10 코인)',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              const SizedBox(height: 20),
              // 상태 메시지
              Text(
                message,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const Spacer(),
              // 확인 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EncyclopediaScreen(),
                      ),
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
                    '확인',
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

  String _getSuccessRate(int starLevel) {
    if (starLevel >= 9) return '0';
    switch (starLevel) {
      case 6:
        return '1'; // 7성
      case 7:
        return '0.5'; // 8성
      case 8:
        return '0.1'; // 9성
      default:
        return ((1.0 - (starLevel * 0.1)) * 100).toStringAsFixed(0);
    }
  }
}
