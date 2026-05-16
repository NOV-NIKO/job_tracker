import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../db/database_helper.dart';
import 'auth_service.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;
  static const _jobsCollection = 'jobs';

  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static Future<void> syncJobToCloud(Job job) async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return;

    final jobMap = job.toMap();
    jobMap['userId'] = userId;
    jobMap['createdAt'] = FieldValue.serverTimestamp();

    if (job.id != null) {
      await _firestore.collection(_jobsCollection).doc(job.id.toString()).set(jobMap);
    } else {
      await _firestore.collection(_jobsCollection).add(jobMap);
    }
  }

  static Future<void> deleteJobFromCloud(int jobId) async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection(_jobsCollection).doc(jobId.toString()).delete();
  }

  static Future<List<Job>> loadJobsFromCloud() async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection(_jobsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = int.tryParse(doc.id) ?? 0;
      return Job.fromMap(data);
    }).toList();
  }

  static Future<void> deleteJobFromCloud(int jobId) async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection(_jobsCollection).doc(jobId.toString()).delete();
  }

  static Future<void> syncAllJobsToCloud(List<Job> jobs) async {
    for (final job in jobs) {
      await syncJobToCloud(job);
    }
  }

  static Future<void> syncJobsFromCloud() async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return;

    try {
      // 从云端加载数据
      final cloudJobs = await loadJobsFromCloud();
      
      // 清空本地数据库
      await DatabaseHelper.instance.deleteAll();
      
      // 将云端数据同步到本地
      for (final job in cloudJobs) {
        await DatabaseHelper.instance.insert(job);
      }
      
      print('数据已从云端同步到本地');
    } catch (e) {
      print('同步数据失败: $e');
      throw e;
    }
  }
}
