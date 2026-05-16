import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/job.dart';

class DatabaseHelper {
  static const _databaseName = "job_tracker.db";
  static const _databaseVersion = 4;

  static const table = 'jobs';

  static const columnId = 'id';
  static const columnType = 'type';
  static const columnCompanyName = 'companyName';
  static const columnPositionName = 'positionName';
  static const columnLocation = 'location';
  static const columnJobDescription = 'jobDescription';
  static const columnRequirements = 'requirements';
  static const columnSalary = 'salary';
  static const columnPlatform = 'platform';
  static const columnLink = 'link';
  static const columnCompanyType = 'companyType';
  static const columnFundingStatus = 'fundingStatus';
  static const columnCompanySize = 'companySize';
  static const columnIndustry = 'industry';
  static const columnStatus = 'status';
  static const columnExamName = 'examName';
  static const columnExamDate = 'examDate';
  static const columnExamSubjects = 'examSubjects';
  static const columnInterviewDate = 'interviewDate';
  static const columnRegistrationStartDate = 'registrationStartDate';
  static const columnRegistrationEndDate = 'registrationEndDate';
  static const columnRegistrationEndTime = 'registrationEndTime';
  static const columnExamInfo = 'examInfo';
  static const columnPostName = 'postName';
  static const columnPostLocation = 'postLocation';
  static const columnUnitCode = 'unitCode';
  static const columnPostCode = 'postCode';
  static const columnRecruitCount = 'recruitCount';
  static const columnInterviewRatio = 'interviewRatio';
  static const columnResumeVersion = 'resumeVersion';
  static const columnInterviewFeedback = 'interviewFeedback';
  static const columnApplicationDate = 'applicationDate';
  static const columnImagePath = 'imagePath';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnType TEXT NOT NULL DEFAULT 'company',
            $columnCompanyName TEXT NOT NULL,
            $columnPositionName TEXT NOT NULL,
            $columnLocation TEXT NOT NULL,
            $columnJobDescription TEXT,
            $columnRequirements TEXT,
            $columnSalary TEXT,
            $columnPlatform TEXT,
            $columnLink TEXT,
            $columnCompanyType TEXT,
            $columnFundingStatus TEXT,
            $columnCompanySize TEXT,
            $columnIndustry TEXT,
            $columnStatus TEXT NOT NULL,
            $columnExamName TEXT,
            $columnExamDate TEXT,
            $columnExamSubjects TEXT,
            $columnInterviewDate TEXT,
            $columnRegistrationStartDate TEXT,
            $columnRegistrationEndDate TEXT,
            $columnRegistrationEndTime TEXT,
            $columnExamInfo TEXT,
            $columnPostName TEXT,
            $columnPostLocation TEXT,
            $columnUnitCode TEXT,
            $columnPostCode TEXT,
            $columnRecruitCount INTEGER,
            $columnInterviewRatio TEXT,
            $columnResumeVersion TEXT,
            $columnInterviewFeedback TEXT,
            $columnApplicationDate TEXT,
            $columnImagePath TEXT
          )
          ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $table ADD COLUMN $columnType TEXT DEFAULT \'company\'');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnExamName TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnExamDate TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnExamInfo TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnPostName TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnPostLocation TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnUnitCode TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnPostCode TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnRecruitCount INTEGER');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnInterviewRatio TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $table ADD COLUMN $columnExamSubjects TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnRegistrationStartDate TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnRegistrationEndDate TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnRegistrationEndTime TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $table ADD COLUMN $columnImagePath TEXT');
    }
  }

  Future<int> insert(Job job) async {
    Database db = await instance.database;
    return await db.insert(table, job.toMap());
  }

  Future<List<Job>> queryAllRows() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) => Job.fromMap(maps[i]));
  }

  Future<List<Job>> queryRowsByStatus(String status) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: "$columnStatus = ?",
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) => Job.fromMap(maps[i]));
  }

  Future<int> update(Job job) async {
    Database db = await instance.database;
    return await db.update(
      table,
      job.toMap(),
      where: "$columnId = ?",
      whereArgs: [job.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateStatus(int id, String status) async {
    Database db = await instance.database;
    return await db.update(
      table,
      {columnStatus: status},
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}
