import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/donation.dart';

/// Centralized service for all Supabase interactions.
///
/// Wraps Supabase client operations for donations, AI assistant, etc.
/// Auth is handled separately via [AuthService].
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Supabase client shortcut.
  SupabaseClient get _client => Supabase.instance.client;

  // ── Donations ──────────────────────────────────────────────────

  /// Fetches all donations from the `donations` table.
  Future<List<Donation>> getDonations() async {
    try {
      final data = await _client
          .from('donations')
          .select()
          .order('created_at', ascending: false);

      return (data as List).map((json) => Donation.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to load donations: ${_friendlyError(e)}');
    }
  }

  /// Creates a new donation row in the `donations` table.
  Future<Donation> createDonation(Donation donation) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final payload = {
        ...donation.toJson(),
        'donor_id': userId,
      };

      final data = await _client
          .from('donations')
          .insert(payload)
          .select()
          .single();

      return Donation.fromJson(data);
    } catch (e) {
      throw ApiException('Failed to create donation: ${_friendlyError(e)}');
    }
  }

  /// Marks a donation as requested by the current user.
  Future<void> requestDonation(int donationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client.from('donations').update({
        'status': 'accepted',
        'recipient_id': userId,
      }).eq('id', donationId);
    } catch (e) {
      throw ApiException('Failed to request donation: ${_friendlyError(e)}');
    }
  }

  // ── AI Assistant ───────────────────────────────────────────────

  /// Sends a message to the AI assistant via Supabase Edge Function.
  ///
  /// Expects an Edge Function named `assistant` that accepts
  /// `{ "message": "..." }` and returns `{ "response": "..." }`.
  Future<String> sendAssistantMessage(String message) async {
    try {
      final response = await _client.functions.invoke(
        'assistant',
        body: {'message': message},
      );

      final data = response.data;
      if (data is Map) {
        return data['response'] ?? data['message'] ?? data['reply'] ?? '';
      }
      return data?.toString() ?? 'No response received.';
    } catch (e) {
      throw ApiException('AI assistant unavailable: ${_friendlyError(e)}');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────

  String _friendlyError(dynamic e) {
    if (e is PostgrestException) return e.message;
    if (e is FunctionException) return e.reasonPhrase ?? 'Edge function error';
    return e.toString();
  }
}

/// Custom exception for API errors with user-friendly messages.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
