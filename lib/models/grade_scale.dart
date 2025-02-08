class GradeScale {
  String grade;
  double points;

  GradeScale({
    required this.grade,
    required this.points,
  });

  Map<String, dynamic> toJson() => {
        'grade': grade,
        'points': points,
      };

  factory GradeScale.fromJson(Map<String, dynamic> json) => GradeScale(
        grade: json['grade'],
        points: json['points'],
      );
}
