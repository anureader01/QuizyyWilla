import 'package:quizbit_2/core/utils/lifelineEnum.dart';

class LifeLineSession{
  static Map<LifeLineType, bool> used = {
    LifeLineType.fiftyFifty : false,
    LifeLineType.expertAdvice : false,
    LifeLineType.audiencePoll : false,
    LifeLineType.queHint : false,
  };

  static bool isUsed(LifeLineType type) => used[type] ?? false;

  static void markUsed(LifeLineType type){
    used[type] = true;
  }

  static void reset(){
    used.updateAll((key, value)=> false);
  }


  static List<String> lifeLineUsed() {
    return used.entries.where((entry)=> entry.value == true).map((entry)=> entry.key.name).toList();
  }
}
