import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:job_tracker/models/job.dart';
import 'package:job_tracker/models/user.dart';
import 'package:job_tracker/db/database_helper.dart';
import 'package:job_tracker/theme/app_theme.dart';
import 'package:job_tracker/components/geometric_background.dart';
import 'job_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Future<List<Job>> _jobsFuture;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Job>> _events = {};
  List<Job> _allJobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
    // 每秒钟更新一次倒计时
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        // 强制刷新UI，重新计算倒计时
      });
    });
  }

  Future<void> _loadJobs() async {
    List<Job> jobs = await DatabaseHelper.instance.queryAllRows();
    _allJobs = jobs;
    Map<DateTime, List<Job>> events = {};
    
    for (Job job in jobs) {
      // 报名开始日期
      if (job.registrationStartDate != null) {
        DateTime date = DateTime(job.registrationStartDate!.year, job.registrationStartDate!.month, job.registrationStartDate!.day);
        if (events.containsKey(date)) {
          events[date]!.add(job);
        } else {
          events[date] = [job];
        }
      }
      
      // 报名截止日期
      if (job.registrationEndDate != null) {
        DateTime date = DateTime(job.registrationEndDate!.year, job.registrationEndDate!.month, job.registrationEndDate!.day);
        if (events.containsKey(date)) {
          events[date]!.add(job);
        } else {
          events[date] = [job];
        }
      }
      
      // 考试日期
      if (job.examDate != null) {
        DateTime date = DateTime(job.examDate!.year, job.examDate!.month, job.examDate!.day);
        if (events.containsKey(date)) {
          events[date]!.add(job);
        } else {
          events[date] = [job];
        }
      }
      
      // 面试日期
      if (job.interviewDate != null) {
        DateTime date = DateTime(job.interviewDate!.year, job.interviewDate!.month, job.interviewDate!.day);
        if (events.containsKey(date)) {
          events[date]!.add(job);
        } else {
          events[date] = [job];
        }
      }
    }
    
    setState(() {
      _events = events;
    });
  }

  List<Job> _getEventsForDay(DateTime day) {
    DateTime date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  // 获取日期的标记颜色
  Color _getMarkerColor(Job job, DateTime day) {
    DateTime date = DateTime(day.year, day.month, day.day);
    
    // 检查是否是报名截止日期
    if (job.registrationEndDate != null) {
      DateTime endDate = DateTime(job.registrationEndDate!.year, job.registrationEndDate!.month, job.registrationEndDate!.day);
      if (isSameDay(date, endDate)) {
        return Colors.red; // 报名截止日期使用红色标记
      }
    }
    
    // 检查是否是笔试日期
    if (job.examDate != null) {
      DateTime examDate = DateTime(job.examDate!.year, job.examDate!.month, job.examDate!.day);
      if (isSameDay(date, examDate)) {
        return Colors.blue; // 笔试日期使用蓝色标记
      }
    }
    
    // 检查是否是面试日期
    if (job.interviewDate != null) {
      DateTime interviewDate = DateTime(job.interviewDate!.year, job.interviewDate!.month, job.interviewDate!.day);
      if (isSameDay(date, interviewDate)) {
        return Colors.green; // 面试日期使用绿色标记
      }
    }
    
    // 检查是否是报名开始日期
    if (job.registrationStartDate != null) {
      DateTime startDate = DateTime(job.registrationStartDate!.year, job.registrationStartDate!.month, job.registrationStartDate!.day);
      if (isSameDay(date, startDate)) {
        return Colors.yellow; // 报名开始日期使用黄色标记
      }
    }
    
    return AppTheme.primaryColor; // 默认使用主题色
  }

  // 构建图例项
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
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
          ),
        ],
      ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 考试倒计时部分
              if (_allJobs.where((job) => job.type == 'exam' && job.examDate != null).isNotEmpty) ...[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _allJobs.where((job) => job.type == 'exam' && job.examDate != null).length,
                    itemBuilder: (context, index) {
                      Job job = _allJobs.where((job) => job.type == 'exam' && job.examDate != null).toList()[index];
                      DateTime now = DateTime.now();
                      Duration difference;
                      String countdownType;
                      
                      // 根据状态决定显示笔试还是面试倒计时
                      if (['面试', '待录取', '已拒绝', '已感谢'].contains(job.status) && job.interviewDate != null) {
                        difference = job.interviewDate!.difference(now);
                        countdownType = '面试';
                      } else {
                        difference = job.examDate!.difference(now);
                        countdownType = '笔试';
                      }
                      
                      if (difference.isNegative) {
                        return Container();
                      }
                      
                      // 计算报名状态
                      String registrationStatus = '未报名';
                      if (job.status == '已报名' || job.status == '笔试中' || job.status == '面试' || job.status == '待录取') {
                        registrationStatus = '已报名';
                      } else if (job.registrationEndDate != null && job.registrationEndDate!.isBefore(now)) {
                        registrationStatus = '报名截止';
                      }
                      
                      return Container(
                        width: 180,
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              job.type == 'exam' ? (job.examName ?? '考试公告') : (job.positionName ?? '职位'),
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${job.examDate!.year}-${job.examDate!.month}-${job.examDate!.day}',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                                fontFamily: 'JetBrainsMono',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                registrationStatus,
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${countdownType} ${difference.inDays} 天',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              // 图例说明
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(Colors.red, '报名截止'),
                    _buildLegendItem(Colors.blue, '笔试'),
                    _buildLegendItem(Colors.green, '面试'),
                    _buildLegendItem(Colors.yellow, '报名开始'),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _getEventsForDay,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return Container();
                      
                      return Container(
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.take(3).map((event) {
                            Job job = event as Job;
                            Color markerColor = _getMarkerColor(job, date);
                            
                            return Container(
                              width: 6,
                              height: 6,
                              margin: EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: markerColor,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.textPrimary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.textPrimary.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    defaultTextStyle: TextStyle(
                      color: AppTheme.textPrimary,
                      fontFamily: 'JetBrainsMono',
                    ),
                    selectedTextStyle: TextStyle(
                      color: AppTheme.background,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono',
                    ),
                    todayTextStyle: TextStyle(
                      color: AppTheme.background,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: AppTheme.textPrimary,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: AppTheme.textPrimary,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                    weekendStyle: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _selectedDay != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _getEventsForDay(_selectedDay!).length,
                        itemBuilder: (context, index) {
                          Job job = _getEventsForDay(_selectedDay!)[index];
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
                                        job.type == 'exam' ? (job.examName ?? '考试公告') : job.positionName, 
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
                                // 添加标签
                                Row(
                                  children: [
                                    if (job.registrationEndDate != null && isSameDay(DateTime(job.registrationEndDate!.year, job.registrationEndDate!.month, job.registrationEndDate!.day), _selectedDay)) ...[
                                      Container(
                                        margin: EdgeInsets.only(right: 8),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '报名截止',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'JetBrainsMono',
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (job.examDate != null && isSameDay(DateTime(job.examDate!.year, job.examDate!.month, job.examDate!.day), _selectedDay)) ...[
                                      Container(
                                        margin: EdgeInsets.only(right: 8),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '笔试',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'JetBrainsMono',
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (job.interviewDate != null && isSameDay(DateTime(job.interviewDate!.year, job.interviewDate!.month, job.interviewDate!.day), _selectedDay)) ...[
                                      Container(
                                        margin: EdgeInsets.only(right: 8),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '面试',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'JetBrainsMono',
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (job.registrationStartDate != null && isSameDay(DateTime(job.registrationStartDate!.year, job.registrationStartDate!.month, job.registrationStartDate!.day), _selectedDay)) ...[
                                      Container(
                                        margin: EdgeInsets.only(right: 8),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '报名开始',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'JetBrainsMono',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        // 导航到详情页
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
                      )
                    : Center(
                        child: Text(
                          '选择日期查看日程',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
    );
  }
}