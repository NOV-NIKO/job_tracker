class Job {
  int? id;
  String type; // 'company' 或 'exam'
  String companyName;
  String positionName;
  String location;
  String jobDescription;
  String requirements;
  String salary;
  String platform;
  String link;
  String companyType;
  String fundingStatus;
  String companySize;
  String industry;
  String status;
  // 考试公告相关字段
  String? examName;
  DateTime? examDate;
  String? examSubjects;
  DateTime? interviewDate;
  DateTime? registrationStartDate;
  DateTime? registrationEndDate;
  String? registrationEndTime;
  String? examInfo;
  // 选岗信息相关字段
  String? postName;
  String? postLocation;
  String? unitCode;
  String? postCode;
  int? recruitCount;
  String? interviewRatio;
  // 其他字段
  String? resumeVersion;
  String? interviewFeedback;
  DateTime? applicationDate;
  // 图片路径
  String? imagePath;

  Job({
    this.id,
    required this.type,
    required this.companyName,
    required this.positionName,
    required this.location,
    this.jobDescription = '',
    this.requirements = '',
    this.salary = '',
    this.platform = '',
    this.link = '',
    this.companyType = '',
    this.fundingStatus = '',
    this.companySize = '',
    this.industry = '',
    required this.status,
    this.examName,
    this.examDate,
    this.examSubjects,
    this.interviewDate,
    this.registrationStartDate,
    this.registrationEndDate,
    this.registrationEndTime,
    this.examInfo,
    this.postName,
    this.postLocation,
    this.unitCode,
    this.postCode,
    this.recruitCount,
    this.interviewRatio,
    this.resumeVersion,
    this.interviewFeedback,
    this.applicationDate,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'companyName': companyName,
      'positionName': positionName,
      'location': location,
      'jobDescription': jobDescription,
      'requirements': requirements,
      'salary': salary,
      'platform': platform,
      'link': link,
      'companyType': companyType,
      'fundingStatus': fundingStatus,
      'companySize': companySize,
      'industry': industry,
      'status': status,
      'examName': examName,
      'examDate': examDate?.toIso8601String(),
      'examSubjects': examSubjects,
      'interviewDate': interviewDate?.toIso8601String(),
      'registrationStartDate': registrationStartDate?.toIso8601String(),
      'registrationEndDate': registrationEndDate?.toIso8601String(),
      'registrationEndTime': registrationEndTime,
      'examInfo': examInfo,
      'postName': postName,
      'postLocation': postLocation,
      'unitCode': unitCode,
      'postCode': postCode,
      'recruitCount': recruitCount,
      'interviewRatio': interviewRatio,
      'resumeVersion': resumeVersion,
      'interviewFeedback': interviewFeedback,
      'applicationDate': applicationDate?.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      type: map['type'] ?? 'company',
      companyName: map['companyName'],
      positionName: map['positionName'],
      location: map['location'],
      jobDescription: map['jobDescription'],
      requirements: map['requirements'],
      salary: map['salary'],
      platform: map['platform'],
      link: map['link'],
      companyType: map['companyType'],
      fundingStatus: map['fundingStatus'],
      companySize: map['companySize'],
      industry: map['industry'],
      status: map['status'],
      examName: map['examName'],
      examDate: map['examDate'] != null ? DateTime.parse(map['examDate']) : null,
      examSubjects: map['examSubjects'],
      interviewDate: map['interviewDate'] != null ? DateTime.parse(map['interviewDate']) : null,
      registrationStartDate: map['registrationStartDate'] != null ? DateTime.parse(map['registrationStartDate']) : null,
      registrationEndDate: map['registrationEndDate'] != null ? DateTime.parse(map['registrationEndDate']) : null,
      registrationEndTime: map['registrationEndTime'],
      examInfo: map['examInfo'],
      postName: map['postName'],
      postLocation: map['postLocation'],
      unitCode: map['unitCode'],
      postCode: map['postCode'],
      recruitCount: map['recruitCount'],
      interviewRatio: map['interviewRatio'],
      resumeVersion: map['resumeVersion'],
      interviewFeedback: map['interviewFeedback'],
      applicationDate: map['applicationDate'] != null ? DateTime.parse(map['applicationDate']) : null,
      imagePath: map['imagePath'],
    );
  }
}
