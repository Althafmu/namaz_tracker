import '../../data/models/group_dashboard_model.dart';

abstract class GroupRepository {
  Future<GroupDashboardModel> getDashboard(int groupId);
  Future<int> joinGroup(String inviteCode);
  Future<List<GroupSummary>> getMyGroups();
}