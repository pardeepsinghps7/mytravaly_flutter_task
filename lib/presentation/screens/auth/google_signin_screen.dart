import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 96),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to MyTravaly',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text('Sign in to continue', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 32),

                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is Authenticated) {
                      context.go('/home');
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthInProgress) return const CircularProgressIndicator();
                    return FilledButton.icon(
                      onPressed: () => context.read<AuthBloc>().add(SignInRequested()),
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google (mock)'),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // TextButton(
                //   onPressed: () => context.go('/home'),
                //   child: const Text('Skip (demo)'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
