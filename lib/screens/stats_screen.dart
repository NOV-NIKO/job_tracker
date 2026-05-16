import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_tracker/models/job.dart';
import 'package:job_tracker/models/user.dart';
import 'package:job_tracker/db/database_helper.dart';
import 'package:job_tracker/theme/app_theme.dart';
import 'package:job_tracker/components/geometric_background.dart';
import 'home_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<Map<String, dynamic>> _loadStats() async {
    List<Job> jobs = await DatabaseHelper.instance.queryAllRows();
    
    // 计算本周投递量
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    int weeklyApplications = jobs.where((job) => 
      job.applicationDate != null && 
      job.applicationDate!.isAfter(startOfWeek)
    ).length;
    
    // 计算面试率
    int totalApplications = jobs.length;
    int interviewCount = jobs.where((job) => 
      job.status == '面试中' || job.status == '待录取'
    ).length;
    double interviewRate = totalApplications > 0 ? (interviewCount / totalApplications) * 100 : 0;
    
    // 计算失败原因分布
    Map<String, int> failureReasons = {};
    jobs.where((job) => job.status == '已拒绝' || job.status == '已感谢').forEach((job) {
      // 这里简化处理，实际应用中可能需要更详细的失败原因分析
      failureReasons[job.status] = (failureReasons[job.status] ?? 0) + 1;
    });
    
    // 计算各状态分布
    Map<String, int> statusDistribution = {};
    for (var job in jobs) {
      statusDistribution[job.status] = (statusDistribution[job.status] ?? 0) + 1;
    }
    
    return {
      'weeklyApplications': weeklyApplications,
      'interviewRate': interviewRate,
      'failureReasons': failureReasons,
      'statusDistribution': statusDistribution,
      'totalApplications': totalApplications,
    };
  }

  void _refreshStats() {
    setState(() {
      _statsFuture = _loadStats();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // 保存头像路径到全局User类
      User.updateAvatar(pickedFile.path);
      setState(() {});
      print('头像已选择: ${pickedFile.path}');
    }
  }

  void _editUserInfo() {
    // 这里可以实现编辑用户信息的逻辑
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController usernameController = TextEditingController(text: User.username);
        TextEditingController encouragementController = TextEditingController(text: User.encouragement);
        
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Text('编辑个人信息', style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: '用户名',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.secondaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              SizedBox(height: 16),
              TextField(
                controller: encouragementController,
                decoration: InputDecoration(
                  labelText: '鼓励的话',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.secondaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                style: TextStyle(color: AppTheme.textPrimary),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                // 更新全局User类的信息
                User.updateUserInfo(usernameController.text, encouragementController.text);
                setState(() {});
                Navigator.pop(context);
              },
              child: Text('保存', style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GeometricBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'J',
                    style: TextStyle(
                      color: AppTheme.background,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'JOB Tracker',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: AppTheme.textPrimary),
              onPressed: () {
                // 实现搜索功能
                showSearch(
                  context: context,
                  delegate: JobSearchDelegate(),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: AppTheme.textPrimary),
              onPressed: _refreshStats,
            ),
          ],
          backgroundColor: AppTheme.cardBackground,
          elevation: 2,
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _loadStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '加载中...',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.glassmorphism,
                  child: Text(
                    '错误: ${snapshot.error}',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 16,
                      
                    ),
                  ),
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.glassmorphism,
                  child: Text(
                    'NO DATA AVAILABLE',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      
                    ),
                  ),
                ),
              );
            } else {
              Map<String, dynamic> stats = snapshot.data!;
              
              return Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '统计分析', 
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // 用户信息卡片
                    Container(
                      margin: EdgeInsets.only(bottom: 24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.secondaryColor,
                                    image: User.avatarPath != null
                                        ? DecorationImage(
                                            image: FileImage(File(User.avatarPath!)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: User.avatarPath == null
                                      ? Icon(Icons.add_a_photo, color: AppTheme.textPrimary, size: 24)
                                      : null,
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    User.username,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    width: 150, // 大致容纳14个中文字符的宽度
                                    child: Text(
                                      User.encouragement,
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                            onPressed: _editUserInfo,
                          ),
                        ],
                      ),
                    ),
                    
                    // 关键指标卡片
                    Container(
                      margin: EdgeInsets.only(bottom: 24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '本周申请',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                ),
                                Text(
                                  '${stats['weeklyApplications']}',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '总申请数',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                ),
                                Text(
                                  '${stats['totalApplications']}',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '面试比例',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                ),
                                Text(
                                  '${stats['interviewRate'].toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 状态分布
                    Container(
                      margin: EdgeInsets.only(bottom: 24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(0, 240, 255, 1).withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '状态分布',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              
                            ),
                          ),
                          SizedBox(height: 16),
                          Column(
                            children: (stats['statusDistribution'] as Map<String, int>).entries.map((entry) {
                              int total = stats['totalApplications'] as int;
                              double percentage = total > 0 ? (entry.value / total) * 100 : 0;
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        Text(
                                          '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontFamily: 'JetBrainsMono',
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppTheme.cardBackground,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: FractionallySizedBox(
                                        widthFactor: percentage / 100,
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [AppTheme.primaryColor, const Color.fromRGBO(112, 0, 255, 1)],
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    // 失败原因分析
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '失败原因分析',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              
                            ),
                          ),
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...(stats['failureReasons'] as Map<String, int>).entries.map((entry) => 
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      Text(
                                        entry.value.toString(),
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontFamily: 'JetBrainsMono',
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}