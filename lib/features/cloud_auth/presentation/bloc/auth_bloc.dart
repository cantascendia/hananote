// HanaNote v2 — AuthBloc.
// Drives the auth state machine: unknown → signedOut / signedIn /
// syncing. Listens to AuthService.authStateChanges for OAuth
// completions and remote sign-out events.
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/core/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.userId, this.email);
  final String userId;
  final String? email;
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

sealed class AuthEvent {
  const AuthEvent();
}

class AuthInitRequested extends AuthEvent {
  const AuthInitRequested();
}

class AuthSignUpEmailRequested extends AuthEvent {
  const AuthSignUpEmailRequested(this.email, this.password);
  final String email;
  final String password;
}

class AuthSignInEmailRequested extends AuthEvent {
  const AuthSignInEmailRequested(this.email, this.password);
  final String email;
  final String password;
}

class AuthSignInAppleRequested extends AuthEvent {
  const AuthSignInAppleRequested();
}

class AuthSignInGoogleRequested extends AuthEvent {
  const AuthSignInGoogleRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthWipeAccountRequested extends AuthEvent {
  const AuthWipeAccountRequested();
}

class _AuthStateChanged extends AuthEvent {
  const _AuthStateChanged(this.user);
  final sb.User? user;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._service) : super(const AuthUnknown()) {
    on<AuthInitRequested>(_onInit);
    on<AuthSignUpEmailRequested>(_onSignUpEmail);
    on<AuthSignInEmailRequested>(_onSignInEmail);
    on<AuthSignInAppleRequested>(_onSignInApple);
    on<AuthSignInGoogleRequested>(_onSignInGoogle);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthWipeAccountRequested>(_onWipe);
    on<_AuthStateChanged>(_onChanged);

    if (_service.isCloudEnabled) {
      _sub = _service.authStateChanges.listen((s) {
        add(_AuthStateChanged(s.session?.user));
      });
    }
  }

  final AuthService _service;
  StreamSubscription<sb.AuthState>? _sub;

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }

  AuthState _userToState(sb.User? user) {
    if (user == null) return const AuthSignedOut();
    return AuthSignedIn(user.id, user.email);
  }

  Future<void> _onInit(AuthInitRequested e, Emitter<AuthState> emit) async {
    emit(_userToState(_service.currentUser));
  }

  void _onChanged(_AuthStateChanged e, Emitter<AuthState> emit) {
    emit(_userToState(e.user));
  }

  Future<void> _onSignUpEmail(
    AuthSignUpEmailRequested e,
    Emitter<AuthState> emit,
  ) async {
    final res =
        await _service.signUpWithEmail(email: e.email, password: e.password);
    res.match(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSignedIn(user.id, user.email)),
    );
  }

  Future<void> _onSignInEmail(
    AuthSignInEmailRequested e,
    Emitter<AuthState> emit,
  ) async {
    final res =
        await _service.signInWithEmail(email: e.email, password: e.password);
    res.match(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSignedIn(user.id, user.email)),
    );
  }

  Future<void> _onSignInApple(
    AuthSignInAppleRequested e,
    Emitter<AuthState> emit,
  ) async {
    final res = await _service.signInWithApple();
    res.match(
      (failure) => emit(AuthError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onSignInGoogle(
    AuthSignInGoogleRequested e,
    Emitter<AuthState> emit,
  ) async {
    final res = await _service.signInWithGoogle();
    res.match(
      (failure) => emit(AuthError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onSignOut(
    AuthSignOutRequested e,
    Emitter<AuthState> emit,
  ) async {
    final res = await _service.signOut();
    res.match(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthSignedOut()),
    );
  }

  Future<void> _onWipe(
    AuthWipeAccountRequested e,
    Emitter<AuthState> emit,
  ) async {
    final res = await _service.wipeAccount();
    res.match(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthSignedOut()),
    );
  }
}
