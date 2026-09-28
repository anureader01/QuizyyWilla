import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/core/utils/topic_validator.dart';
import 'package:quizbit_2/features/home/topic_repository.dart';

class TopicSubmitResult{
  final bool success;
  final String message;
  TopicSubmitResult(this.success, this.message);
}


class TopicController {
    final TopicRepository _topicRepository;
  TopicController()
    : _topicRepository = TopicRepository(SupabaseService().client);




    Future<TopicSubmitResult> submitTopic(String rawInput) async{
      final topic = rawInput.trim();

      final error = TopicValidator.validate(topic);

      if(error != null){
        return TopicSubmitResult(false, error);
      }
try {
  await _topicRepository.submitTopicCntrl(topic: topic);
  return TopicSubmitResult(true, "Thanks! We'll bring this quiz for you!");
} catch (e) {
  print("TOPIC SUBMIT ERROR $e");
  return TopicSubmitResult(false, "Couldn't submit right now. Please try again");
}
    }
}
