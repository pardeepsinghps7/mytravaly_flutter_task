
import 'package:bloc/bloc.dart';
// Using google_sign_in package but the UI uses a mock button per task requirement.
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthInProgress());
    try {
      // For the assignment we use a mock-friendly flow: attempt signIn, but UI may skip actual flow.
      final account = await _googleSignIn.signInSilently(); // try silent first
      if (account != null) {
        emit(Authenticated(account.displayName ?? account.email));
      } else {
        // If silent fails, we still treat it as a mocked success for frontend-only demo.
        emit(Authenticated('Demo User'));
      }
    } catch (e) {
      // In case of error, fallback to mock authenticated state (frontend-only)
      emit(Authenticated('Demo User'));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    await _googleSignIn.signOut();
    emit(Unauthenticated());
  }
}
