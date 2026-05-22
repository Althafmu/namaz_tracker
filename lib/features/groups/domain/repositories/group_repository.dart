import '../../data/models/group_dashboard_model.dart';

abstract class GroupRepository {
  Future<GroupDashboardModel> getDashboard(String groupId);
  Future<String> joinGroup(String inviteCode);
  Future<List<GroupSummary>> getMyGroups();
  Future<Map<String, dynamic>> createGroup(String name);
  Future<Map<String, dynamic>> validateInviteCode(String inviteCode);
}