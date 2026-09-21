import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/app/auth_session_guard.dart';
import 'package:hananote/core/privacy/native_interaction.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class _Auth extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  testWidgets('background locks; resume cannot implicitly unlock',
      (tester) async {
    final auth = _Auth();
    when(() => auth.state).thenReturn(const AuthState.unlocked());
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp(
          home: AuthSessionGuard(onLocked: () {}, child: const SizedBox()),
        ),
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    verify(auth.lockSession).called(1);
    verifyNever(() => auth.unlock(any()));
    verifyNever(auth.unlockBiometric);
  });

  testWidgets('locking replaces the private navigation stack', (tester) async {
    final auth = _Auth();
    final states = StreamController<AuthState>();
    whenListen(auth, states.stream, initialState: const AuthState.unlocked());
    var redirects = 0;
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp(
          home: AuthSessionGuard(
            onLocked: () => redirects++,
            child: const SizedBox(),
          ),
        ),
      ),
    );
    states.add(const AuthState.locked(biometricAvailable: false));
    await tester.pump();
    expect(redirects, 1);
    await states.close();
  });

  testWidgets('explicitly disabling app lock preserves the warm session',
      (tester) async {
    final auth = _Auth();
    when(() => auth.state).thenReturn(const AuthState.unlocked());
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp(
          home: AuthSessionGuard(
            enabled: false,
            onLocked: () {},
            child: const SizedBox(),
          ),
        ),
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    verifyNever(auth.lockSession);
  });

  testWidgets('an explicit native interaction does not lock the warm session',
      (tester) async {
    final auth = _Auth();
    final nativeResult = Completer<void>();
    when(() => auth.state).thenReturn(const AuthState.unlocked());
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp(
          home: AuthSessionGuard(onLocked: () {}, child: const SizedBox()),
        ),
      ),
    );

    final interaction = NativeInteraction.run(() => nativeResult.future);
    expect(NativeInteraction.isActive, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    verifyNever(auth.lockSession);

    nativeResult.complete();
    await interaction;
    expect(NativeInteraction.isActive, isFalse);
  });

  test('NativeInteraction releases after a successful native result', () async {
    final result = await NativeInteraction.run(() async => 42);

    expect(result, 42);
    expect(NativeInteraction.isActive, isFalse);
  });

  test('NativeInteraction releases after a native failure', () async {
    final interaction = NativeInteraction.run<void>(
      () async => throw StateError('native failure'),
    );

    await expectLater(interaction, throwsStateError);
    expect(NativeInteraction.isActive, isFalse);
  });

  test('NativeInteraction releases after a cancelled native interaction',
      () async {
    final nativeResult = Completer<void>();
    final interaction = NativeInteraction.run(() => nativeResult.future);
    expect(NativeInteraction.isActive, isTrue);

    nativeResult.completeError(StateError('cancelled'));
    await expectLater(interaction, throwsStateError);

    expect(NativeInteraction.isActive, isFalse);
  });
}
