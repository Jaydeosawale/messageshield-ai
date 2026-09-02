import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MessageShield'**
  String get appName;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinMessageShield.
  ///
  /// In en, this message translates to:
  /// **'Join MessageShield'**
  String get joinMessageShield;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @createSecureAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Secure Account'**
  String get createSecureAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get marathi;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @yourAccountIsProtected.
  ///
  /// In en, this message translates to:
  /// **'Your account is protected'**
  String get yourAccountIsProtected;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmail;

  /// No description provided for @emailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully.'**
  String get emailVerifiedSuccessfully;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @securityDashboard.
  ///
  /// In en, this message translates to:
  /// **'Security Dashboard'**
  String get securityDashboard;

  /// No description provided for @securityOverview.
  ///
  /// In en, this message translates to:
  /// **'Security Overview'**
  String get securityOverview;

  /// No description provided for @recentAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Recent Analyses'**
  String get recentAnalyses;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @analyzedMessage.
  ///
  /// In en, this message translates to:
  /// **'Analyzed Message'**
  String get analyzedMessage;

  /// No description provided for @classification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get classification;

  /// No description provided for @securitySignals.
  ///
  /// In en, this message translates to:
  /// **'Security Signals'**
  String get securitySignals;

  /// No description provided for @modelProbabilities.
  ///
  /// In en, this message translates to:
  /// **'Model Probabilities'**
  String get modelProbabilities;

  /// No description provided for @analysisInformation.
  ///
  /// In en, this message translates to:
  /// **'Analysis Information'**
  String get analysisInformation;

  /// No description provided for @analysisHistory.
  ///
  /// In en, this message translates to:
  /// **'Analysis History'**
  String get analysisHistory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @pasteMessage.
  ///
  /// In en, this message translates to:
  /// **'Paste the message you received here...'**
  String get pasteMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @scanMessage.
  ///
  /// In en, this message translates to:
  /// **'Scan message'**
  String get scanMessage;

  /// No description provided for @confidenceDistribution.
  ///
  /// In en, this message translates to:
  /// **'Confidence distribution across categories'**
  String get confidenceDistribution;

  /// No description provided for @technicalDetailsForResult.
  ///
  /// In en, this message translates to:
  /// **'Technical details for this result'**
  String get technicalDetailsForResult;

  /// No description provided for @analysisId.
  ///
  /// In en, this message translates to:
  /// **'Analysis ID'**
  String get analysisId;

  /// No description provided for @aiModel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModel;

  /// No description provided for @modelVersion.
  ///
  /// In en, this message translates to:
  /// **'Model Version'**
  String get modelVersion;

  /// No description provided for @analyzedAt.
  ///
  /// In en, this message translates to:
  /// **'Analyzed At'**
  String get analyzedAt;

  /// No description provided for @couldNotLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Could not load dashboard'**
  String get couldNotLoadDashboard;

  /// No description provided for @securityDashboardDescription.
  ///
  /// In en, this message translates to:
  /// **'Review your message security analysis.'**
  String get securityDashboardDescription;

  /// No description provided for @yourMessageSecurityActivity.
  ///
  /// In en, this message translates to:
  /// **'Your message security activity'**
  String get yourMessageSecurityActivity;

  /// No description provided for @latestMessageSecurityChecks.
  ///
  /// In en, this message translates to:
  /// **'Latest message security checks'**
  String get latestMessageSecurityChecks;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @accountRole.
  ///
  /// In en, this message translates to:
  /// **'Account Role'**
  String get accountRole;

  /// No description provided for @changeAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Change your account password.'**
  String get changeAccountPassword;

  /// No description provided for @setPasswordForEmailSignIn.
  ///
  /// In en, this message translates to:
  /// **'Set a password for email and password sign-in.'**
  String get setPasswordForEmailSignIn;

  /// No description provided for @messageShieldKeepsDataProtected.
  ///
  /// In en, this message translates to:
  /// **'MessageShield keeps your analysis data protected.'**
  String get messageShieldKeepsDataProtected;

  /// No description provided for @youHaveAdministratorAccess.
  ///
  /// In en, this message translates to:
  /// **'You have administrator access.'**
  String get youHaveAdministratorAccess;

  /// No description provided for @adminToolsAuthorizedOnly.
  ///
  /// In en, this message translates to:
  /// **'Administrative tools and system statistics should only be visible to authorized users.'**
  String get adminToolsAuthorizedOnly;

  /// No description provided for @adminControlsRestricted.
  ///
  /// In en, this message translates to:
  /// **'Admin controls are restricted to administrator accounts.'**
  String get adminControlsRestricted;

  /// No description provided for @unableToLoadAnalysisHistory.
  ///
  /// In en, this message translates to:
  /// **'Unable to load analysis history'**
  String get unableToLoadAnalysisHistory;

  /// No description provided for @noAnalysesFound.
  ///
  /// In en, this message translates to:
  /// **'No analyses found'**
  String get noAnalysesFound;

  /// No description provided for @messageProcessedByAI.
  ///
  /// In en, this message translates to:
  /// **'The message processed by MessageShield AI'**
  String get messageProcessedByAI;

  /// No description provided for @aiCategoryPrediction.
  ///
  /// In en, this message translates to:
  /// **'AI category prediction'**
  String get aiCategoryPrediction;

  /// No description provided for @detectedCategory.
  ///
  /// In en, this message translates to:
  /// **'Detected Category'**
  String get detectedCategory;

  /// No description provided for @predictionConfidence.
  ///
  /// In en, this message translates to:
  /// **'Prediction Confidence'**
  String get predictionConfidence;

  /// No description provided for @signalsDetectedDuringAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Signals detected during analysis'**
  String get signalsDetectedDuringAnalysis;

  /// No description provided for @verificationEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verificationEmailTitle;

  /// No description provided for @verificationEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}.\n\nOpen the email from MessageShield and click the verification link. Then return here and tap \"I\'ve verified my email\".'**
  String verificationEmailInstructions(Object email);

  /// No description provided for @verificationEmailSentAgain.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent again. Please check your inbox or spam folder.'**
  String get verificationEmailSentAgain;

  /// No description provided for @createAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your secure account and start analyzing suspicious messages.'**
  String get createAccountDescription;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordMinimumLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinimumLength;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @accountCreatedWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully with Google.'**
  String get accountCreatedWithGoogle;

  /// No description provided for @verifiedEmailButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get verifiedEmailButton;

  /// No description provided for @signedInSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in.'**
  String get signedInSuccessfully;

  /// No description provided for @verifyEmailBeforeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address before signing in.\n\nYou can resend the verification email below.'**
  String get verifyEmailBeforeSignIn;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Please check your inbox.'**
  String get verificationEmailSent;

  /// No description provided for @unableToResendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend verification email.'**
  String get unableToResendVerificationEmail;

  /// No description provided for @risky.
  ///
  /// In en, this message translates to:
  /// **'Risky'**
  String get risky;

  /// No description provided for @safeMessages.
  ///
  /// In en, this message translates to:
  /// **'Safe Messages'**
  String get safeMessages;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @safe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// No description provided for @messagesChecked.
  ///
  /// In en, this message translates to:
  /// **'Messages checked'**
  String get messagesChecked;

  /// No description provided for @needAttention.
  ///
  /// In en, this message translates to:
  /// **'Need attention'**
  String get needAttention;

  /// No description provided for @messageSecurity.
  ///
  /// In en, this message translates to:
  /// **'Message Security'**
  String get messageSecurity;

  /// No description provided for @recentActivitySecure.
  ///
  /// In en, this message translates to:
  /// **'Your recent activity looks secure'**
  String get recentActivitySecure;

  /// No description provided for @messagesNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'Some messages need attention'**
  String get messagesNeedAttention;

  /// No description provided for @aiPoweredMessageSecurity.
  ///
  /// In en, this message translates to:
  /// **'AI-powered message security'**
  String get aiPoweredMessageSecurity;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToProtectMessages.
  ///
  /// In en, this message translates to:
  /// **'Sign in to protect and analyze your messages.'**
  String get signInToProtectMessages;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @secureLogin.
  ///
  /// In en, this message translates to:
  /// **'Secure Login'**
  String get secureLogin;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @secureAiProtection.
  ///
  /// In en, this message translates to:
  /// **'Secure AI-powered protection'**
  String get secureAiProtection;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerified;

  /// No description provided for @successfullySignedInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in with Google.'**
  String get successfullySignedInWithGoogle;

  /// No description provided for @googleAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'No MessageShield account was found for this Google account. Please create an account first.'**
  String get googleAccountNotFound;

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get googleSignInCancelled;

  /// No description provided for @googlePopupBlocked.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in popup was blocked. Please allow popups and try again.'**
  String get googlePopupBlocked;

  /// No description provided for @googleSignInNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not enabled.'**
  String get googleSignInNotEnabled;

  /// No description provided for @googleSignInNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured correctly.'**
  String get googleSignInNotConfigured;

  /// No description provided for @pleaseVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address before signing in. Check your inbox for the verification email.'**
  String get pleaseVerifyEmail;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidEmailOrPassword;

  /// No description provided for @unableToConnectServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Please check your internet connection and try again.'**
  String get unableToConnectServer;

  /// No description provided for @requestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get requestTimedOut;

  /// No description provided for @unableToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in. Please try again.'**
  String get unableToSignIn;

  /// No description provided for @unableToSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in with Google. Please try again.'**
  String get unableToSignInWithGoogle;

  /// No description provided for @accountInactive.
  ///
  /// In en, this message translates to:
  /// **'Your account is currently inactive.'**
  String get accountInactive;

  /// No description provided for @registerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please register first.'**
  String get registerFirst;

  /// No description provided for @stayProtected.
  ///
  /// In en, this message translates to:
  /// **'Stay Protected.'**
  String get stayProtected;

  /// No description provided for @checkSuspiciousMessages.
  ///
  /// In en, this message translates to:
  /// **'Check suspicious messages safely before you act.'**
  String get checkSuspiciousMessages;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'ANALYZING...'**
  String get analyzing;

  /// No description provided for @analyzeMessage.
  ///
  /// In en, this message translates to:
  /// **'ANALYZE MESSAGE'**
  String get analyzeMessage;

  /// No description provided for @clearMessage.
  ///
  /// In en, this message translates to:
  /// **'Clear message'**
  String get clearMessage;

  /// No description provided for @safetyGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Safety guidelines'**
  String get safetyGuidelines;

  /// No description provided for @otpAndPasswords.
  ///
  /// In en, this message translates to:
  /// **'OTP and passwords'**
  String get otpAndPasswords;

  /// No description provided for @neverShareSensitiveCodes.
  ///
  /// In en, this message translates to:
  /// **'Never share OTPs, passwords, PINs or CVV values.'**
  String get neverShareSensitiveCodes;

  /// No description provided for @suspiciousLinks.
  ///
  /// In en, this message translates to:
  /// **'Suspicious links'**
  String get suspiciousLinks;

  /// No description provided for @avoidUnknownLinks.
  ///
  /// In en, this message translates to:
  /// **'Avoid unknown links and verify organisations through official channels.'**
  String get avoidUnknownLinks;

  /// No description provided for @paymentScams.
  ///
  /// In en, this message translates to:
  /// **'Payment scams'**
  String get paymentScams;

  /// No description provided for @verifyPaymentRequests.
  ///
  /// In en, this message translates to:
  /// **'Verify payment requests before sending money.'**
  String get verifyPaymentRequests;

  /// No description provided for @verifyTheSender.
  ///
  /// In en, this message translates to:
  /// **'Verify the sender'**
  String get verifyTheSender;

  /// No description provided for @familiarNameNotGuarantee.
  ///
  /// In en, this message translates to:
  /// **'A familiar name does not guarantee that a message is genuine.'**
  String get familiarNameNotGuarantee;

  /// No description provided for @mediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get mediumRisk;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get confidence;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @risk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get risk;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get riskHigh;

  /// No description provided for @riskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get riskMedium;

  /// No description provided for @riskLow.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get riskLow;

  /// No description provided for @messageType.
  ///
  /// In en, this message translates to:
  /// **'Message Type'**
  String get messageType;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @whyWeFlaggedThis.
  ///
  /// In en, this message translates to:
  /// **'Why We Flagged This'**
  String get whyWeFlaggedThis;

  /// No description provided for @safetyCheck.
  ///
  /// In en, this message translates to:
  /// **'Safety Check'**
  String get safetyCheck;

  /// No description provided for @whatYouShouldDo.
  ///
  /// In en, this message translates to:
  /// **'What You Should Do'**
  String get whatYouShouldDo;

  /// No description provided for @analysisConfidence.
  ///
  /// In en, this message translates to:
  /// **'Analysis confidence'**
  String get analysisConfidence;

  /// No description provided for @adminAnalysisDetails.
  ///
  /// In en, this message translates to:
  /// **'Admin Analysis Details'**
  String get adminAnalysisDetails;

  /// No description provided for @riskScore.
  ///
  /// In en, this message translates to:
  /// **'Risk score'**
  String get riskScore;

  /// No description provided for @categoryConfidence.
  ///
  /// In en, this message translates to:
  /// **'Category confidence'**
  String get categoryConfidence;

  /// No description provided for @categoryModel.
  ///
  /// In en, this message translates to:
  /// **'Category model'**
  String get categoryModel;

  /// No description provided for @safetyLabel.
  ///
  /// In en, this message translates to:
  /// **'Safety label'**
  String get safetyLabel;

  /// No description provided for @safetyConfidence.
  ///
  /// In en, this message translates to:
  /// **'Safety confidence'**
  String get safetyConfidence;

  /// No description provided for @safetyModel.
  ///
  /// In en, this message translates to:
  /// **'Safety model'**
  String get safetyModel;

  /// No description provided for @categoryProbabilities.
  ///
  /// In en, this message translates to:
  /// **'Category Probabilities'**
  String get categoryProbabilities;

  /// No description provided for @safetyProbabilities.
  ///
  /// In en, this message translates to:
  /// **'Safety Probabilities'**
  String get safetyProbabilities;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @securityAnalysisCompleted.
  ///
  /// In en, this message translates to:
  /// **'Security analysis completed.'**
  String get securityAnalysisCompleted;

  /// No description provided for @highRiskAlert.
  ///
  /// In en, this message translates to:
  /// **'This message may be unsafe. Do not click links or share OTPs, passwords, PINs, CVV, or banking details.'**
  String get highRiskAlert;

  /// No description provided for @mediumRiskAlert.
  ///
  /// In en, this message translates to:
  /// **'This message contains some indicators that need verification. Confirm the sender through an official channel before acting.'**
  String get mediumRiskAlert;

  /// No description provided for @lowRiskAlert.
  ///
  /// In en, this message translates to:
  /// **'No major risk indicators were detected. Still verify unexpected requests before sharing personal information or making payments.'**
  String get lowRiskAlert;

  /// No description provided for @doNotClickSuspiciousLinks.
  ///
  /// In en, this message translates to:
  /// **'Do not click suspicious links.'**
  String get doNotClickSuspiciousLinks;

  /// No description provided for @doNotShareSensitiveCodes.
  ///
  /// In en, this message translates to:
  /// **'Do not share OTPs, passwords, PINs or CVV.'**
  String get doNotShareSensitiveCodes;

  /// No description provided for @verifyOrganisationOfficial.
  ///
  /// In en, this message translates to:
  /// **'Verify the organisation using an official website or number.'**
  String get verifyOrganisationOfficial;

  /// No description provided for @verifySenderIndependently.
  ///
  /// In en, this message translates to:
  /// **'Verify the sender independently.'**
  String get verifySenderIndependently;

  /// No description provided for @avoidMessageLinks.
  ///
  /// In en, this message translates to:
  /// **'Avoid using links from the message until verified.'**
  String get avoidMessageLinks;

  /// No description provided for @doNotShareSensitiveInformation.
  ///
  /// In en, this message translates to:
  /// **'Do not share sensitive information.'**
  String get doNotShareSensitiveInformation;

  /// No description provided for @stayCautiousUnexpectedRequests.
  ///
  /// In en, this message translates to:
  /// **'Stay cautious with unexpected requests.'**
  String get stayCautiousUnexpectedRequests;

  /// No description provided for @verifyPaymentAccountRequests.
  ///
  /// In en, this message translates to:
  /// **'Verify payment or account requests independently.'**
  String get verifyPaymentAccountRequests;

  /// No description provided for @analysisDetails.
  ///
  /// In en, this message translates to:
  /// **'Analysis Details'**
  String get analysisDetails;

  /// No description provided for @riskDescriptionHigh.
  ///
  /// In en, this message translates to:
  /// **'This message contains strong indicators of potential risk.'**
  String get riskDescriptionHigh;

  /// No description provided for @riskDescriptionMedium.
  ///
  /// In en, this message translates to:
  /// **'This message contains some suspicious indicators. Review carefully.'**
  String get riskDescriptionMedium;

  /// No description provided for @riskDescriptionLow.
  ///
  /// In en, this message translates to:
  /// **'No major threat indicators were detected in this message.'**
  String get riskDescriptionLow;

  /// No description provided for @riskInformationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Risk information is unavailable.'**
  String get riskInformationUnavailable;

  /// No description provided for @riskScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk Score'**
  String get riskScoreLabel;

  /// No description provided for @informationAboutAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Information about this analysis'**
  String get informationAboutAnalysis;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @yourRecentMessageSafetyChecks.
  ///
  /// In en, this message translates to:
  /// **'Your recent message safety checks'**
  String get yourRecentMessageSafetyChecks;

  /// No description provided for @messageAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Message analysis'**
  String get messageAnalysis;

  /// No description provided for @loadingAnalysisHistory.
  ///
  /// In en, this message translates to:
  /// **'Loading your analysis history...'**
  String get loadingAnalysisHistory;

  /// No description provided for @noAnalysesYet.
  ///
  /// In en, this message translates to:
  /// **'No analyses yet'**
  String get noAnalysesYet;

  /// No description provided for @analyzedMessagesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your analyzed messages will appear here so you can review their safety results anytime.'**
  String get analyzedMessagesAppearHere;

  /// No description provided for @unableToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Unable to load history'**
  String get unableToLoadHistory;

  /// No description provided for @totalAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Total Analyses'**
  String get totalAnalyses;

  /// No description provided for @messagesCheckedForThreats.
  ///
  /// In en, this message translates to:
  /// **'Messages checked for threats'**
  String get messagesCheckedForThreats;

  /// No description provided for @analyzeMessageToStart.
  ///
  /// In en, this message translates to:
  /// **'Analyze a message to start building your security activity.'**
  String get analyzeMessageToStart;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @pleaseVerifyEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email first.'**
  String get pleaseVerifyEmailFirst;

  /// No description provided for @iveVerifiedMyEmail.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get iveVerifiedMyEmail;

  /// No description provided for @accountWithEmailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please sign in instead.'**
  String get accountWithEmailAlreadyExists;

  /// No description provided for @unableToCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to create your account. Please try again.'**
  String get unableToCreateAccount;

  /// No description provided for @accountExistsLoginInstead.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email. Please log in instead.'**
  String get accountExistsLoginInstead;

  /// No description provided for @emailPasswordProviderConflict.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered with email and password. Please log in with your password.'**
  String get emailPasswordProviderConflict;

  /// No description provided for @firebaseAuthVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Firebase authentication verification failed.'**
  String get firebaseAuthVerificationFailed;

  /// No description provided for @unsupportedPlatform.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not supported on this platform.'**
  String get unsupportedPlatform;

  /// No description provided for @unableToContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Unable to continue with Google. Please try again.'**
  String get unableToContinueWithGoogle;

  /// No description provided for @unableToScanMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to scan the message.'**
  String get unableToScanMessage;

  /// No description provided for @noReadableTextFound.
  ///
  /// In en, this message translates to:
  /// **'No readable text was found in the image.'**
  String get noReadableTextFound;

  /// No description provided for @pasteOrScanMessageFirst.
  ///
  /// In en, this message translates to:
  /// **'Paste or scan a message first.'**
  String get pasteOrScanMessageFirst;

  /// No description provided for @captureMessageDescription.
  ///
  /// In en, this message translates to:
  /// **'Capture a message with your camera or select a screenshot/image.'**
  String get captureMessageDescription;

  /// No description provided for @scanWithCamera.
  ///
  /// In en, this message translates to:
  /// **'SCAN WITH CAMERA'**
  String get scanWithCamera;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE IMAGE'**
  String get chooseImage;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordSetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password set successfully. You can now sign in with Google or email and password.'**
  String get passwordSetSuccessfully;

  /// No description provided for @logoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logoutQuestion;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from MessageShield?'**
  String get logoutConfirmation;

  /// No description provided for @activeAccount.
  ///
  /// In en, this message translates to:
  /// **'Active Account'**
  String get activeAccount;

  /// No description provided for @inactiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Inactive Account'**
  String get inactiveAccount;

  /// No description provided for @smartPrivateProtected.
  ///
  /// In en, this message translates to:
  /// **'Smart. Private. Protected.'**
  String get smartPrivateProtected;

  /// No description provided for @noSuspiciousSignalsDetected.
  ///
  /// In en, this message translates to:
  /// **'No suspicious signals detected.'**
  String get noSuspiciousSignalsDetected;

  /// No description provided for @aiSafetyAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Safety Analysis'**
  String get aiSafetyAnalysis;

  /// No description provided for @emailPasswordAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists using email and password. Please sign in using your email and password.'**
  String get emailPasswordAccountExists;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'mr': return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
