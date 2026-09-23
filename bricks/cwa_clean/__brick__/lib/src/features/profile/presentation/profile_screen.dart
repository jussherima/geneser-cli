{{#with_profile}}import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{project_name}}/src/features/authentication/domain/app_user.dart';
import 'package:{{project_name}}/src/features/authentication/data/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    return Scaffold(appBar: AppBar(title: const Text('Profil')), body: const Center(child: Text('Profile'))); 
  }
}{{/with_profile}}{{^with_profile}}import 'package:flutter/material.dart'; class ProfileScreen extends StatelessWidget { const ProfileScreen({super.key}); @override Widget build(BuildContext c) => const Scaffold(body: Center(child: Text('Profile disabled'))); }{{/with_profile}}
