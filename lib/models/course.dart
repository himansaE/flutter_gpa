class Course {
  String name;
  double credits;
  String grade;
  String id;

  Course({
    required this.name,
    required this.credits,
    required this.grade,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'credits': credits,
        'grade': grade,
      };

  Course.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        credits = json['credits'],
        grade = json['grade'];

  double get gradePoints {
    switch (grade) {
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.7;
      case 'D+':
        return 1.3;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }
}
