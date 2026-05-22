import '../repositories/group_repository.dart';
import '../../data/models/group_dashboard_model.dart';

class GetDashboardUseCase {
  final GroupRepository repository;

  GetDashboardUseCase(this.repository);

  Future<GroupDashboardModel> call(String groupId) {
    return repository.getDashboard(groupId);
  }
}