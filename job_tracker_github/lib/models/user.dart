class User {
  static String? avatarPath;
  static String username = '用户';
  static String encouragement = '加油，你一定能找到理想的工作！';

  static void updateAvatar(String? path) {
    avatarPath = path;
  }

  static void updateUserInfo(String name, String message) {
    username = name;
    encouragement = message;
  }
}
