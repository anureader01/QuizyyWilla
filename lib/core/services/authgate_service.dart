import 'package:flutter/material.dart';
import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/core/utils/snackbar_helper.dart';
import 'package:quizbit_2/features/auth/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthgateService extends StatelessWidget {
  final Widget? nextScreen;
  const AuthgateService({super.key, required this.nextScreen});

  @override
  Widget build(BuildContext context) {
      final client = SupabaseService().client;
    final session = client.auth.currentSession;
print(session);
    if(session != null){ //USER IS LOGGED IN
return nextScreen!;
    }else{
    return LoginScreen();

    }

  }
}


