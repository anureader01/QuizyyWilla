class TopicValidator {

  static const _bannedWords = <String>{
"kill", "murder", "suicide"
  };


static String? validate(String input){
  final text = input.trim();

  if(text.isEmpty) return "Please enter a topic";
  if(text.length < 5) return "Topic is too short";
  if(text.length > 50) return "Topic is too long";

  final lower = text.toLowerCase();

  final Realwords = lower.split(RegExp(r'[^a-zA-Z]+')).where((word)=>word.isNotEmpty).toList();

  if(Realwords.isEmpty){
    return "Enter a real topic, not random characters";
  }
  for (var word in Realwords) {
    for (final bad in _bannedWords){
      if(word  == bad || word.startsWith(bad)){
        return "Please choose an approprite topic";
      }
    }
    
  }

  return null;
}
}
