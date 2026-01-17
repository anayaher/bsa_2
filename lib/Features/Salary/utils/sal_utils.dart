import '../models/salary_model.dart';

class SalaryUtils {
  static int calculatePercent(int basic, int percent) {
    return ((basic * percent) / 100).round();
  }

  static int totalSalary(SalaryModel s) {
    return s.basic +
        s.daAmount +
        s.hraAmount +
        s.ta +
        s.arrears;
  }
}
