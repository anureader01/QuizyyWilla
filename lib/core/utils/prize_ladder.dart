 
 List<int> generatePrizeLadder({required int baseAmount, required double greed_factor, required int total_question}){
  List<int> prizes = [];


  double current = baseAmount.toDouble();

  for (int i=0; i< total_question; i++) {
    prizes.add(current.toInt());
    current = current * greed_factor;
  }

  return prizes.reversed.toList();
}
