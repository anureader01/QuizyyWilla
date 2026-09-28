import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopicRepository {
  final SupabaseClient _client;
  TopicRepository(this._client);

  Future<void> submitTopicCntrl({required String topic}) async {
    final response = await _client
        .from('profile')
        .select('topic_asked')
        .eq('user_id', ProfileSession.profile!.user_id)
        .single();

    final current = (response['topic_asked'] as List)
        .map((e) => e.toString())
        .toList();
    print("current");
    print(current);

    print("topic");
    print(topic);
    print(current.contains(topic));
    if (current.contains(topic)) return;

    current.add(topic);

    await _client
        .from('profile')
        .update({'topic_asked': current})
        .eq('user_id', ProfileSession.profile!.user_id);

    await _client.from('topic_request').insert({
      'profile_id': ProfileSession.profile!.user_id,
      'topic': topic,
    });
  }
}

