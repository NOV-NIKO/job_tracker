import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OCRHelper {
  // GLM-4.6V-FlashX API配置
  // 请在 config.dart 文件中配置你的 API 密钥
  static String apiKey = ''; // 请在 config.dart 中设置
  static const String apiUrl = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';

  // 使用GLM-4.6V-FlashX进行图片识别
  static Future<Map<String, String>> extractJobInfo(dynamic imageData, {String type = 'exam'}) async {
    try {
      print('OCRHelper.extractJobInfo 被调用');
      print('图片数据类型: ${imageData.runtimeType}');
      print('提取类型: $type');
      
      // 直接使用GLM-4.6V-FlashX进行智能识别
      Map<String, String> aiResult = await _extractWithGLM(imageData, type: type);
      return aiResult;
    } catch (e) {
      print('OCR error: $e');
      return {
        'examName': '',
        'province': '',
        'companyType': '',
        'examDate': '',
        'examSubjects': '',
        'interviewDate': '',
        'registrationStartDate': '',
        'registrationEndDate': '',
        'registrationEndTime': '',
        'examInfo': '',
        'postName': '',
        'postLocation': '',
        'unitCode': '',
        'postCode': '',
        'recruitCount': '',
        'interviewRatio': '',
        'analysisStatus': 'failed'
      };
    }
  }

  // 使用GLM-4.6V-FlashX进行智能识别
  static Future<Map<String, String>> _extractWithGLM(dynamic imageData, {String type = 'exam'}) async {
    try {
      String? imageUrl;
      String? base64Image;
      
      print('开始处理图片数据...');
      print('图片数据: $imageData');
      
      // 根据不同平台处理图片数据
      if (imageData is String) {
        // 如果是字符串
        print('图片数据是字符串，长度: ${imageData.length}');
        
        // 检查是否是data URL
        if (imageData.startsWith('data:image/')) {
          print('图片数据包含data:image/前缀');
          // 移除data:image/xxx;base64,前缀
          int commaIndex = imageData.indexOf(',');
          if (commaIndex != -1) {
            base64Image = imageData.substring(commaIndex + 1);
            print('移除前缀后长度: ${base64Image.length}');
          } else {
            base64Image = imageData;
          }
        }
        // 检查是否是HTTP/HTTPS URL
        else if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
          print('图片数据是HTTP/HTTPS URL');
          // 直接使用URL
          imageUrl = imageData;
        }
        // 检查是否是blob URL (Web平台)
        else if (imageData.startsWith('blob:')) {
          print('图片数据是blob URL');
          // 在Web环境中，blob URL需要特殊处理
          // 由于我们不能在移动平台上使用dart:html，这里返回失败
          // 实际的Web平台处理需要在单独的文件中实现
          print('在移动平台上，blob URL不适用');
          return {
            'examName': '',
            'province': '',
            'companyType': '',
            'analysisStatus': 'failed'
          };
        }
        // 检查是否是本地文件路径
        else if (File(imageData).existsSync()) {
          print('图片数据是本地文件路径');
          // 读取文件内容并转换为base64编码
          try {
            File file = File(imageData);
            List<int> bytes = await file.readAsBytes();
            base64Image = base64Encode(bytes);
            print('文件大小: ${bytes.length} 字节');
            print('转换为base64后长度: ${base64Image.length}');
          } catch (e) {
            print('读取文件失败: $e');
            return {
              'companyName': '',
              'positionName': '',
              'salary': '',
              'location': '',
              'analysisStatus': 'failed'
            };
          }
        }
        else {
          // 直接使用字符串作为base64数据
          base64Image = imageData;
        }
      } else if (imageData is List<int>) {
        // 如果是字节列表
        print('图片数据是字节列表，长度: ${imageData.length}');
        base64Image = base64Encode(imageData);
        print('转换为base64后长度: ${base64Image.length}');
      } else {
        // 其他情况，返回失败
        print('不支持的图片数据类型: ${imageData.runtimeType}');
        return {
          'companyName': '',
          'positionName': '',
          'salary': '',
          'location': '',
          'analysisStatus': 'failed'
        };
      }
      
      // 根据类型生成不同的提示词
      String prompt = '';
      if (type == 'company') {
        prompt = '请从这张公司招聘信息页面截图中提取以下信息：\n1. 公司名称（companyName）\n2. 职位名称（positionName）\n3. 薪资（salary）\n4. 工作地点（location）\n5. 招聘平台（recruitmentPlatform）\n6. 原始链接（originalLink）\n7. 公司类型（companyType）\n8. 融资状态（financingStatus）\n9. 公司规模（companySize）\n10. 所属行业（industry）\n11. 工作职责（jobResponsibilities）\n12. 岗位要求（jobRequirements）\n\n请严格按照JSON格式返回，键名必须与上述括号中的名称一致。如果某些信息在图片中不存在，请返回空字符串。';
      } else {
        prompt = '请从这张招考公告页面截图中提取以下信息：\n1. 公告标题（examName）\n2. 省份（province）\n3. 单位性质（companyType）\n4. 考试日期（examDate，格式：YYYY-MM-DD）\n5. 考试科目（examSubjects）\n6. 面试日期（interviewDate，格式：YYYY-MM-DD）\n7. 报名开始日期（registrationStartDate，格式：YYYY-MM-DD）\n8. 报名截止日期（registrationEndDate，格式：YYYY-MM-DD）\n9. 报名截止时间（registrationEndTime）\n10. 考试信息（examInfo）\n11. 岗位名称（postName）\n12. 岗位地点（postLocation）\n13. 单位编码（unitCode）\n14. 岗位编码（postCode）\n15. 招生人数（recruitCount）\n16. 面试比例（interviewRatio）\n\n请严格按照JSON格式返回，键名必须与上述括号中的名称一致。如果某些信息在图片中不存在，请返回空字符串。';
      }
      
      // 构建请求体
      Map<String, dynamic> requestBody = {
        'model': 'glm-4.6v-flashx',
        'messages': [
          {
            'role': 'system',
            'content': '你是一个专业的信息提取助手，能够准确识别并提取图片中的关键信息。请严格按照要求的格式返回数据。'
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': prompt
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': imageUrl ?? 'data:image/jpeg;base64,$base64Image'
                }
              }
            ]
          }
        ],
        'temperature': 0.0,
        'stream': false
      };
      
      // 发送请求
      print('正在调用GLM-4.6V-FlashX API...');
      if (imageUrl != null) {
        print('使用图片URL: $imageUrl');
      } else {
        print('图片数据长度: ${base64Image!.length}');
      }
      
      // 构建HTTP请求
      var request = http.Request('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      });
      request.body = jsonEncode(requestBody);
      
      // 发送请求并获取响应
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      print('GLM API响应状态码: ${response.statusCode}');
      print('GLM API响应: $responseBody');
      
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(responseBody);
        String assistantMessage = responseData['choices'][0]['message']['content'];
        print('GLM API助手消息: $assistantMessage');
        
        // 增加调试输出，打印原始响应
        print('--- GLM API 原始响应 ---');
        print(assistantMessage);
        print('--- GLM API 原始响应结束 ---');

        // 提取JSON部分
        RegExp jsonRegex = RegExp(r'\{[\s\S]*\}');
        Match? match = jsonRegex.firstMatch(assistantMessage);
        if (match != null) {
          String jsonString = match.group(0)!;
          Map<String, dynamic> extractedData = jsonDecode(jsonString);
          
          // 转换为Map<String, String>
          Map<String, String> result = {
            'analysisStatus': 'success',
            'rawResponse': assistantMessage // 添加原始响应
          };
          
          // 根据类型提取不同的字段
          if (type == 'company') {
            // 公司招聘信息
            if (extractedData.containsKey('companyName')) {
              result['companyName'] = extractedData['companyName'].toString();
            }
            if (extractedData.containsKey('positionName')) {
              result['positionName'] = extractedData['positionName'].toString();
            }
            if (extractedData.containsKey('salary')) {
              result['salary'] = extractedData['salary'].toString();
            }
            if (extractedData.containsKey('location')) {
              result['location'] = extractedData['location'].toString();
            }
            if (extractedData.containsKey('recruitmentPlatform')) {
              result['recruitmentPlatform'] = extractedData['recruitmentPlatform'].toString();
            }
            if (extractedData.containsKey('originalLink')) {
              result['originalLink'] = extractedData['originalLink'].toString();
            }
            if (extractedData.containsKey('companyType')) {
              result['companyType'] = extractedData['companyType'].toString();
            }
            if (extractedData.containsKey('financingStatus')) {
              result['financingStatus'] = extractedData['financingStatus'].toString();
            }
            if (extractedData.containsKey('companySize')) {
              result['companySize'] = extractedData['companySize'].toString();
            }
            if (extractedData.containsKey('industry')) {
              result['industry'] = extractedData['industry'].toString();
            }
            if (extractedData.containsKey('jobResponsibilities')) {
              result['jobResponsibilities'] = extractedData['jobResponsibilities'].toString();
            }
            if (extractedData.containsKey('jobRequirements')) {
              result['jobRequirements'] = extractedData['jobRequirements'].toString();
            }
          } else {
            // 招考公告信息
            if (extractedData.containsKey('examName')) {
              result['examName'] = extractedData['examName'].toString();
            }
            if (extractedData.containsKey('province')) {
              result['province'] = extractedData['province'].toString();
            }
            if (extractedData.containsKey('companyType')) {
              result['companyType'] = extractedData['companyType'].toString();
            }
            if (extractedData.containsKey('examDate')) {
              result['examDate'] = extractedData['examDate'].toString();
            }
            if (extractedData.containsKey('examSubjects')) {
              result['examSubjects'] = extractedData['examSubjects'].toString();
            }
            if (extractedData.containsKey('interviewDate')) {
              result['interviewDate'] = extractedData['interviewDate'].toString();
            }
            if (extractedData.containsKey('registrationStartDate')) {
              result['registrationStartDate'] = extractedData['registrationStartDate'].toString();
            }
            if (extractedData.containsKey('registrationEndDate')) {
              result['registrationEndDate'] = extractedData['registrationEndDate'].toString();
            }
            if (extractedData.containsKey('registrationEndTime')) {
              result['registrationEndTime'] = extractedData['registrationEndTime'].toString();
            }
            if (extractedData.containsKey('examInfo')) {
              result['examInfo'] = extractedData['examInfo'].toString();
            }
            if (extractedData.containsKey('postName')) {
              result['postName'] = extractedData['postName'].toString();
            }
            if (extractedData.containsKey('postLocation')) {
              result['postLocation'] = extractedData['postLocation'].toString();
            }
            if (extractedData.containsKey('unitCode')) {
              result['unitCode'] = extractedData['unitCode'].toString();
            }
            if (extractedData.containsKey('postCode')) {
              result['postCode'] = extractedData['postCode'].toString();
            }
            if (extractedData.containsKey('recruitCount')) {
              result['recruitCount'] = extractedData['recruitCount'].toString();
            }
            if (extractedData.containsKey('interviewRatio')) {
              result['interviewRatio'] = extractedData['interviewRatio'].toString();
            }
          }
          
          return result;
        } else {
          print('无法从响应中提取JSON数据');
          return {
            'examName': '',
            'province': '',
            'companyType': '',
            'analysisStatus': 'failed',
            'errorCode': 'JSON_PARSE_ERROR',
            'errorMessage': '无法从响应中提取JSON数据'
          };
        }
      } else {
        print('GLM API错误: ${response.statusCode} $responseBody');
        // 检查是否是访问量过大错误
        if (response.statusCode == 429) {
          print('GLM API访问量过大，将使用备用方案');
        }
        return {
          'companyName': '',
          'positionName': '',
          'salary': '',
          'location': '',
          'analysisStatus': 'failed',
          'errorCode': 'API_ERROR_${response.statusCode}',
          'errorMessage': 'GLM API错误: ${response.statusCode} $responseBody'
        };
      }
    } catch (e) {
      print('GLM API error: $e');
      return {
        'companyName': '',
        'positionName': '',
        'salary': '',
        'location': '',
        'analysisStatus': 'failed',
        'errorCode': 'NETWORK_ERROR',
        'errorMessage': '网络错误: $e'
      };
    }
  }


}