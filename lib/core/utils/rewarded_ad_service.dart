import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  static RewardedAd? _ad;
  static bool _isLoading = false;

  static String get _adUnitId {
    return dotenv.env["REWARDED_UNIT_ID"]!;
  }

  static Future<void> loadAd() async {
    if (_ad != null || _isLoading) return;

    _isLoading = true;

    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
          print("REWARDED AD LOADED");
        },
        onAdFailedToLoad: (err) {
          _ad = null;
          _isLoading = false;
          print("REWARDED AD FAILED TO LOAD");

           print("=== AD LOAD FAILED ===");
  print("Code:    ${err.code}");
  print("Domain:  ${err.domain}");
  print("Message: ${err.message}");
  print("Cause:   ${err.responseInfo}");
        },
      ),
    );
  }


static Future<void> show({
  required void Function() onRewarded,
  required void Function() onClosed,
  required void Function() onUnavailable,
}) async{
  if(_ad == null){
    onUnavailable();
    loadAd();
    return;
  }

  bool didEarnReward = false;

  _ad!.fullScreenContentCallback = FullScreenContentCallback(
    onAdDismissedFullScreenContent: (ad){
      ad.dispose();
      _ad = null;
      loadAd();
      onClosed();
      // onUnavailable();
    }
  );

  await _ad!.show(onUserEarnedReward: (ad, reward){
    didEarnReward = true;
  });
}


}

