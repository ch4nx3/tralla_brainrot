import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'character_provider.dart';
import 'main.dart';
import 'reward_screen.dart';
import 'store_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BoxDropScreen extends StatefulWidget {
  const BoxDropScreen({super.key});

  @override
  _BoxDropScreenState createState() => _BoxDropScreenState();
}

class _BoxDropScreenState extends State<BoxDropScreen> {
  bool isOpening = false;
  String rewardMessage = '';
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _canGetExtraReward = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // 테스트 광고 ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          setState(() {
            _isAdLoaded = false;
          });
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _showInterstitialAd(VoidCallback onAdClosed) {
    if (_interstitialAd != null && _isAdLoaded) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          print('InterstitialAd failed to show: $error');
        },
      );
      _interstitialAd!.show();
    } else {
      print('InterstitialAd not loaded yet.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('광고를 로드 중입니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  void openBox() async {
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );
    if (characterProvider.player.boxes.isEmpty || isOpening) return;

    setState(() {
      isOpening = true;
      rewardMessage = '';
      _canGetExtraReward = true; // 상자 열 때마다 추가 보상 가능 상태로 설정
    });

    characterProvider.useBox();
    await Future.delayed(const Duration(seconds: 1));

    String result = characterProvider.openBoxReward();
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RewardScreen(rewardResult: result)),
    ).then((_) {
      setState(() {
        isOpening = false;
      });
    });
  }

  void getExtraReward() {
    if (!_canGetExtraReward) return;

    _showInterstitialAd(() {
      final characterProvider = Provider.of<CharacterProvider>(
        context,
        listen: false,
      );
      String result = characterProvider.openBoxReward();
      setState(() {
        _canGetExtraReward = false; // 추가 보상 횟수 제한
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RewardScreen(rewardResult: result)),
      );
    });
  }

  void getCoinFromAd() {
    _showInterstitialAd(() {
      final characterProvider = Provider.of<CharacterProvider>(
        context,
        listen: false,
      );
      characterProvider.addCoins(10);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('광고 시청으로 코인 10개를 획득했습니다!')));
    });
  }

  void _showOddsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '보상 상자 확률',
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('코인: 79%'),
              Text('보석: 20%'),
              Text('캐릭터: 1%'),
              SizedBox(height: 10),
              Text(
                '※ 캐릭터가 더 이상 잠금 해제할 것이 없을 경우 코인 5개로 대체됩니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(color: Colors.black)),
            ),
          ],
          backgroundColor: Colors.white,
        );
      },
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterProvider = Provider.of<CharacterProvider>(context);
    final boxCount = characterProvider.player.boxes.length;
    final selectedCharacter = characterProvider.selectedCharacter;
    final coins = characterProvider.player.coins;
    final gems = characterProvider.player.gems;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/space.png'),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // 💎 코인, 보석 표시 + 탭하면 스토어 이동
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StoreScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Coins: $coins   ',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Text(
                      'Gems: $gems',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (selectedCharacter != null)
                Image.asset(
                  selectedCharacter.image,
                  width: 200,
                  height: 200,
                  errorBuilder:
                      (context, error, stackTrace) => const SizedBox.shrink(),
                  gaplessPlayback: true,
                ),
              const SizedBox(height: 20),
              Text(
                'Boxes: $boxCount',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 20),
              if (rewardMessage.isNotEmpty)
                Text(
                  rewardMessage,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (boxCount > 0 && !isOpening)
                    GestureDetector(
                      onTap: openBox,
                      child: Image.asset(
                        'assets/box.png',
                        width: 100,
                        height: 100,
                        errorBuilder:
                            (context, error, stackTrace) => const Text(
                              'NO BOX IMAGE?!',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    )
                  else if (isOpening)
                    const Text(
                      'Opening...',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )
                  else
                    const Text(
                      'No boxes available!',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  const SizedBox(width: 20),
                  if (_canGetExtraReward && !isOpening)
                    ElevatedButton(
                      onPressed: getExtraReward,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        '광고 보고 한 번 더',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _showOddsDialog,
                child: const Text(
                  '확률 정보 보기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: getCoinFromAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  '광고 보고 코인 10개 받기',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
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
                  'Back to Main',
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
