abstract class UserHolidaysRepo {
  getPendingCompanyHolidays(int companyId, String userToken, int pageIndex);
  getFutureSingleUserHoliday(String userToken);
  getSingleUserHoliday(String userToken, String userId);
}
