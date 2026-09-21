import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_state.dart';

/// Sends every private location through the local authentication gate.
String? requireLocalAuthentication(BuildContext context, GoRouterState state) {
  if (state.uri.path != '/' &&
      context.read<AuthCubit>().state is! AuthUnlocked) {
    return '/';
  }
  return null;
}
