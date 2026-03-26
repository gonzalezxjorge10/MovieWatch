// IMPORTANT: Run the following SQL in your Supabase SQL editor before using this app.
//
// CREATE TABLE favorites (
//   id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
//   user_id uuid REFERENCES auth.users NOT NULL,
//   movie_id int4 NOT NULL,
//   title text NOT NULL DEFAULT '',
//   poster_path text NOT NULL DEFAULT '',
//   genre_ids int4[] NOT NULL DEFAULT '{}',
//   created_at timestamptz DEFAULT now() NOT NULL,
//   CONSTRAINT favorites_user_movie_unique UNIQUE (user_id, movie_id)
// );
// ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
// CREATE POLICY "Users can manage own favorites" ON favorites USING (auth.uid() = user_id);
//
// CREATE TABLE user_ratings (
//   id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
//   user_id uuid REFERENCES auth.users NOT NULL,
//   movie_id int4 NOT NULL,
//   rating float8 NOT NULL,
//   created_at timestamptz DEFAULT now() NOT NULL,
//   CONSTRAINT user_ratings_user_movie_unique UNIQUE (user_id, movie_id)
// );
// ALTER TABLE user_ratings ENABLE ROW LEVEL SECURITY;
// CREATE POLICY "Users can manage own ratings" ON user_ratings USING (auth.uid() = user_id);
//
// CREATE TABLE watch_history (
//   id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
//   user_id uuid REFERENCES auth.users NOT NULL,
//   movie_id int4 NOT NULL,
//   title text NOT NULL DEFAULT '',
//   poster_path text NOT NULL DEFAULT '',
//   created_at timestamptz DEFAULT now() NOT NULL,
//   CONSTRAINT watch_history_user_movie_unique UNIQUE (user_id, movie_id)
// );
// ALTER TABLE watch_history ENABLE ROW LEVEL SECURITY;
// CREATE POLICY "Users can manage own history" ON watch_history USING (auth.uid() = user_id);

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/movie.dart';
import '../../models/user_movie.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── AUTH ──────────────────────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) =>
      _client.auth.signUp(email: email, password: password);

  Future<void> signOut() => _client.auth.signOut();

  // ── FAVORITES ─────────────────────────────────────────────────────────────

  Future<List<UserMovie>> getFavorites() async {
    final userId = currentUser?.id;
    if (userId == null) return [];
    final data = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => UserMovie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isFavorite(int movieId) async {
    final userId = currentUser?.id;
    if (userId == null) return false;
    final data = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('movie_id', movieId)
        .maybeSingle();
    return data != null;
  }

  Future<void> addFavorite(Movie movie) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await _client.from('favorites').upsert(
      {'user_id': userId, ...movie.toSupabase()},
      onConflict: 'user_id,movie_id',
    );
  }

  Future<void> removeFavorite(int movieId) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('movie_id', movieId);
  }

  // ── RATINGS ───────────────────────────────────────────────────────────────

  Future<double?> getUserRating(int movieId) async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    final data = await _client
        .from('user_ratings')
        .select('rating')
        .eq('user_id', userId)
        .eq('movie_id', movieId)
        .maybeSingle();
    return data != null ? (data['rating'] as num).toDouble() : null;
  }

  Future<void> setRating({
    required int movieId,
    required double rating,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await _client.from('user_ratings').upsert(
      {'user_id': userId, 'movie_id': movieId, 'rating': rating},
      onConflict: 'user_id,movie_id',
    );
  }

  // ── WATCH HISTORY ─────────────────────────────────────────────────────────

  Future<void> addToWatchHistory(Movie movie) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await _client.from('watch_history').upsert(
      {
        'user_id': userId,
        'movie_id': movie.id,
        'title': movie.title,
        'poster_path': movie.posterPath,
        'created_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id,movie_id',
    );
  }

  Future<List<WatchHistory>> getWatchHistory() async {
    final userId = currentUser?.id;
    if (userId == null) return [];
    final data = await _client
        .from('watch_history')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(30);
    return (data as List)
        .map((e) => WatchHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
