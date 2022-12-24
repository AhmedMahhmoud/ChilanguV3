import '../user_permessions.dart';

abstract class PermessionAbstract {
  addPermession(UserPermessions userPermessions, String userToken,
      String userId, String permDate);
  getSingleUserPermession(String userToken, String userId);
  getPendingCompanyPermessions(int companyId, String userToken, int pageIndex);
  getFutureSinglePermession(String userToken);
  getPendingPermessionDetailsByID(int permessionId, String token);
  getShiftByShiftId(int shiftId);
}
