//TIMER.PERIODIC - SECONDS COUNT - WON't WORK IN BACKGROUND
//CALCULATE TIME - STARTING TIME - END TIME = SECONDS 01:22:30 - 01:22:60 = 30 seconds [RIGHT APPROACH]

class QuizTimer {
  int remainingSeconds;
  DateTime? lastTickTime;
  bool isPaused = false;

  QuizTimer({required this.remainingSeconds});

  void start() {
    lastTickTime = DateTime.now();
  }


  void tick(){
    if(isPaused) return;
    final now = DateTime.now();
    final diff = now.difference(lastTickTime!).inSeconds;

    if(diff>0){
      remainingSeconds -= diff;
      lastTickTime = now;
    }
  }


void pause(){
  tick();
  isPaused = true;
}

void resume(){
  lastTickTime = DateTime.now();
  isPaused = false;
}

  int getRemainingSeconds() {
    tick();
    return remainingSeconds >0 ? remainingSeconds : 0;
  }

  bool isTimeUp() {
    return getRemainingSeconds() <= 0;
  }

  addExtraSeconds(int seconds) {
    remainingSeconds += seconds;
  }

}

