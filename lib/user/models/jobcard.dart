class JobCard {
  final String accountNo;
  final String dateStarted;
  final String timeStarted;
  final String department;
  final String section;
  final String selectedTaskName;
  final String workLocation;
  final String northings;
  final String eastings;
  final String workStatus;
  final String dateCompleted;
  final String timeCompleted;
  final String workDescription;
  final String material;
  final String assignedWorker;
  final String username;

  JobCard( {
    required this.accountNo,
    required this.dateStarted,
    required this.timeStarted,
    required this.department,
    required this.section,
    required this.selectedTaskName,
    required this.workLocation,
    required this.northings,
    required this.eastings,
    required this.workStatus,
    required this.dateCompleted,
    required this.timeCompleted,
    required this.workDescription,
    required this.material,
    required this.assignedWorker,
    required this.username,
    // Add other fields as needed
  });

  Map<String, dynamic> toMap() {
    return {
      'accountNo': accountNo,
      'dateStarted': dateStarted,
      'timeStarted':timeStarted,
      'department': department,
      'section': section,
      'selectedTaskName': selectedTaskName,
      'workLocation': workLocation,
      'northings': northings,
      'eastings': eastings,
      'workStatus': workStatus,
      'dateCompleted': dateCompleted,
      'timeCompleted':timeCompleted,
      'workDescription': workDescription,
      'material': material,
      'assignedWorker': assignedWorker,

      'username': username,
      // Map other fields as needed
    };
  }
}
