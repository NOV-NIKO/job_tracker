import 'package:flutter/material.dart';

class AppTheme {
  // Cyber-Noir 配色方案
  static const Color primaryColor = Color(0xFF00F0FF); // 霓虹青
  static const Color secondaryColor = Color(0xFF007AFF); // 蓝色
  static const Color accentColor = Color(0xFF00F0FF); // 霓虹青
  static const Color background = Color(0xFF0A0C10); // 深邃黑
  static const Color cardBackground = Color(0xFF14171F); // 卡片背景
  static const Color textPrimary = Color(0xFFFFFFFF); // 白色文本
  static const Color textSecondary = Color(0xB3FFFFFF); // 半透明白色
  static const Color successColor = Color(0xFF00F0FF); // 霓虹青
  static const Color warningColor = Color(0xFFFFC107); // 黄色
  static const Color errorColor = Color(0xFFF44336); // 红色

  // 背景渐变
  static LinearGradient get backgroundGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        background,
        Color(0xFF1A1D27),
        Color(0xFF0A0C10),
      ],
      stops: [0.0, 0.5, 1.0],
    );
  }

  // 卡片渐变
  static LinearGradient get cardGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x8014171F),
        Color(0x4014171F),
      ],
    );
  }

  // 考试公告卡片渐变
  static LinearGradient get examCardGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x8014171F),
        Color(0x4014171F),
      ],
    );
  }

  // 玻璃拟态效果
  static BoxDecoration get glassmorphism {
    return BoxDecoration(
      color: cardBackground.withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: primaryColor.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.1),
          spreadRadius: 5,
          blurRadius: 15,
          offset: Offset(0, 5),
        ),
      ],
    );
  }

  // 流光边框
  static BoxDecoration get glowingBorder {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: primaryColor.withOpacity(0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 10,
          offset: Offset(0, 0),
        ),
      ],
    );
  }

  // 主主题
  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      secondaryHeaderColor: secondaryColor,
      scaffoldBackgroundColor: background,
      cardColor: cardBackground,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        bodyMedium: TextStyle(color: textSecondary, fontFamily: 'Inter'),
        headlineLarge: TextStyle(color: textPrimary, fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: textPrimary, fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontFamily: 'SpaceGrotesk'),
        titleMedium: TextStyle(color: textPrimary, fontFamily: 'SpaceGrotesk'),
        titleSmall: TextStyle(color: textPrimary, fontFamily: 'SpaceGrotesk'),
        labelLarge: TextStyle(color: textSecondary, fontFamily: 'JetBrainsMono'),
        labelMedium: TextStyle(color: textSecondary, fontFamily: 'JetBrainsMono'),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardBackground.withOpacity(0.8),
        elevation: 0,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold),
        shadowColor: primaryColor.withOpacity(0.1),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBackground.withOpacity(0.8),
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: background,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: cardBackground.withOpacity(0.6),
        filled: true,
        hintStyle: TextStyle(color: textSecondary, fontFamily: 'Inter'),
        labelStyle: TextStyle(color: textSecondary, fontFamily: 'Inter'),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // 鼓励的话
  static List<String> encouragingMessages = [
    '加油！你的梦想就在前方！',
    '每一次投递都是向成功迈进的一步',
    '相信自己，你一定能找到理想的工作',
    '坚持就是胜利，求职路上你不孤单',
    '今天的努力，明天的收获',
    '你很棒，继续保持！',
    '机会总是留给有准备的人',
    '每一次面试都是成长的机会',
    '不要放弃，成功就在下一个转角',
    '你已经做得很好了，继续加油！'
  ];

  // 随机获取鼓励的话
  static String getRandomEncouragingMessage() {
    final random = DateTime.now().millisecondsSinceEpoch % encouragingMessages.length;
    return encouragingMessages[random];
  }
}