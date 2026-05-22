import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupRemoteDataSource {
  final SupabaseClient _client;

  GroupRemoteDataSource({required SupabaseClient client}) : _client = client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('No authenticated Supabase user');
    return id;
  }

  Future<Map<String, dynamic>> fetchDashboard(String groupId) async {
    final userId = _userId;

    // 1. Get group details & members
    final groupData = await _client.from('groups').select('*, members:group_members(user_id)').eq('id', groupId).single();
    final memberIds = (groupData['members'] as List).map((e) => e['user_id']).toList();
    
    // 2. Current User Role
    final currentUserMember = await _client.from('group_members').select().eq('group_id', groupId).eq('user_id', userId).maybeSingle();
    final role = currentUserMember != null ? currentUserMember['role'] : null;

    // 3. Top Streaks
    final topStreaksData = await _client
        .from('streaks')
        .select('user_id, current_streak, profiles(username)')
        .inFilter('user_id', memberIds)
        .order('current_streak', ascending: false)
        .limit(10);

    final List<Map<String, dynamic>> topStreaks = [];
    int rank = 1;
    for (final s in topStreaksData) {
      final username = s['profiles'] != null ? s['profiles']['username'] : 'Unknown';
      topStreaks.add({
        'rank': rank++,
        'username': username ?? 'Unknown',
        'streak': s['current_streak'],
        'isCurrentUser': s['user_id'] == userId,
      });
    }

    // 4. Current user stats
    Map<String, dynamic>? currentUserStats;
    if (currentUserMember != null) {
      final currentStreakData = await _client.from('streaks').select('current_streak').eq('user_id', userId).maybeSingle();
      final streak = currentStreakData != null ? currentStreakData['current_streak'] : 0;
      final myRank = topStreaks.firstWhere((e) => e['isCurrentUser'], orElse: () => {'rank': -1})['rank'];

      final profileData = await _client.from('profiles').select('username').eq('id', userId).maybeSingle();

      currentUserStats = {
        'user_id': userId,
        'username': profileData != null ? profileData['username'] : null,
        'role': currentUserMember['role'],
        'joined_at': currentUserMember['joined_at'],
        'current_streak': streak,
        'rank': myRank > 0 ? myRank : null,
      };
    }

    // 5. Today Completion (Sum of all members for today)
    final today = DateTime.now().toIso8601String().split('T')[0];
    final logsData = await _client
        .from('prayer_logs')
        .select('prayer_name, status')
        .inFilter('user_id', memberIds)
        .eq('date', today);

    int fajr = 0, dhuhr = 0, asr = 0, maghrib = 0, isha = 0;
    for (final log in logsData) {
      if (log['status'] == 'jamaat' || log['status'] == 'alone' || log['status'] == 'late') {
        switch (log['prayer_name']) {
          case 'fajr': fajr++; break;
          case 'dhuhr': dhuhr++; break;
          case 'asr': asr++; break;
          case 'maghrib': maghrib++; break;
          case 'isha': isha++; break;
        }
      }
    }

    // Combine everything
    return {
      'group': {
        'id': groupData['id'],
        'name': groupData['name'],
        'description': groupData['description'],
        'privacy_level': groupData['privacy_level'],
        'member_count': memberIds.length,
        'created_by': groupData['created_by'],
        'user_role': role,
        'invite_code': groupData['invite_code'],
      },
      'current_user': currentUserStats,
      'top_streaks': topStreaks,
      'today_completion': {
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      },
      'recent_activity': await fetchGroupActivity(groupId),
      'stats': {'weekly_completion': 0},
    };
  }

  Future<List<Map<String, dynamic>>> fetchGroupActivity(String groupId) async {
    // Generate dummy activity for now since we don't have an activity table yet
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchMyGroups() async {
    final userId = _userId;
    
    final membersData = await _client.from('group_members').select('group_id, role, groups(*)').eq('user_id', userId);
    
    final List<Map<String, dynamic>> result = [];
    for (final member in membersData) {
      final group = member['groups'];
      // Get member count for this group
      final memberCountData = await _client.from('group_members').select('user_id').eq('group_id', group['id']);
      
      result.add({
        'id': group['id'],
        'name': group['name'],
        'description': group['description'],
        'privacy_level': group['privacy_level'],
        'member_count': memberCountData.length,
        'created_by': group['created_by'],
        'user_role': member['role'],
        'invite_code': group['invite_code'],
      });
    }
    
    return result;
  }

  Future<Map<String, dynamic>> validateInviteCode(String inviteCode) async {
    final group = await _client.from('groups').select().eq('invite_code', inviteCode.toUpperCase()).maybeSingle();
    if (group == null) {
      throw Exception('Invalid invite code');
    }

    // Check if already a member
    final userId = _userId;
    final member = await _client.from('group_members').select().eq('group_id', group['id']).eq('user_id', userId).maybeSingle();

    return {
      'group_id': group['id'],
      'group_name': group['name'],
      'is_already_member': member != null,
    };
  }

  Future<String> joinGroup(String inviteCode) async {
    final userId = _userId;
    
    // Validate again and get group ID
    final group = await _client.from('groups').select().eq('invite_code', inviteCode.toUpperCase()).maybeSingle();
    if (group == null) throw Exception('Invalid invite code');
    
    final groupId = group['id'] as String;

    // Insert member
    await _client.from('group_members').upsert({
      'group_id': groupId,
      'user_id': userId,
      'role': 'member',
    }, onConflict: 'group_id,user_id');

    return groupId;
  }
  
  Future<Map<String, dynamic>> createGroup(String name) async {
    final userId = _userId;
    
    // Generate unique 6-char alphanumeric invite code
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    String inviteCode = '';
    for (var i = 0; i < 6; i++) {
      inviteCode += chars[random.nextInt(chars.length)];
    }

    final group = await _client.from('groups').insert({
      'name': name,
      'created_by': userId,
      'invite_code': inviteCode,
    }).select().single();

    final groupId = group['id'] as String;

    // Add creator as admin
    await _client.from('group_members').insert({
      'group_id': groupId,
      'user_id': userId,
      'role': 'admin',
    });

    return group;
  }
}