// Web平台专用的OCR助手实现
// 只在Web平台上导入dart:html库

import 'dart:html' as html;

class OCRHelperWeb {
  // 将blob URL转换为base64编码 (Web平台专用)
  static Future<String> convertBlobUrlToBase64(String blobUrl) async {
    try {
      // 使用fetch API获取blob数据
      var response = await html.HttpRequest.request(
        blobUrl,
        method: 'GET',
        responseType: 'blob'
      );
      
      // 获取blob对象
      var blob = response.response as html.Blob;
      
      // 创建FileReader来读取blob数据
      var reader = html.FileReader();
      
      // 开始读取blob数据为data URL
      reader.readAsDataUrl(blob);
      
      // 等待读取完成
      await reader.onLoad.first;
      
      // 读取结果是data URL，需要提取base64部分
      String dataUrl = reader.result as String;
      int commaIndex = dataUrl.indexOf(',');
      if (commaIndex != -1) {
        return dataUrl.substring(commaIndex + 1);
      }
      return '';
    } catch (e) {
      print('转换blob URL失败: $e');
      return '';
    }
  }
}