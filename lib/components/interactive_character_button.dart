import 'package:flutter/material.dart';
import 'package:job_tracker/theme/app_theme.dart';

class InteractiveCharacterButton extends StatefulWidget {
  final double size;

  const InteractiveCharacterButton({
    super.key,
    this.size = 60,
  });

  @override
  _InteractiveCharacterButtonState createState() => _InteractiveCharacterButtonState();
}

class _InteractiveCharacterButtonState extends State<InteractiveCharacterButton> {
  bool _isPressed = false;
  String _currentMessage = '点击我获取鼓励！';
  bool _showMessage = false;

  void _onTap() {
    setState(() {
      _isPressed = true;
      _currentMessage = AppTheme.getRandomEncouragingMessage();
      _showMessage = true;
    });

    // 3秒后隐藏消息
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showMessage = false;
      });
    });

    // 动画结束后恢复按钮状态
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _isPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // 互动按钮
        GestureDetector(
          onTap: _onTap,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Transform.scale(
              scale: _isPressed ? 0.9 : 1.0,
              child: Center(
                child: Text(
                  '🤖',
                  style: TextStyle(fontSize: widget.size * 0.6),
                ),
              ),
            ),
          ),
        ),
        // 鼓励消息气泡
        if (_showMessage)
          Positioned(
            bottom: widget.size + 10,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(maxWidth: 200),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.secondaryColor.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _currentMessage,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        // 消息气泡的小三角
        if (_showMessage)
          Positioned(
            bottom: widget.size + 5,
            right: 20,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                border: Border.all(
                  color: AppTheme.secondaryColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              transform: Matrix4.identity()
                ..translate(0.0, 0.0)
                ..rotateZ(45 * 3.14159 / 180),
            ),
          ),
      ],
    );
  }
}