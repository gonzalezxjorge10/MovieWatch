import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/movie_providers.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'home_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;

  static const _screens = [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  Future<void> _onSurpriseMe() async {
    try {
      final movie = await ref.read(tmdbServiceProvider).getRandomMovie();
      if (mounted) context.push('/movie/${movie.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo cargar: ${e.toString()}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _onSurpriseMe,
              backgroundColor: AppColors.primary,
              icon: const Text('🎲', style: TextStyle(fontSize: 20)),
              label: const Text(
                'Sorpréndeme',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded), label: 'Buscar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded), label: 'Favoritos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}
