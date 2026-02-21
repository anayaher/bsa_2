class HomeState {
  final double totalJama;
  final double totalKharcha;

  final int totalSalary;
  final int totalDeduction;

  final int expiredCount;

  const HomeState({
    required this.totalJama,
    required this.totalKharcha,
    required this.totalSalary,
    required this.totalDeduction,
    required this.expiredCount,
  });

  double get netBalance => totalJama - totalKharcha;
  int get netSalary => totalSalary - totalDeduction;
}
