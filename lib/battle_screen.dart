import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'character_provider.dart';
import 'character.dart';
import 'box_drop_screen.dart';
import 'main.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:io' show Platform;

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  _BattleScreenState createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with SingleTickerProviderStateMixin {
  int playerHP = 100;
  int enemyHP = 0;
  double defenseMultiplier = 1.0;
  bool battleWon = false;
  bool playerHit = false;
  bool enemyHit = false;
  bool isAttacking = false;
  bool skillCooldown = false;
  double skullSize = 0.0;
  double lastEnemyRotationDirection = 0.0;
  int selectedStage = 0;
  Timer? enemyAttackTimer;
  Timer? enemySkillTimer;

  final double basicAttackRotation = 0.01 * math.pi;
  final double skillAttackRotation = 0.2 * math.pi;

  late AnimationController _animationController;
  late Animation<double> _playerRotation;
  late Animation<double> _enemyRotation;
  late AudioPlayer _audioPlayer;
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _playerRotation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(_animationController);
    _enemyRotation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(_animationController);
    _audioPlayer = AudioPlayer();
    _loadInterstitialAd();
    _loadBannerAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy', // 발급받은 Interstitial Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy', // 발급받은 Banner Ad Unit ID로 교체
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _showInterstitialAdIfNeeded() {
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );
    if (characterProvider.battleCount % 2 == 0 &&
        !characterProvider.isAdFree &&
        _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    enemyAttackTimer?.cancel();
    enemySkillTimer?.cancel();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void startBattle(int stage) {
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );
    setState(() {
      selectedStage = stage;
      playerHP = characterProvider.selectedCharacter?.hp ?? 100;
      enemyHP = (100 * (1 + stage * 0.1)).round();
      battleWon = false;
      playerHit = false;
      enemyHit = false;
      isAttacking = false;
      skillCooldown = false;
      skullSize = 0.0;
    });
    enemyAttackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!battleWon && playerHP > 0 && enemyHP > 0) {
        _enemyTurn();
      } else {
        timer.cancel();
      }
    });
    enemySkillTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!battleWon && playerHP > 0 && enemyHP > 0) {
        _enemySkillAttack();
      } else {
        timer.cancel();
      }
    });
  }

  void _animatePlayerAttack(double rotation) {
    setState(() {
      playerHit = true;
    });
    _playerRotation = Tween<double>(
      begin: 0,
      end: rotation,
    ).animate(_animationController);
    _animationController.forward(from: 0).then((_) {
      _animationController.reverse().then((_) {
        setState(() {
          playerHit = false;
        });
      });
    });
  }

  void _animateEnemyHit() {
    setState(() {
      enemyHit = true;
    });
    double newRotation =
        lastEnemyRotationDirection > 0 ? -0.2 * math.pi : 0.2 * math.pi;
    _enemyRotation = Tween<double>(
      begin: 0,
      end: newRotation,
    ).animate(_animationController);
    _animationController.forward(from: 0).then((_) {
      _animationController.reverse().then((_) {
        setState(() {
          enemyHit = false;
        });
      });
    });
  }

  void _animateEnemyAttack() {
    setState(() {
      lastEnemyRotationDirection = 0.2 * math.pi;
    });
    _enemyRotation = Tween<double>(
      begin: 0,
      end: lastEnemyRotationDirection,
    ).animate(_animationController);
    _animationController.forward(from: 0).then((_) {
      _animationController.reverse();
    });
  }

  void _animatePlayerHit() {
    setState(() {
      playerHit = true;
    });
    _playerRotation = Tween<double>(
      begin: 0,
      end: -0.2 * math.pi,
    ).animate(_animationController);
    _animationController.forward(from: 0).then((_) {
      _animationController.reverse().then((_) {
        setState(() {
          playerHit = false;
        });
      });
    });
  }

  void _playSound(String soundPath) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await _audioPlayer.play(AssetSource(soundPath));
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _attackSkill(Character character) async {
    if (isAttacking || skillCooldown) return;
    setState(() {
      isAttacking = true;
      skillCooldown = true;
      enemyHP -= character.attackSkill.damage;
      _animatePlayerAttack(skillAttackRotation);
      _playSound('skill.wav');
      if (enemyHP <= 0) {
        _winBattle();
      } else {
        _animateEnemyHit();
      }
    });

    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      skillCooldown = false;
      isAttacking = false;
    });
  }

  void _defenseSkill(Character character) async {
    if (isAttacking || skillCooldown) return;
    setState(() {
      isAttacking = true;
      skillCooldown = true;
      defenseMultiplier = 1.0 - character.defenseSkill.defense;
      _playSound(character.defenseSkill.sound);
    });

    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      defenseMultiplier = 1.0;
    });

    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      skillCooldown = false;
      isAttacking = false;
    });
  }

  void _enemyTurn() {
    if (battleWon || playerHP <= 0) return;
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );
    int enemyAttack = (2 * (1 + selectedStage * 0.1)).round();
    setState(() {
      playerHP -= (enemyAttack * defenseMultiplier).round();
      _animateEnemyAttack();
      _playSound('enemy_attack.wav');
      if (playerHP <= 0) {
        _loseBattle();
      } else {
        _animatePlayerHit();
      }
    });
  }

  void _enemySkillAttack() {
    if (battleWon || playerHP <= 0) return;
    setState(() {
      playerHP -= (10 * defenseMultiplier).round();
      _animateEnemyAttack();
      _playSound('sahur.wav');
      if (playerHP <= 0) {
        _loseBattle();
      } else {
        _animatePlayerHit();
      }
    });
  }

  void _winBattle() {
    setState(() {
      battleWon = true;
      enemyHP = 0;
    });
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );
    characterProvider.winBattle(selectedStage);
    _showInterstitialAdIfNeeded();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Victory!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BoxDropScreen()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _loseBattle() {
    setState(() {
      playerHP = 0;
    });
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );
    characterProvider.loseBattle();
    _showInterstitialAdIfNeeded();

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        skullSize += 10;
        if (skullSize >= 200) {
          timer.cancel();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('You lose'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      );
                    },
                    child: const Text('Back to Main'),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final characterProvider = Provider.of<CharacterProvider>(context);
    final character = characterProvider.selectedCharacter ?? allCharacters[0];
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (selectedStage == 0) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/space.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final stage = index + 1;
                    final isAccessible =
                        stage <= characterProvider.currentStage;
                    return GestureDetector(
                      onTap: isAccessible ? () => startBattle(stage) : null,
                      child: Opacity(
                        opacity: isAccessible ? 1.0 : 0.5,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey,
                          child: Text(
                            '$stage',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isBannerAdLoaded && _bannerAd != null)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/space.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 20.0,
              bottom: screenHeight * 0.25,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            value: playerHP / character.hp.toDouble(),
                            backgroundColor: Colors.grey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF39FF14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$playerHP/${character.hp}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (!isAttacking &&
                          !battleWon &&
                          playerHP > 0 &&
                          enemyHP > 0) {
                        setState(() {
                          enemyHP -= 1;
                          _animatePlayerAttack(basicAttackRotation);
                          _playSound('attack.wav');
                          _animateEnemyHit();
                          if (enemyHP <= 0) {
                            _winBattle();
                          }
                        });
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _playerRotation.value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            color:
                                playerHit
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.transparent,
                            child: Image.asset(
                              character.image,
                              width: 240,
                              height: 240,
                              errorBuilder:
                                  (context, error, stackTrace) => const Text(
                                    'NO CHARACTER?!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Player HP',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20.0,
              top: screenHeight * 0.5 - 120,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            value: enemyHP / (100 * (1 + selectedStage * 0.1)),
                            backgroundColor: Colors.grey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF39FF14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$enemyHP/${(100 * (1 + selectedStage * 0.1)).round()}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _enemyRotation.value,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          color:
                              enemyHit
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.transparent,
                          child: Image.asset(
                            'assets/tung_tung_tung_tung_sahur.png',
                            width: 120,
                            height: 120,
                            errorBuilder:
                                (context, error, stackTrace) => const Text(
                                  'NO ENEMY?!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Stage $selectedStage',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Row(
                children: [
                  if (!battleWon && playerHP > 0)
                    ElevatedButton(
                      onPressed:
                          skillCooldown ? null : () => _attackSkill(character),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        '${character.attackSkill.name} (${character.attackSkill.damage} DMG)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (!battleWon && playerHP > 0)
                    ElevatedButton(
                      onPressed:
                          skillCooldown ? null : () => _defenseSkill(character),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        '${character.defenseSkill.name} (${(character.defenseSkill.defense * 100).round()}% DEF)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (playerHP <= 0)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: skullSize,
                      height: skullSize,
                      child: const Text(
                        '☠️',
                        style: TextStyle(fontSize: 100, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (skullSize >= 200)
                      const Text(
                        'You lose',
                        style: TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    if (skullSize >= 200) const SizedBox(height: 20),
                    if (skullSize >= 200)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
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
                          'Back',
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                  ],
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (_isBannerAdLoaded && _bannerAd != null)
                    Container(
                      alignment: Alignment.center,
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
