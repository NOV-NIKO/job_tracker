import 'package:flutter/material.dart';
import 'package:job_tracker/models/job.dart';
import 'package:job_tracker/db/database_helper.dart';
import 'package:job_tracker/services/firebase_service.dart';
import 'package:job_tracker/theme/app_theme.dart';
import 'package:job_tracker/screens/add_job_screen.dart';
import 'dart:io';
import 'package:job_tracker/components/geometric_background.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  _JobDetailScreenState createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Job _job;
  final _interviewFeedbackController = TextEditingController();
  final _resumeVersionController = TextEditingController();
  DateTime? _selectedDate;
  final _postNameController = TextEditingController();
  final _postLocationController = TextEditingController();
  final _unitCodeController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _recruitCountController = TextEditingController();
  final _interviewRatioController = TextEditingController();
  bool _showFullJobDescription = false;
  bool _showFullRequirements = false;



  Future<void> _editPostInfo() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Text('编辑选岗信息', style: TextStyle(color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _postNameController,
                  decoration: InputDecoration(
                    labelText: '岗位名称',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _postLocationController,
                  decoration: InputDecoration(
                    labelText: '岗位地点',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _unitCodeController,
                  decoration: InputDecoration(
                    labelText: '单位编码',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _postCodeController,
                  decoration: InputDecoration(
                    labelText: '岗位编码',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _recruitCountController,
                  decoration: InputDecoration(
                    labelText: '招生人数',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _interviewRatioController,
                  decoration: InputDecoration(
                    labelText: '面试比例',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: TextStyle(color: AppTheme.textPrimary)),
            ),
            TextButton(
              onPressed: () async {
                // 先更新 _job 对象的属性
                _job.postName = _postNameController.text;
                _job.postLocation = _postLocationController.text;
                _job.unitCode = _unitCodeController.text;
                _job.postCode = _postCodeController.text;
                _job.recruitCount = _recruitCountController.text.isNotEmpty ? int.tryParse(_recruitCountController.text) : null;
                _job.interviewRatio = _interviewRatioController.text;
                
                // 保存到数据库
                int result = await DatabaseHelper.instance.update(_job);
                // 同步到云端数据库
                await FirebaseService.syncJobToCloud(_job);
                print('更新结果: $result');
                
                // 重新获取最新的 job 对象
                List<Job> jobs = await DatabaseHelper.instance.queryAllRows();
                Job? updatedJob = jobs.firstWhere((j) => j.id == _job.id, orElse: () => _job);
                
                // 更新状态并关闭对话框
                setState(() {
                  _job = updatedJob;
                });
                Navigator.pop(context);
              },
              child: Text('保存', style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  final _examNameController = TextEditingController();
  final _examSubjectsController = TextEditingController();
  final _registrationEndTimeController = TextEditingController();
  final _examInfoController = TextEditingController();
  DateTime? _examDate;
  DateTime? _registrationStartDate;
  DateTime? _registrationEndDate;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _interviewFeedbackController.text = _job.interviewFeedback ?? '';
    _resumeVersionController.text = _job.resumeVersion ?? '';
    _selectedDate = _job.interviewDate;
    _postNameController.text = _job.postName ?? '';
    _postLocationController.text = _job.postLocation ?? '';
    _unitCodeController.text = _job.unitCode ?? '';
    _postCodeController.text = _job.postCode ?? '';
    _recruitCountController.text = _job.recruitCount?.toString() ?? '';
    _interviewRatioController.text = _job.interviewRatio ?? '';
    _examNameController.text = _job.examName ?? '';
    _examSubjectsController.text = _job.examSubjects ?? '';
    _registrationEndTimeController.text = _job.registrationEndTime ?? '';
    _examInfoController.text = _job.examInfo ?? '';
    _examDate = _job.examDate;
    _registrationStartDate = _job.registrationStartDate;
    _registrationEndDate = _job.registrationEndDate;
  }

  Future<void> _editExamInfo() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Text('编辑考试信息', style: TextStyle(color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _examNameController,
                  decoration: InputDecoration(
                    labelText: '考试名称',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text('考试日期:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                    ),
                    Text(_examDate != null ? '${_examDate!.year}-${_examDate!.month}-${_examDate!.day}' : '未设置', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _examDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && picked != _examDate) {
                          setState(() {
                            _examDate = picked;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('选择日期'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _examSubjectsController,
                  decoration: InputDecoration(
                    labelText: '考试科目',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text('报名开始日期:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                    ),
                    Text(_registrationStartDate != null ? '${_registrationStartDate!.year}-${_registrationStartDate!.month}-${_registrationStartDate!.day}' : '未设置', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _registrationStartDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && picked != _registrationStartDate) {
                          setState(() {
                            _registrationStartDate = picked;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('选择日期'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text('报名截止日期:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                    ),
                    Text(_registrationEndDate != null ? '${_registrationEndDate!.year}-${_registrationEndDate!.month}-${_registrationEndDate!.day}' : '未设置', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _registrationEndDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && picked != _registrationEndDate) {
                          setState(() {
                            _registrationEndDate = picked;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('选择日期'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _registrationEndTimeController,
                  decoration: InputDecoration(
                    labelText: '报名截止时间',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _examInfoController,
                  decoration: InputDecoration(
                    labelText: '考试信息',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    fillColor: AppTheme.cardBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: TextStyle(color: AppTheme.textPrimary)),
            ),
            TextButton(
              onPressed: () async {
                // 先更新 _job 对象的属性
                _job.examName = _examNameController.text;
                _job.examDate = _examDate;
                _job.examSubjects = _examSubjectsController.text;
                _job.registrationStartDate = _registrationStartDate;
                _job.registrationEndDate = _registrationEndDate;
                _job.registrationEndTime = _registrationEndTimeController.text;
                _job.examInfo = _examInfoController.text;
                
                // 保存到数据库
                int result = await DatabaseHelper.instance.update(_job);
                // 同步到云端数据库
                await FirebaseService.syncJobToCloud(_job);
                print('更新结果: $result');
                
                // 重新获取最新的 job 对象
                List<Job> jobs = await DatabaseHelper.instance.queryAllRows();
                Job? updatedJob = jobs.firstWhere((j) => j.id == _job.id, orElse: () => _job);
                
                // 更新状态并关闭对话框
                setState(() {
                  _job = updatedJob;
                });
                Navigator.pop(context);
              },
              child: Text('保存', style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateJob() async {
    // 先更新 _job 对象的属性
    _job.interviewFeedback = _interviewFeedbackController.text;
    _job.resumeVersion = _resumeVersionController.text;
    _job.interviewDate = _selectedDate;
    
    // 保存到数据库
    await DatabaseHelper.instance.update(_job);
    // 同步到云端数据库
    await FirebaseService.syncJobToCloud(_job);
    
    // 重新获取最新的 job 对象
    List<Job> jobs = await DatabaseHelper.instance.queryAllRows();
    Job? updatedJob = jobs.firstWhere((j) => j.id == _job.id, orElse: () => _job);
    
    // 更新状态并关闭对话框
    setState(() {
      _job = updatedJob;
    });
    Navigator.pop(context);
  }

  Future<void> _updateStatus(String status) async {
    // 先更新 _job 对象的属性
    _job.status = status;
    
    // 保存到数据库
    await DatabaseHelper.instance.update(_job);
    // 同步到云端数据库
    await FirebaseService.syncJobToCloud(_job);
    
    // 重新获取最新的 job 对象
    List<Job> jobs = await DatabaseHelper.instance.queryAllRows();
    Job? updatedJob = jobs.firstWhere((j) => j.id == _job.id, orElse: () => _job);
    
    // 更新状态
    setState(() {
      _job = updatedJob;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildRegistrationReminder() {
    if (_job.registrationEndDate == null) {
      return Text('未设置报名截止日期', style: TextStyle(color: AppTheme.textSecondary));
    }

    DateTime now = DateTime.now();
    DateTime endDate = _job.registrationEndDate!;
    // 尝试解析截止时间
    TimeOfDay? endTime;
    if (_job.registrationEndTime != null && _job.registrationEndTime!.isNotEmpty) {
      List<String> timeParts = _job.registrationEndTime!.split(':');
      if (timeParts.length == 2) {
        int? hour = int.tryParse(timeParts[0]);
        int? minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          endTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }

    // 计算截止时间
    DateTime endDateTime = endDate;
    if (endTime != null) {
      endDateTime = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    }

    Duration difference = endDateTime.difference(now);

    if (difference.isNegative) {
      return Text('报名已截止', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold));
    } else if (difference.inDays == 0) {
      int hours = difference.inHours;
      int minutes = difference.inMinutes % 60;
      return Text('报名将在 $hours 小时 $minutes 分钟后截止', style: TextStyle(color: AppTheme.warningColor, fontWeight: FontWeight.bold));
    } else {
      int days = difference.inDays;
      int hours = difference.inHours % 24;
      return Text('报名将在 $days 天 $hours 小时后截止', style: TextStyle(color: AppTheme.textPrimary));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeometricBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_job.type == 'exam' ? (_job.examName ?? '考试公告') : _job.positionName, style: TextStyle(fontFamily: 'SpaceGrotesk')),
          backgroundColor: AppTheme.cardBackground.withOpacity(0.9),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.textPrimary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddJobScreen(job: _job, type: _job.type),
                  ),
                ).then((_) async {
                  // 编辑完成后从数据库重新加载最新数据
                  List<Job> jobs = await DatabaseHelper.instance.queryAllRows();
                  Job? updatedJob = jobs.firstWhere((job) => job.id == _job.id, orElse: () => _job);
                  setState(() {
                    _job = updatedJob;
                  });
                });
              },
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 招考公告特殊布局
              if (_job.type == 'exam') ...[
                // 基本信息 - 只保留公告标题、省份、单位性质
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('基本信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                          ElevatedButton(
                            onPressed: () {
                              // 原图预览功能
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: AppTheme.cardBackground,
                                    title: Text('原图预览', style: TextStyle(color: AppTheme.textPrimary)),
                                    content: _job.imagePath != null && _job.imagePath!.isNotEmpty
                                        ? Image.file(
                                            File(_job.imagePath!),
                                            fit: BoxFit.contain,
                                          )
                                        : Text('暂无原图', style: TextStyle(color: AppTheme.textPrimary)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('确定', style: TextStyle(color: AppTheme.primaryColor)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: AppTheme.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                            ),
                            child: Text('原图预览', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('公告标题: ${_job.examName ?? '未设置'}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('省份: ${_job.location ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('单位性质: ${_job.companyType ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                    ],
                  ),
                ),
                // 第二块：考试信息
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('考试信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                      SizedBox(height: 16),
                      Text('考试日期: ${_job.examDate != null ? '${_job.examDate!.year}-${_job.examDate!.month}-${_job.examDate!.day}' : '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 8),
                      Text('考试科目: ${_job.examSubjects ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('面试日期: ${_job.interviewDate != null ? '${_job.interviewDate!.year}-${_job.interviewDate!.month}-${_job.interviewDate!.day}' : '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 8),
                      Text('报名时间:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 4),
                      Text('开始日期: ${_job.registrationStartDate != null ? '${_job.registrationStartDate!.year}-${_job.registrationStartDate!.month}-${_job.registrationStartDate!.day}' : '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 4),
                      Text('截止日期: ${_job.registrationEndDate != null ? '${_job.registrationEndDate!.year}-${_job.registrationEndDate!.month}-${_job.registrationEndDate!.day}' : '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 4),
                      Text('截止时间: ${_job.registrationEndTime ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 16),
                      // 报名日期提醒
                      if (_job.registrationEndDate != null) ...[
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.warningColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('报名截止提醒', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.warningColor, fontFamily: 'SpaceGrotesk')),
                              SizedBox(height: 8),
                              _buildRegistrationReminder(),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      Text('考试信息:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 4),
                      Text(_job.examInfo ?? '未设置', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _editExamInfo();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                        child: Text('编辑考试信息', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                      ),
                    ],
                  ),
                ),
                // 第三块：选岗信息
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('选岗信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                      SizedBox(height: 16),
                      Text('岗位名称: ${_job.postName ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('岗位地点: ${_job.postLocation ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('单位编码: ${_job.unitCode ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 8),
                      Text('岗位编码: ${_job.postCode ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 8),
                      Text('招生人数: ${_job.recruitCount ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 8),
                      Text('面试比例: ${_job.interviewRatio ?? '未设置'}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _editPostInfo();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                        child: Text('编辑选岗信息', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                      ),
                    ],
                  ),
                ),
                // 第四块：状态管理
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('状态管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text('当前状态: ', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(_job.status, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontFamily: 'JetBrainsMono')),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('更新状态:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          '未报名',
                          '已报名',
                          '笔试中',
                          '面试',
                          '待录取',
                          '已拒绝',
                          '已感谢'
                        ].map((status) => ElevatedButton(
                          onPressed: () => _updateStatus(status),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _job.status == status ? AppTheme.primaryColor : AppTheme.cardBackground.withOpacity(0.6),
                            foregroundColor: _job.status == status ? AppTheme.background : AppTheme.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: _job.status == status ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3)),
                            ),
                            elevation: _job.status == status ? 4 : 0,
                          ),
                          child: Text(status, style: TextStyle(fontFamily: 'SpaceGrotesk')),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                // 第五块：面试信息
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('面试信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text('面试时间: ', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                          Text(_selectedDate != null ? '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}' : '未设置', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: AppTheme.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                            ),
                            child: Text('选择日期', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('简历版本:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      TextField(
                        controller: _resumeVersionController,
                        decoration: InputDecoration(
                          hintText: '例如：中文版/英文版/产品版',
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          fillColor: AppTheme.cardBackground.withOpacity(0.6),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 16),
                      Text('面试反馈:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      TextField(
                        controller: _interviewFeedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: '记录面试题、表现自我评价、面试官印象',
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          fillColor: AppTheme.cardBackground.withOpacity(0.6),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // 企业招聘的原始布局
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('基本信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                          ElevatedButton(
                            onPressed: () {
                              // 原图预览功能
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: AppTheme.cardBackground,
                                    title: Text('原图预览', style: TextStyle(color: AppTheme.textPrimary)),
                                    content: _job.imagePath != null && _job.imagePath!.isNotEmpty
                                        ? Image.file(
                                            File(_job.imagePath!),
                                            fit: BoxFit.contain,
                                          )
                                        : Text('暂无原图', style: TextStyle(color: AppTheme.textPrimary)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('确定', style: TextStyle(color: AppTheme.primaryColor)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: AppTheme.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                            ),
                            child: Text('原图预览', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('公司名称: ${_job.companyName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('职位名称: ${_job.positionName}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('工作地点: ${_job.location}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('薪资范围: ${_job.salary}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontFamily: 'JetBrainsMono')),
                      SizedBox(height: 8),
                      Text('招聘平台: ${_job.platform}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('单位性质: ${_job.companyType}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('融资情况: ${_job.fundingStatus}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('公司规模: ${_job.companySize}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      SizedBox(height: 8),
                      Text('行业领域: ${_job.industry}', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('职位详情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                      SizedBox(height: 16),
                      Text('岗位职责', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                      SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _job.jobDescription ?? '',
                            style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter'),
                            maxLines: _showFullJobDescription ? null : 3,
                            overflow: _showFullJobDescription ? null : TextOverflow.ellipsis,
                          ),
                          if ((_job.jobDescription?.length ?? 0) > 100) ...[
                            SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showFullJobDescription = !_showFullJobDescription;
                                });
                              },
                              child: Text(
                                _showFullJobDescription ? '收起' : '查看更多',
                                style: TextStyle(color: AppTheme.primaryColor, fontFamily: 'SpaceGrotesk'),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('任职要求', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                      SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _job.requirements ?? '',
                            style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter'),
                            maxLines: _showFullRequirements ? null : 3,
                            overflow: _showFullRequirements ? null : TextOverflow.ellipsis,
                          ),
                          if ((_job.requirements?.length ?? 0) > 100) ...[
                            SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showFullRequirements = !_showFullRequirements;
                                });
                              },
                              child: Text(
                                _showFullRequirements ? '收起' : '查看更多',
                                style: TextStyle(color: AppTheme.primaryColor, fontFamily: 'SpaceGrotesk'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('状态管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text('当前状态: ', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(_job.status, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontFamily: 'JetBrainsMono')),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('更新状态:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          '未报名',
                          '已报名',
                          '笔试中',
                          '面试',
                          '待录取',
                          '已拒绝',
                          '已感谢'
                        ].map((status) => ElevatedButton(
                          onPressed: () => _updateStatus(status),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _job.status == status ? AppTheme.primaryColor : AppTheme.cardBackground.withOpacity(0.6),
                            foregroundColor: _job.status == status ? AppTheme.background : AppTheme.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: _job.status == status ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3)),
                            ),
                            elevation: _job.status == status ? 4 : 0,
                          ),
                          child: Text(status, style: TextStyle(fontFamily: 'SpaceGrotesk')),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('面试信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text('面试时间: ', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                          Text(_selectedDate != null ? '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}' : '未设置', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'JetBrainsMono')),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: AppTheme.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                            ),
                            child: Text('选择日期', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('简历版本:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      TextField(
                        controller: _resumeVersionController,
                        decoration: InputDecoration(
                          hintText: '例如：中文版/英文版/产品版',
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          fillColor: AppTheme.cardBackground.withOpacity(0.6),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 16),
                      Text('面试反馈:', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                      TextField(
                        controller: _interviewFeedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: '记录面试题、表现自我评价、面试官印象',
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          fillColor: AppTheme.cardBackground.withOpacity(0.6),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _updateJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.background,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text('保存修改', style: TextStyle( fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: AppTheme.cardBackground.withOpacity(0.9),
                            title: Text('删除确认', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'SpaceGrotesk')),
                            content: Text('确定要删除这个职位信息吗？', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Inter')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('取消', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'SpaceGrotesk')),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // 从本地数据库删除
                                  await DatabaseHelper.instance.delete(_job.id!);
                                  // 从云端数据库删除
                                  await FirebaseService.deleteJobFromCloud(_job.id!);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text('删除', style: TextStyle(color: AppTheme.errorColor, fontFamily: 'SpaceGrotesk')),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text('删除', style: TextStyle( fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
