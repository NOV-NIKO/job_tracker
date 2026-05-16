import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_tracker/models/job.dart';
import 'package:job_tracker/db/database_helper.dart';
import 'package:job_tracker/services/firebase_service.dart';
import 'package:job_tracker/utils/ocr_helper.dart';
import 'package:job_tracker/theme/app_theme.dart';
import 'package:job_tracker/components/loading_indicator.dart';
import 'package:job_tracker/components/geometric_background.dart';

class AddJobScreen extends StatefulWidget {
  final Job? job;
  final String type;

  const AddJobScreen({super.key, this.job, required this.type});

  @override
  _AddJobScreenState createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _positionNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _salaryController = TextEditingController();
  final _platformController = TextEditingController();
  final _linkController = TextEditingController();
  final _companyTypeController = TextEditingController();
  final _fundingStatusController = TextEditingController();
  final _companySizeController = TextEditingController();
  final _industryController = TextEditingController();
  String _status = '未报名';
  late String _type; // 'company' 或 'exam'
  // 考试公告相关字段
  final _examNameController = TextEditingController();
  final _examInfoController = TextEditingController();
  final _examSubjectsController = TextEditingController();
  DateTime? _examDate;
  final _examDateController = TextEditingController();
  DateTime? _interviewDate;
  final _interviewDateController = TextEditingController();
  DateTime? _registrationStartDate;
  final _registrationStartDateController = TextEditingController();
  DateTime? _registrationEndDate;
  final _registrationEndDateController = TextEditingController();
  final _registrationEndTimeController = TextEditingController();
  // 选岗信息相关字段
  final _postNameController = TextEditingController();
  final _postLocationController = TextEditingController();
  final _unitCodeController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _recruitCountController = TextEditingController();
  final _interviewRatioController = TextEditingController();
  bool _isLoading = false;
  double _loadingProgress = 0.0;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    // 如果传入了job参数，填充表单字段
    if (widget.job != null) {
      Job job = widget.job!;
      _status = job.status;
      _companyNameController.text = job.companyName ?? '';
      _positionNameController.text = job.positionName ?? '';
      _locationController.text = job.location ?? '';
      _jobDescriptionController.text = job.jobDescription ?? '';
      _requirementsController.text = job.requirements ?? '';
      _salaryController.text = job.salary ?? '';
      _platformController.text = job.platform ?? '';
      _linkController.text = job.link ?? '';
      _companyTypeController.text = job.companyType ?? '';
      _fundingStatusController.text = job.fundingStatus ?? '';
      _companySizeController.text = job.companySize ?? '';
      _industryController.text = job.industry ?? '';
      // 考试公告相关字段
      _examNameController.text = job.examName ?? '';
      _examInfoController.text = job.examInfo ?? '';
      _examSubjectsController.text = job.examSubjects ?? '';
      _examDate = job.examDate;
      if (job.examDate != null) {
        _examDateController.text = '${job.examDate!.year}-${job.examDate!.month}-${job.examDate!.day}';
      }
      _interviewDate = job.interviewDate;
      if (job.interviewDate != null) {
        _interviewDateController.text = '${job.interviewDate!.year}-${job.interviewDate!.month}-${job.interviewDate!.day}';
      }
      _registrationStartDate = job.registrationStartDate;
      if (job.registrationStartDate != null) {
        _registrationStartDateController.text = '${job.registrationStartDate!.year}-${job.registrationStartDate!.month}-${job.registrationStartDate!.day}';
      }
      _registrationEndDate = job.registrationEndDate;
      if (job.registrationEndDate != null) {
        _registrationEndDateController.text = '${job.registrationEndDate!.year}-${job.registrationEndDate!.month}-${job.registrationEndDate!.day}';
      }
      _registrationEndTimeController.text = job.registrationEndTime ?? '';
      // 选岗信息相关字段
      _postNameController.text = job.postName ?? '';
      _postLocationController.text = job.postLocation ?? '';
      _unitCodeController.text = job.unitCode ?? '';
      _postCodeController.text = job.postCode ?? '';
      _recruitCountController.text = job.recruitCount?.toString() ?? '';
      _interviewRatioController.text = job.interviewRatio ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // 先设置选中的图片
      setState(() {
        _isLoading = true;
        _loadingProgress = 0.0;
        _selectedImage = File(pickedFile.path);
      });

      // 显示加载窗口
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppTheme.cardBackground,
            title: Text('识别中', style: TextStyle(color: AppTheme.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 显示选中的图片
                if (_selectedImage != null) ...[
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                // 显示加载动画
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
                SizedBox(height: 16),
                // 显示加载信息
                Text(
                  '正在处理图片...',
                  style: TextStyle(color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      try {
        // 直接调用OCR API进行识别
        Map<String, String> extractedData = await OCRHelper.extractJobInfo(pickedFile.path, type: widget.type);
        
        // 关闭加载窗口
        Navigator.pop(context);

        // 显示识别结果详情
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // 判断是公司招聘还是招考公告
            bool isCompanyRecruitment = extractedData.containsKey('companyName') && extractedData['companyName'] != null && extractedData['companyName']!.isNotEmpty;
            bool isExamAnnouncement = extractedData.containsKey('examName') && extractedData['examName'] != null && extractedData['examName']!.isNotEmpty;
            
            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              title: Text('识别结果', style: TextStyle(color: AppTheme.textPrimary)),
              content: SizedBox(
                width: 300,
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('提取的信息：', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      
                      // 显示公司招聘信息
                      if (isCompanyRecruitment) ...[
                        Text('【公司招聘信息】', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        if (extractedData['companyName'] != null && extractedData['companyName']!.isNotEmpty) ...[
                          Text('公司名称: ${extractedData['companyName']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['positionName'] != null && extractedData['positionName']!.isNotEmpty) ...[
                          Text('职位名称: ${extractedData['positionName']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['salary'] != null && extractedData['salary']!.isNotEmpty) ...[
                          Text('薪资: ${extractedData['salary']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['location'] != null && extractedData['location']!.isNotEmpty) ...[
                          Text('工作地点: ${extractedData['location']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['companyType'] != null && extractedData['companyType']!.isNotEmpty) ...[
                          Text('公司类型: ${extractedData['companyType']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['industry'] != null && extractedData['industry']!.isNotEmpty) ...[
                          Text('所属行业: ${extractedData['industry']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                      ],
                      
                      // 显示招考公告信息
                      if (isExamAnnouncement) ...[
                        Text('【招考公告信息】', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        if (extractedData['examName'] != null && extractedData['examName']!.isNotEmpty) ...[
                          Text('公告标题: ${extractedData['examName']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['province'] != null && extractedData['province']!.isNotEmpty) ...[
                          Text('省份: ${extractedData['province']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['companyType'] != null && extractedData['companyType']!.isNotEmpty) ...[
                          Text('单位性质: ${extractedData['companyType']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['examDate'] != null && extractedData['examDate']!.isNotEmpty) ...[
                          Text('考试日期: ${extractedData['examDate']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['interviewDate'] != null && extractedData['interviewDate']!.isNotEmpty) ...[
                          Text('面试日期: ${extractedData['interviewDate']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['registrationEndDate'] != null && extractedData['registrationEndDate']!.isNotEmpty) ...[
                          Text('报名截止日期: ${extractedData['registrationEndDate']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['postName'] != null && extractedData['postName']!.isNotEmpty) ...[
                          Text('岗位名称: ${extractedData['postName']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData['recruitCount'] != null && extractedData['recruitCount']!.isNotEmpty) ...[
                          Text('招生人数: ${extractedData['recruitCount']}', style: TextStyle(color: AppTheme.textPrimary)),
                          SizedBox(height: 8),
                        ],
                      ],
                      
                      // 如果没有提取到任何信息
                      if (!isCompanyRecruitment && !isExamAnnouncement) ...[
                        Text('未能提取到有效信息，请检查图片质量或内容是否清晰。', style: TextStyle(color: AppTheme.textSecondary)),
                        SizedBox(height: 8),
                        // 显示错误信息
                        if (extractedData.containsKey('errorCode') && extractedData['errorCode'] != null && extractedData['errorCode']!.isNotEmpty) ...[
                          Text('错误码: ${extractedData['errorCode']}', style: TextStyle(color: AppTheme.errorColor)),
                          SizedBox(height: 8),
                        ],
                        if (extractedData.containsKey('errorMessage') && extractedData['errorMessage'] != null && extractedData['errorMessage']!.isNotEmpty) ...[
                          Text('错误信息: ${extractedData['errorMessage']}', style: TextStyle(color: AppTheme.errorColor)),
                          SizedBox(height: 8),
                        ],
                      ],
                      
                      // 预览原始图像按钮
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // 显示原始图像预览窗口
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  double scale = 1.0;
                                  return AlertDialog(
                                    backgroundColor: AppTheme.cardBackground,
                                    title: Text('原始图像预览', style: TextStyle(color: AppTheme.textPrimary)),
                                    content: Container(
                                      width: 300,
                                      height: 400,
                                      child: InteractiveViewer(
                                        panEnabled: true,
                                        boundaryMargin: EdgeInsets.all(20),
                                        minScale: 0.1,
                                        maxScale: 5.0,
                                        child: Image.file(_selectedImage!, fit: BoxFit.contain),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('关闭', style: TextStyle(color: AppTheme.textPrimary)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('预览原始图像', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('确定', style: TextStyle(color: AppTheme.primaryColor)),
                ),
              ],
            );
          },
        );

        // 更新表单数据
        setState(() {
          // 基本信息
          _companyNameController.text = extractedData['companyName'] ?? '';
          _positionNameController.text = extractedData['positionName'] ?? '';
          _salaryController.text = extractedData['salary'] ?? '';
          _locationController.text = extractedData['location'] ?? '';
          // 公司信息
          _platformController.text = extractedData['recruitmentPlatform'] ?? '';
          _linkController.text = extractedData['originalLink'] ?? '';
          _companyTypeController.text = extractedData['companyType'] ?? '';
          _fundingStatusController.text = extractedData['financingStatus'] ?? '';
          _companySizeController.text = extractedData['companySize'] ?? '';
          _industryController.text = extractedData['industry'] ?? '';
          // 职位信息
          _jobDescriptionController.text = extractedData['jobResponsibilities'] ?? '';
          _requirementsController.text = extractedData['jobRequirements'] ?? extractedData['requirements'] ?? '';
          // 考试公告相关字段
          _examNameController.text = extractedData['examName'] ?? '';
          _examSubjectsController.text = extractedData['examSubjects'] ?? '';
          _examInfoController.text = extractedData['examInfo'] ?? '';
          _registrationEndTimeController.text = extractedData['registrationEndTime'] ?? '';
          // 解析日期字段
          if (extractedData['examDate'] != null) {
            try {
              _examDate = DateTime.parse(extractedData['examDate']!);
              _examDateController.text = '${_examDate!.year}-${_examDate!.month}-${_examDate!.day}';
            } catch (e) {
              print('解析考试日期失败: $e');
            }
          }
          if (extractedData['interviewDate'] != null) {
            try {
              _interviewDate = DateTime.parse(extractedData['interviewDate']!);
              _interviewDateController.text = '${_interviewDate!.year}-${_interviewDate!.month}-${_interviewDate!.day}';
            } catch (e) {
              print('解析面试日期失败: $e');
            }
          }
          if (extractedData['registrationStartDate'] != null) {
            try {
              _registrationStartDate = DateTime.parse(extractedData['registrationStartDate']!);
              _registrationStartDateController.text = '${_registrationStartDate!.year}-${_registrationStartDate!.month}-${_registrationStartDate!.day}';
            } catch (e) {
              print('解析报名开始日期失败: $e');
            }
          }
          if (extractedData['registrationEndDate'] != null) {
            try {
              _registrationEndDate = DateTime.parse(extractedData['registrationEndDate']!);
              _registrationEndDateController.text = '${_registrationEndDate!.year}-${_registrationEndDate!.month}-${_registrationEndDate!.day}';
            } catch (e) {
              print('解析报名截止日期失败: $e');
            }
          }
          // 选岗信息相关字段
          _postNameController.text = extractedData['postName'] ?? '';
          _postLocationController.text = extractedData['postLocation'] ?? '';
          _unitCodeController.text = extractedData['unitCode'] ?? '';
          _postCodeController.text = extractedData['postCode'] ?? '';
          _recruitCountController.text = extractedData['recruitCount'] ?? '';
          _interviewRatioController.text = extractedData['interviewRatio'] ?? '';
          _loadingProgress = 1.0;
        });

        // 显示识别结果
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OCR识别成功'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );

        // 重置加载状态
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _isLoading = false;
            _loadingProgress = 0.0;
          });
        });
      } catch (e) {
        // 关闭加载窗口
        Navigator.pop(context);
        
        setState(() {
          _isLoading = false;
          _loadingProgress = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OCR识别失败: $e'),
            backgroundColor: AppTheme.errorColor,
            duration: Duration(seconds: 2),
          ),
        );
      }

    }
  }

  Future<void> _openLink() async {
    String link = _linkController.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请输入链接'),
          backgroundColor: AppTheme.errorColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 确保链接格式正确
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      link = 'https://$link';
    }

    // 显示对话框，让用户确认并复制链接
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Text('打开链接', style: TextStyle(color: AppTheme.textPrimary)),
          content: Text('链接: $link', style: TextStyle(color: AppTheme.textPrimary)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消', style: TextStyle(color: AppTheme.textPrimary)),
            ),
            TextButton(
              onPressed: () {
                // 这里可以添加复制链接到剪贴板的功能
                // 由于环境限制，我们只显示链接
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('链接已复制到剪贴板'),
                    backgroundColor: AppTheme.successColor,
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('复制链接', style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveJob() async {
    if (_formKey.currentState!.validate()) {
      Job job = Job(
        id: widget.job?.id,
        type: _type,
        companyName: _companyNameController.text,
        positionName: _positionNameController.text,
        location: _locationController.text,
        jobDescription: _jobDescriptionController.text,
        requirements: _requirementsController.text,
        salary: _salaryController.text,
        platform: _platformController.text,
        link: _linkController.text,
        companyType: _companyTypeController.text,
        fundingStatus: _fundingStatusController.text,
        companySize: _companySizeController.text,
        industry: _industryController.text,
        status: _status,
        // 考试公告相关字段
        examName: _examNameController.text,
        examDate: _examDate,
        examSubjects: _examSubjectsController.text,
        interviewDate: _interviewDate,
        registrationStartDate: _registrationStartDate,
        registrationEndDate: _registrationEndDate,
        registrationEndTime: _registrationEndTimeController.text,
        examInfo: _examInfoController.text,
        // 选岗信息相关字段
        postName: _postNameController.text,
        postLocation: _postLocationController.text,
        unitCode: _unitCodeController.text,
        postCode: _postCodeController.text,
        recruitCount: _recruitCountController.text.isNotEmpty ? int.tryParse(_recruitCountController.text) : null,
        interviewRatio: _interviewRatioController.text,
        applicationDate: widget.job?.applicationDate ?? DateTime.now(),
        imagePath: _selectedImage?.path,
      );
      if (widget.job != null) {
        await DatabaseHelper.instance.update(job);
      } else {
        await DatabaseHelper.instance.insert(job);
      }
      // 同步到云端数据库
      await FirebaseService.syncJobToCloud(job);
      Navigator.pop(context);
    } else {
      // 表单验证失败，显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请填写所有必填字段'),
          backgroundColor: AppTheme.errorColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _companyNameController.clear();
    _positionNameController.clear();
    _locationController.clear();
    _jobDescriptionController.clear();
    _requirementsController.clear();
    _salaryController.clear();
    _platformController.clear();
    _linkController.clear();
    _companyTypeController.clear();
    _fundingStatusController.clear();
    _companySizeController.clear();
    _industryController.clear();
    _status = '未报名';
    // 考试公告相关字段
    _examNameController.clear();
    _examSubjectsController.clear();
    _examDate = null;
    _examDateController.clear();
    _interviewDate = null;
    _interviewDateController.clear();
    _registrationStartDate = null;
    _registrationStartDateController.clear();
    _registrationEndDate = null;
    _registrationEndDateController.clear();
    _registrationEndTimeController.clear();
    _examInfoController.clear();
    // 选岗信息相关字段
    _postNameController.clear();
    _postLocationController.clear();
    _unitCodeController.clear();
    _postCodeController.clear();
    _recruitCountController.clear();
    _interviewRatioController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GeometricBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_type == 'company' ? '添加企业招聘' : '添加考试公告'),
          backgroundColor: AppTheme.cardBackground.withOpacity(0.9),
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
          // 表单内容
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, color: AppTheme.textPrimary),
                                SizedBox(width: 8),
                                Text(
                                  '从截图识别',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _openLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.link, color: AppTheme.textPrimary),
                                SizedBox(width: 8),
                                Text(
                                  '打开链接',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    if (_type == 'company') ...[
                      TextFormField(
                        controller: _companyNameController,
                        decoration: InputDecoration(
                          labelText: '公司名称',
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
                        validator: (value) => value!.isEmpty ? '请输入公司名称' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _positionNameController,
                        decoration: InputDecoration(
                          labelText: '职位名称',
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
                        validator: (value) => value!.isEmpty ? '请输入职位名称' : null,
                      ),
                      SizedBox(height: 16),
                    ] else ...[
                      TextFormField(
                        controller: _examNameController,
                        decoration: InputDecoration(
                          labelText: '公告名称',
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
                        validator: (value) => value!.isEmpty ? '请输入公告名称' : null,
                      ),
                      SizedBox(height: 16),
                    ],
                    if (_type == 'company') ...[
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: '工作地点',
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
                        validator: (value) => value!.isEmpty ? '请输入工作地点' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _salaryController,
                        decoration: InputDecoration(
                          labelText: '薪资范围',
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
                      TextFormField(
                        controller: _platformController,
                        decoration: InputDecoration(
                          labelText: '招聘平台',
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
                    ],
                    TextFormField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        labelText: _type == 'company' ? '原始链接' : '公告链接',
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
                    if (_type == 'company') ...[
                      TextFormField(
                        controller: _companyTypeController,
                        decoration: InputDecoration(
                          labelText: '单位性质',
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
                      // 企业招聘特有字段
                      
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _fundingStatusController,
                        decoration: InputDecoration(
                          labelText: '融资情况',
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
                      TextFormField(
                        controller: _companySizeController,
                        decoration: InputDecoration(
                          labelText: '公司规模',
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
                      TextFormField(
                        controller: _industryController,
                        decoration: InputDecoration(
                          labelText: '行业领域',
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
                      TextFormField(
                        controller: _jobDescriptionController,
                        decoration: InputDecoration(
                          labelText: '岗位职责',
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
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _requirementsController,
                        decoration: InputDecoration(
                          labelText: '任职要求',
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
                    // 考试公告相关字段
                    if (_type == 'exam') ...[
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _requirementsController,
                        decoration: InputDecoration(
                          labelText: '报名要求',
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
                      SizedBox(height: 24),
                      Text(
                        '报名时间',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '开始日期',
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
                              controller: _registrationStartDateController,
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _registrationStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _registrationStartDate = picked;
                                  _registrationStartDateController.text = '${picked.year}-${picked.month}-${picked.day}';
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '截止日期',
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
                              controller: _registrationEndDateController,
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _registrationEndDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _registrationEndDate = picked;
                                  _registrationEndDateController.text = '${picked.year}-${picked.month}-${picked.day}';
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('选择日期'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _registrationEndTimeController,
                        decoration: InputDecoration(
                          labelText: '截止时间',
                          labelStyle: TextStyle(color: AppTheme.textSecondary),
                          hintText: '例如：23:59',
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
                      SizedBox(height: 24),
                      Text(
                        '考试信息',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
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
                      TextFormField(
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
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '考试日期',
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
                              controller: _examDateController,
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _examDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _examDate = picked;
                                  _examDateController.text = '${picked.year}-${picked.month}-${picked.day}';
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '面试日期',
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
                              controller: _interviewDateController,
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _interviewDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _interviewDate = picked;
                                  _interviewDateController.text = '${picked.year}-${picked.month}-${picked.day}';
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('选择日期'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
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
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      onChanged: (value) => setState(() => _status = value!),
                      items: [
                        '未报名',
                        '已报名',
                        '笔试中',
                        '面试',
                        '待录取',
                        '已拒绝',
                        '已感谢'
                      ].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                      decoration: InputDecoration(
                        labelText: '状态',
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
                    // 原始图像显示
                    if (_selectedImage != null) ...[
                      SizedBox(height: 24),
                      Text(
                        '原始图像',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: AppTheme.glassmorphism,
                        padding: EdgeInsets.all(16),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _saveJob,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _type == 'company' ? AppTheme.primaryColor : AppTheme.accentColor,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            '保存',
                            style: TextStyle(
                              color: AppTheme.background,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _resetForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.textSecondary.withOpacity(0.2),
                            foregroundColor: AppTheme.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            '重置',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          // 加载状态
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: LoadingIndicator(
                  message: '正在识别图片...',
                  progress: _loadingProgress,
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }
}