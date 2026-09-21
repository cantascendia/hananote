import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/core/privacy/native_interaction.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_state.dart';

/// Keeps private routes behind authentication and locks background sessions.
class AuthSessionGuard extends StatefulWidget {
  /// Creates a guard; [enabled] controls automatic background locking only.
  const AuthSessionGuard({
    required this.child,
    required this.onLocked,
    this.enabled = true,
    super.key,
  });

  /// The router content, visible only after local authentication succeeds.
  final Widget child;

  /// Replaces the private navigation stack with the authentication route.
  final VoidCallback onLocked;

  /// Whether leaving the foreground locks an authenticated session.
  final bool enabled;

  @override
  State<AuthSessionGuard> createState() => _AuthSessionGuardState();
}

class _AuthSessionGuardState extends State<AuthSessionGuard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.enabled &&
        !NativeInteraction.isActive &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden)) {
      context.read<AuthCubit>().lockSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous is AuthUnlocked && current is! AuthUnlocked,
      listener: (context, state) => widget.onLocked(),
      child: widget.child,
    );
  }
}
