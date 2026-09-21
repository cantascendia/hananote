import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/auth_redirect.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class _Auth extends MockCubit<AuthState> implements AuthCubit {}

GoRouter _router({required int Function() privateBuilder}) {
  return GoRouter(
    initialLocation: '/private',
    redirect: requireLocalAuthentication,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Text('local-authentication-gate'),
      ),
      GoRoute(
        path: '/private',
        builder: (_, __) {
          privateBuilder();
          return const Text('private-content');
        },
      ),
    ],
  );
}

void main() {
  testWidgets('locked deep link redirects before the private route is built',
      (tester) async {
    final auth = _Auth();
    var privateBuilds = 0;
    when(() => auth.state)
        .thenReturn(const AuthState.locked(biometricAvailable: false));
    final router = _router(privateBuilder: () => privateBuilds++);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('local-authentication-gate'), findsOneWidget);
    expect(find.text('private-content'), findsNothing);
    expect(privateBuilds, 0);
  });

  testWidgets('unlocked deep link reaches the private route', (tester) async {
    final auth = _Auth();
    var privateBuilds = 0;
    when(() => auth.state).thenReturn(const AuthState.unlocked());
    final router = _router(privateBuilder: () => privateBuilds++);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('private-content'), findsOneWidget);
    expect(privateBuilds, 1);
  });
}
