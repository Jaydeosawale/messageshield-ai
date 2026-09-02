// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MessageShield';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinMessageShield => 'Join MessageShield';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get createSecureAccount => 'Create Secure Account';

  @override
  String get home => 'Home';

  @override
  String get scan => 'Scan';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get safety => 'Safety';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get marathi => 'मराठी';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get yourAccountIsProtected => 'Your account is protected';

  @override
  String get verifyYourEmail => 'Verify your email';

  @override
  String get emailVerifiedSuccessfully => 'Email verified successfully.';

  @override
  String get resendEmail => 'Resend email';

  @override
  String get securityDashboard => 'Security Dashboard';

  @override
  String get securityOverview => 'Security Overview';

  @override
  String get recentAnalyses => 'Recent Analyses';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get security => 'Security';

  @override
  String get privacy => 'Privacy';

  @override
  String get administrator => 'Administrator';

  @override
  String get analyzedMessage => 'Analyzed Message';

  @override
  String get classification => 'Classification';

  @override
  String get securitySignals => 'Security Signals';

  @override
  String get modelProbabilities => 'Model Probabilities';

  @override
  String get analysisInformation => 'Analysis Information';

  @override
  String get analysisHistory => 'Analysis History';

  @override
  String get all => 'All';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get pasteMessage => 'Paste the message you received here...';

  @override
  String get retry => 'Retry';

  @override
  String get scanMessage => 'Scan message';

  @override
  String get confidenceDistribution => 'Confidence distribution across categories';

  @override
  String get technicalDetailsForResult => 'Technical details for this result';

  @override
  String get analysisId => 'Analysis ID';

  @override
  String get aiModel => 'AI Model';

  @override
  String get modelVersion => 'Model Version';

  @override
  String get analyzedAt => 'Analyzed At';

  @override
  String get couldNotLoadDashboard => 'Could not load dashboard';

  @override
  String get securityDashboardDescription => 'Review your message security analysis.';

  @override
  String get yourMessageSecurityActivity => 'Your message security activity';

  @override
  String get latestMessageSecurityChecks => 'Latest message security checks';

  @override
  String get userId => 'User ID';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get accountRole => 'Account Role';

  @override
  String get changeAccountPassword => 'Change your account password.';

  @override
  String get setPasswordForEmailSignIn => 'Set a password for email and password sign-in.';

  @override
  String get messageShieldKeepsDataProtected => 'MessageShield keeps your analysis data protected.';

  @override
  String get youHaveAdministratorAccess => 'You have administrator access.';

  @override
  String get adminToolsAuthorizedOnly => 'Administrative tools and system statistics should only be visible to authorized users.';

  @override
  String get adminControlsRestricted => 'Admin controls are restricted to administrator accounts.';

  @override
  String get unableToLoadAnalysisHistory => 'Unable to load analysis history';

  @override
  String get noAnalysesFound => 'No analyses found';

  @override
  String get messageProcessedByAI => 'The message processed by MessageShield AI';

  @override
  String get aiCategoryPrediction => 'AI category prediction';

  @override
  String get detectedCategory => 'Detected Category';

  @override
  String get predictionConfidence => 'Prediction Confidence';

  @override
  String get signalsDetectedDuringAnalysis => 'Signals detected during analysis';

  @override
  String get verificationEmailTitle => 'Verify your email';

  @override
  String verificationEmailInstructions(Object email) {
    return 'We sent a verification link to $email.\n\nOpen the email from MessageShield and click the verification link. Then return here and tap \"I\'ve verified my email\".';
  }

  @override
  String get verificationEmailSentAgain => 'Verification email sent again. Please check your inbox or spam folder.';

  @override
  String get createAccountDescription => 'Create your secure account and start analyzing suspicious messages.';

  @override
  String get or => 'OR';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordMinimumLength => 'Password must be at least 8 characters';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Login';

  @override
  String get accountCreatedWithGoogle => 'Account created successfully with Google.';

  @override
  String get verifiedEmailButton => 'I\'ve verified my email';

  @override
  String get signedInSuccessfully => 'Successfully signed in.';

  @override
  String get verifyEmailBeforeSignIn => 'Please verify your email address before signing in.\n\nYou can resend the verification email below.';

  @override
  String get verificationEmailSent => 'Verification email sent. Please check your inbox.';

  @override
  String get unableToResendVerificationEmail => 'Unable to resend verification email.';

  @override
  String get risky => 'Risky';

  @override
  String get safeMessages => 'Safe Messages';

  @override
  String get highRisk => 'High Risk';

  @override
  String get safe => 'Safe';

  @override
  String get messagesChecked => 'Messages checked';

  @override
  String get needAttention => 'Need attention';

  @override
  String get messageSecurity => 'Message Security';

  @override
  String get recentActivitySecure => 'Your recent activity looks secure';

  @override
  String get messagesNeedAttention => 'Some messages need attention';

  @override
  String get aiPoweredMessageSecurity => 'AI-powered message security';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToProtectMessages => 'Sign in to protect and analyze your messages.';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get secureLogin => 'Secure Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get secureAiProtection => 'Secure AI-powered protection';

  @override
  String get emailNotVerified => 'Email not verified';

  @override
  String get successfullySignedInWithGoogle => 'Successfully signed in with Google.';

  @override
  String get googleAccountNotFound => 'No MessageShield account was found for this Google account. Please create an account first.';

  @override
  String get googleSignInCancelled => 'Google sign-in was cancelled.';

  @override
  String get googlePopupBlocked => 'Google sign-in popup was blocked. Please allow popups and try again.';

  @override
  String get googleSignInNotEnabled => 'Google sign-in is not enabled.';

  @override
  String get googleSignInNotConfigured => 'Google sign-in is not configured correctly.';

  @override
  String get pleaseVerifyEmail => 'Please verify your email address before signing in. Check your inbox for the verification email.';

  @override
  String get invalidEmailOrPassword => 'Invalid email or password.';

  @override
  String get unableToConnectServer => 'Unable to connect to the server. Please check your internet connection and try again.';

  @override
  String get requestTimedOut => 'The request timed out. Please try again.';

  @override
  String get unableToSignIn => 'Unable to sign in. Please try again.';

  @override
  String get unableToSignInWithGoogle => 'Unable to sign in with Google. Please try again.';

  @override
  String get accountInactive => 'Your account is currently inactive.';

  @override
  String get registerFirst => 'Please register first.';

  @override
  String get stayProtected => 'Stay Protected.';

  @override
  String get checkSuspiciousMessages => 'Check suspicious messages safely before you act.';

  @override
  String get analyzing => 'ANALYZING...';

  @override
  String get analyzeMessage => 'ANALYZE MESSAGE';

  @override
  String get clearMessage => 'Clear message';

  @override
  String get safetyGuidelines => 'Safety guidelines';

  @override
  String get otpAndPasswords => 'OTP and passwords';

  @override
  String get neverShareSensitiveCodes => 'Never share OTPs, passwords, PINs or CVV values.';

  @override
  String get suspiciousLinks => 'Suspicious links';

  @override
  String get avoidUnknownLinks => 'Avoid unknown links and verify organisations through official channels.';

  @override
  String get paymentScams => 'Payment scams';

  @override
  String get verifyPaymentRequests => 'Verify payment requests before sending money.';

  @override
  String get verifyTheSender => 'Verify the sender';

  @override
  String get familiarNameNotGuarantee => 'A familiar name does not guarantee that a message is genuine.';

  @override
  String get mediumRisk => 'Medium Risk';

  @override
  String get lowRisk => 'Low Risk';

  @override
  String get confidence => 'confidence';

  @override
  String get score => 'Score';

  @override
  String get risk => 'Risk';

  @override
  String get riskHigh => 'High Risk';

  @override
  String get riskMedium => 'Medium Risk';

  @override
  String get riskLow => 'Low Risk';

  @override
  String get messageType => 'Message Type';

  @override
  String get alert => 'Alert';

  @override
  String get whyWeFlaggedThis => 'Why We Flagged This';

  @override
  String get safetyCheck => 'Safety Check';

  @override
  String get whatYouShouldDo => 'What You Should Do';

  @override
  String get analysisConfidence => 'Analysis confidence';

  @override
  String get adminAnalysisDetails => 'Admin Analysis Details';

  @override
  String get riskScore => 'Risk score';

  @override
  String get categoryConfidence => 'Category confidence';

  @override
  String get categoryModel => 'Category model';

  @override
  String get safetyLabel => 'Safety label';

  @override
  String get safetyConfidence => 'Safety confidence';

  @override
  String get safetyModel => 'Safety model';

  @override
  String get categoryProbabilities => 'Category Probabilities';

  @override
  String get safetyProbabilities => 'Safety Probabilities';

  @override
  String get notAvailable => 'Not available';

  @override
  String get securityAnalysisCompleted => 'Security analysis completed.';

  @override
  String get highRiskAlert => 'This message may be unsafe. Do not click links or share OTPs, passwords, PINs, CVV, or banking details.';

  @override
  String get mediumRiskAlert => 'This message contains some indicators that need verification. Confirm the sender through an official channel before acting.';

  @override
  String get lowRiskAlert => 'No major risk indicators were detected. Still verify unexpected requests before sharing personal information or making payments.';

  @override
  String get doNotClickSuspiciousLinks => 'Do not click suspicious links.';

  @override
  String get doNotShareSensitiveCodes => 'Do not share OTPs, passwords, PINs or CVV.';

  @override
  String get verifyOrganisationOfficial => 'Verify the organisation using an official website or number.';

  @override
  String get verifySenderIndependently => 'Verify the sender independently.';

  @override
  String get avoidMessageLinks => 'Avoid using links from the message until verified.';

  @override
  String get doNotShareSensitiveInformation => 'Do not share sensitive information.';

  @override
  String get stayCautiousUnexpectedRequests => 'Stay cautious with unexpected requests.';

  @override
  String get verifyPaymentAccountRequests => 'Verify payment or account requests independently.';

  @override
  String get analysisDetails => 'Analysis Details';

  @override
  String get riskDescriptionHigh => 'This message contains strong indicators of potential risk.';

  @override
  String get riskDescriptionMedium => 'This message contains some suspicious indicators. Review carefully.';

  @override
  String get riskDescriptionLow => 'No major threat indicators were detected in this message.';

  @override
  String get riskInformationUnavailable => 'Risk information is unavailable.';

  @override
  String get riskScoreLabel => 'Risk Score';

  @override
  String get informationAboutAnalysis => 'Information about this analysis';

  @override
  String get unknown => 'Unknown';

  @override
  String get yourRecentMessageSafetyChecks => 'Your recent message safety checks';

  @override
  String get messageAnalysis => 'Message analysis';

  @override
  String get loadingAnalysisHistory => 'Loading your analysis history...';

  @override
  String get noAnalysesYet => 'No analyses yet';

  @override
  String get analyzedMessagesAppearHere => 'Your analyzed messages will appear here so you can review their safety results anytime.';

  @override
  String get unableToLoadHistory => 'Unable to load history';

  @override
  String get totalAnalyses => 'Total Analyses';

  @override
  String get messagesCheckedForThreats => 'Messages checked for threats';

  @override
  String get analyzeMessageToStart => 'Analyze a message to start building your security activity.';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get pleaseVerifyEmailFirst => 'Please verify your email first.';

  @override
  String get iveVerifiedMyEmail => 'I\'ve verified my email';

  @override
  String get accountWithEmailAlreadyExists => 'An account with this email already exists. Please sign in instead.';

  @override
  String get unableToCreateAccount => 'Unable to create your account. Please try again.';

  @override
  String get accountExistsLoginInstead => 'An account already exists with this email. Please log in instead.';

  @override
  String get emailPasswordProviderConflict => 'This email is already registered with email and password. Please log in with your password.';

  @override
  String get firebaseAuthVerificationFailed => 'Firebase authentication verification failed.';

  @override
  String get unsupportedPlatform => 'Google sign-in is not supported on this platform.';

  @override
  String get unableToContinueWithGoogle => 'Unable to continue with Google. Please try again.';

  @override
  String get unableToScanMessage => 'Unable to scan the message.';

  @override
  String get noReadableTextFound => 'No readable text was found in the image.';

  @override
  String get pasteOrScanMessageFirst => 'Paste or scan a message first.';

  @override
  String get captureMessageDescription => 'Capture a message with your camera or select a screenshot/image.';

  @override
  String get scanWithCamera => 'SCAN WITH CAMERA';

  @override
  String get chooseImage => 'CHOOSE IMAGE';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully.';

  @override
  String get passwordSetSuccessfully => 'Password set successfully. You can now sign in with Google or email and password.';

  @override
  String get logoutQuestion => 'Logout?';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout from MessageShield?';

  @override
  String get activeAccount => 'Active Account';

  @override
  String get inactiveAccount => 'Inactive Account';

  @override
  String get smartPrivateProtected => 'Smart. Private. Protected.';

  @override
  String get noSuspiciousSignalsDetected => 'No suspicious signals detected.';

  @override
  String get aiSafetyAnalysis => 'AI Safety Analysis';

  @override
  String get emailPasswordAccountExists => 'An account with this email already exists using email and password. Please sign in using your email and password.';
}
