class Config {
  static const String glmApiKey = 'YOUR_GLM_API_KEY_HERE';
  
  static void initialize() {
    OCRHelper.apiKey = glmApiKey;
  }
}
