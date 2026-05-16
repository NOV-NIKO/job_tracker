import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_tracker/models/job.dart';
import 'package:job_tracker/models/user.dart';
import 'package:job_tracker/db/database_helper.dart';
import 'package:job_tracker/services/auth_service.dart';
import 'package:job_tracker/services/firebase_service.dart';
import 'package:job_tracker/theme/app_theme.dart';
import 'package:job_tracker/components/motivational_character.dart';
import 'package:job_tracker/components/geometric_background.dart';
import 'job_detail_screen.dart';
import 'add_job_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';

class JobSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.cardBackground,
        foregroundColor: AppTheme.textPrimary,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppTheme.textSecondary),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: AppTheme.textPrimary),
        titleLarge: TextStyle(color: AppTheme.textPrimary),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: AppTheme.textPrimary),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Job>>(
      future: DatabaseHelper.instance.queryAllRows(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('搜索失败'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('无数据'));
        } else {
          List<Job> jobs = snapshot.data!;
          List<Job> filteredJobs = jobs.where((job) {
            return job.positionName.toLowerCase().contains(query.toLowerCase()) ||
                   job.companyName.toLowerCase().contains(query.toLowerCase()) ||
                   (job.examName != null && job.examName!.toLowerCase().contains(query.toLowerCase()));
          }).toList();

          return ListView.builder(
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              Job job = filteredJobs[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            job.type == 'company' ? job.positionName : (job.examName ?? '考试公告'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 16),
                        if (job.type == 'company') ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              job.salary.isNotEmpty ? job.salary : '薪资: 面议',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (job.type == 'exam' && job.examDate != null) ...[
                          Text(
                            '${job.examDate!.year}-${job.examDate!.month}-${job.examDate!.day}',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 8),
                    if (job.type == 'company') ...[
                      Text(
                        job.companyName,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${job.location}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    if (job.type == 'exam') ...[
                      if (job.examDate != null) ...[
                        Text(
                          '笔试时间: ${job.examDate!.year}-${job.examDate!.month}-${job.examDate!.day}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                      if (job.interviewDate != null) ...[
                        Text(
                          '面试时间: ${job.interviewDate!.year}-${job.interviewDate!.month}-${job.interviewDate!.day}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    ],
                    SizedBox(height: 8),
                    if (job.jobDescription != null && job.jobDescription!.isNotEmpty) ...[
                      Text(
                        job.jobDescription!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
                            );
                          },
                          child: Text('VIEW DETAILS', style: TextStyle(color: AppTheme.primaryColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    CalendarScreen(),
    CompanyJobsScreen(),
    ExamJobsScreen(),
    StatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 检查用户是否登录，如果已登录则从云端加载数据
    _loadDataFromCloud();
  }

  Future<void> _loadDataFromCloud() async {
    if (AuthService.currentUser != null) {
      try {
        // 从云端加载数据
        await FirebaseService.syncJobsFromCloud();
        print('数据已从云端同步');
      } catch (e) {
        print('同步数据失败: $e');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GeometricBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground.withOpacity(0.8),
            border: Border(top: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 1)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                spreadRadius: 8,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 流光指示器
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 3,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  alignment: Alignment(_selectedIndex * 2 / 3 - 1, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 4,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor,
                          AppTheme.primaryColor,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.6),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 导航栏
              BottomNavigationBar(
                currentIndex: _selectedIndex,
                selectedItemColor: AppTheme.primaryColor,
                unselectedItemColor: AppTheme.textSecondary,
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today),
                    label: '日历',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.business),
                    label: '企业',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.school),
                    label: '考试',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart),
                    label: '统计',
                  ),
                ],
                selectedLabelStyle: TextStyle(
                  
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  
                  fontSize: 12,
                ),
                selectedIconTheme: IconThemeData(
                  color: AppTheme.primaryColor,
                  shadows: [
                    Shadow(
                      color: AppTheme.primaryColor.withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompanyJobsScreen extends StatefulWidget {
  @override
  _CompanyJobsScreenState createState() => _CompanyJobsScreenState();
}

class _CompanyJobsScreenState extends State<CompanyJobsScreen> {
  late Future<List<Job>> _jobsFuture;
  final List<String> _statuses = [
    '未报名',
    '已报名',
    '笔试中',
    '面试',
    '待录取',
    '已拒绝',
    '已感谢'
  ];
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _refreshJobs();
  }

  void _refreshJobs() {
    setState(() {
      _jobsFuture = DatabaseHelper.instance.queryAllRows();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'N',
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
        backgroundColor: AppTheme.cardBackground.withOpacity(0.8),
        elevation: 0,
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
          PopupMenuButton(
            icon: Container(
              margin: EdgeInsets.only(right: 16),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
                image: User.avatarPath != null
                    ? DecorationImage(
                        image: FileImage(File(User.avatarPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('更换头像'),
                  onTap: () {
                    _pickImage();
                    Navigator.pop(context);
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('退出登录'),
                  onTap: () async {
                    await AuthService.logout();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '企业招聘',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => AddJobScreen(type: 'company')),
                      );
                      _refreshJobs();
                    },
                    child: Icon(Icons.add),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.background,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Job>>(
                future: _jobsFuture,
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '暂无招聘信息',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 18,
                              
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => AddJobScreen(type: 'company')),
                              );
                              _refreshJobs();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '添加招聘',
                              style: TextStyle(
                                color: AppTheme.background,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // 过滤出企业招聘
                    List<Job> companyJobs = snapshot.data!.where((job) => job.type == 'company').toList();
                    
                    if (companyJobs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'NO JOB POSTINGS',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 18,
                                
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => AddJobScreen(type: 'company')),
                                );
                                _refreshJobs();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'ADD JOB',
                                style: TextStyle(
                                  color: AppTheme.background,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView(
                      children: [
                        // 所有企业招聘职位列表
                        ..._statuses.map((status) {
                          List<Job> jobsWithStatus = companyJobs.where((job) => job.status == status).toList();
                          if (jobsWithStatus.isEmpty) {
                            return Container();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    
                                  ),
                                ),
                              ),
                              ...jobsWithStatus.map((job) => Container(
                                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    padding: EdgeInsets.all(16),
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              job.positionName,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              job.salary,
                                              style: TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                        SizedBox(height: 8),
                                        Text(
                                          job.companyName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppTheme.textPrimary,
                                            
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${job.location}',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        if (job.jobDescription != null && job.jobDescription!.isNotEmpty) ...[
                                          Text(
                                            job.jobDescription!,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                await Navigator.push(
                                                  context, 
                                                  MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
                                                );
                                                _refreshJobs();
                                              },
                                              child: Text('VIEW DETAILS', style: TextStyle(color: AppTheme.primaryColor)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
    );
  }
}

class ExamJobsScreen extends StatefulWidget {
  @override
  _ExamJobsScreenState createState() => _ExamJobsScreenState();
}

class _ExamJobsScreenState extends State<ExamJobsScreen> {
  late Future<List<Job>> _jobsFuture;
  final List<String> _statuses = [
    '未报名',
    '已报名',
    '笔试中',
    '面试',
    '待录取',
    '已拒绝',
    '已感谢'
  ];
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _refreshJobs();
    // 每秒钟更新一次倒计时
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        // 强制刷新UI，重新计算倒计时
      });
    });
  }

  void _refreshJobs() {
    setState(() {
      _jobsFuture = DatabaseHelper.instance.queryAllRows();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        backgroundColor: AppTheme.cardBackground.withOpacity(0.8),
        elevation: 0,
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
          PopupMenuButton(
            icon: Container(
              margin: EdgeInsets.only(right: 16),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
                image: User.avatarPath != null
                    ? DecorationImage(
                        image: FileImage(File(User.avatarPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('更换头像'),
                  onTap: () {
                    _pickImage();
                    Navigator.pop(context);
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('退出登录'),
                  onTap: () async {
                    await AuthService.logout();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '考试公告',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => AddJobScreen(type: 'exam')),
                      );
                      _refreshJobs();
                    },
                    child: Icon(Icons.add),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.background,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Job>>(
                future: _jobsFuture,
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '暂无考试安排',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 18,
                              
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => AddJobScreen(type: 'exam')),
                              );
                              _refreshJobs();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '添加考试',
                              style: TextStyle(
                                color: AppTheme.background,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // 过滤出考试公告
                    List<Job> examJobs = snapshot.data!.where((job) => job.type == 'exam').toList();
                    
                    if (examJobs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'NO EXAM SCHEDULED',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 18,
                                
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => AddJobScreen(type: 'exam')),
                                );
                                _refreshJobs();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'ADD EXAM',
                                style: TextStyle(
                                  color: AppTheme.background,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView(
                      children: [
                        // 所有考试公告列表
                        ..._statuses.map((status) {
                          List<Job> jobsWithStatus = examJobs.where((job) => job.status == status).toList();
                          if (jobsWithStatus.isEmpty) {
                            return Container();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    
                                  ),
                                ),
                              ),
                              ...jobsWithStatus.map((job) {
                                int daysLeft = 0;
                                if (job.examDate != null) {
                                  DateTime now = DateTime.now();
                                  Duration difference = job.examDate!.difference(now);
                                  if (!difference.isNegative) {
                                    daysLeft = difference.inDays;
                                  }
                                }
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    padding: EdgeInsets.all(16),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              job.examName ?? '考试公告',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Text(
                                            '$daysLeft 天',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      if (job.examDate != null) ...[
                                        Text(
                                          '笔试时间: ${job.examDate!.year}-${job.examDate!.month}-${job.examDate!.day}',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                      ],
                                      if (job.interviewDate != null) ...[
                                        Text(
                                          '面试时间: ${job.interviewDate!.year}-${job.interviewDate!.month}-${job.interviewDate!.day}',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                      ],
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              await Navigator.push(
                                                context, 
                                                MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
                                              );
                                              _refreshJobs();
                                            },
                                            child: Text('VIEW DETAILS', style: TextStyle( color: AppTheme.primaryColor)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
    );
  }
}