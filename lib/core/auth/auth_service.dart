// HanaNote v2 — Auth service.
// Wraps Supabase auth: email+password, OAuth (Apple/Google), session
// state, sign-out. Intentionally thin — the AuthBloc owns the
// state machine; this file just exposes async operations.
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/auth/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AuthFailure {
  const AuthFailure(this.message);
  final String message;
}

class AuthDisabledFailure extends AuthFailure {
  const AuthDisabledFailure()
      : super('Cloud sync is disabled in this build (no SUPABASE_URL).');
}

class AuthInvalidCredentialsFailure extends AuthFailure {
  const AuthInvalidCredentialsFailure(super.message);
}

class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure(super.message);
}

class AuthUnknownFailure extends AuthFailure {
  const AuthUnknownFailure(super.message);
}

class AuthService {
  AuthService();

  /// True if Supabase was configured at compile time.
  bool get isCloudEnabled => HanaSupabase.isConfigured;

  /// The currently signed-in user, or null when signed out / disabled.
  User? get currentUser =>
      isCloudEnabled ? HanaSupabase.client.auth.currentUser : null;

  /// Stream of auth state changes (signedIn / signedOut).
  Stream<AuthState> get authStateChanges => isCloudEnabled
      ? HanaSupabase.client.auth.onAuthStateChange
      : const Stream<AuthState>.empty();

  /// Sign up a new user with email + password.
  Future<Either<AuthFailure, User>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isCloudEnabled) return const Left(AuthDisabledFailure());
    try {
      final res = await HanaSupabase.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        return const Left(AuthUnknownFailure('signUp returned null user'));
      }
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthInvalidCredentialsFailure(e.message));
    } catch (e) {
      return Left(AuthUnknownFailure('$e'));
    }
  }

  /// Sign in with email + password.
  Future<Either<AuthFailure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isCloudEnabled) return const Left(AuthDisabledFailure());
    try {
      final res = await HanaSupabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        return const Left(AuthUnknownFailure('signIn returned null user'));
      }
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthInvalidCredentialsFailure(e.message));
    } catch (e) {
      return Left(AuthUnknownFailure('$e'));
    }
  }

  /// Sign in with Apple (iOS / web). On Android, this falls back to
  /// the OIDC sign-in URL.
  Future<Either<AuthFailure, void>> signInWithApple() async {
    if (!isCloudEnabled) return const Left(AuthDisabledFailure());
    try {
      await HanaSupabase.client.auth.signInWithOAuth(OAuthProvider.apple);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthInvalidCredentialsFailure(e.message));
    } catch (e) {
      return Left(AuthUnknownFailure('$e'));
    }
  }

  /// Sign in with Google (any platform).
  Future<Either<AuthFailure, void>> signInWithGoogle() async {
    if (!isCloudEnabled) return const Left(AuthDisabledFailure());
    try {
      await HanaSupabase.client.auth.signInWithOAuth(OAuthProvider.google);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthInvalidCredentialsFailure(e.message));
    } catch (e) {
      return Left(AuthUnknownFailure('$e'));
    }
  }

  /// Sign out the current user.
  Future<Either<AuthFailure, void>> signOut() async {
    if (!isCloudEnabled) return const Right(null);
    try {
      await HanaSupabase.client.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthUnknownFailure('$e'));
    }
  }

  /// Permanent account deletion via the account-wipe edge function.
  /// Triple-tap-confirmed in the UI. Returns Right(null) on success.
  Future<Either<AuthFailure, void>> wipeAccount() async {
    if (!isCloudEnabled) return const Right(null);
    try {
      await HanaSupabase.client.functions.invoke(
        'account-wipe',
        body: {'confirm': 'YES_DELETE_FOREVER'},
      );
      await HanaSupabase.client.auth.signOut();
      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('account-wipe failed: $e');
      }
      return Left(AuthUnknownFailure('$e'));
    }
  }
}
