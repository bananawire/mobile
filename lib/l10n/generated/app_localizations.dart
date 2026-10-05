import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get common_create;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get common_none;

  /// No description provided for @common_select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get common_select;

  /// No description provided for @common_email.
  ///
  /// In en, this message translates to:
  /// **'Email*'**
  String get common_email;

  /// No description provided for @common_password.
  ///
  /// In en, this message translates to:
  /// **'Password*'**
  String get common_password;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login to Clair'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials'**
  String get login_subtitle;

  /// No description provided for @login_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get login_email_required;

  /// No description provided for @login_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get login_password_required;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_button;

  /// No description provided for @login_or_with.
  ///
  /// In en, this message translates to:
  /// **'OR LOGIN WITH'**
  String get login_or_with;

  /// No description provided for @login_google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get login_google;

  /// No description provided for @login_no_account.
  ///
  /// In en, this message translates to:
  /// **'Do not have an account? '**
  String get login_no_account;

  /// No description provided for @login_register_link.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get login_register_link;

  /// No description provided for @register_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register_title;

  /// No description provided for @register_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get register_subtitle;

  /// No description provided for @register_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get register_email_required;

  /// No description provided for @register_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get register_password_required;

  /// No description provided for @register_password_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get register_password_length;

  /// No description provided for @register_button.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register_button;

  /// No description provided for @register_or_with.
  ///
  /// In en, this message translates to:
  /// **'OR REGISTER WITH'**
  String get register_or_with;

  /// No description provided for @register_google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get register_google;

  /// No description provided for @register_already_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get register_already_account;

  /// No description provided for @register_login_link.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get register_login_link;

  /// No description provided for @verify_title.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verify_title;

  /// No description provided for @verify_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your email'**
  String get verify_subtitle;

  /// No description provided for @verify_code_label.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verify_code_label;

  /// No description provided for @verify_code_hint.
  ///
  /// In en, this message translates to:
  /// **'ABCD-1234'**
  String get verify_code_hint;

  /// No description provided for @verify_code_required.
  ///
  /// In en, this message translates to:
  /// **'Verification code is required'**
  String get verify_code_required;

  /// No description provided for @verify_button.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify_button;

  /// No description provided for @verify_back_login.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get verify_back_login;

  /// No description provided for @verify_success_message.
  ///
  /// In en, this message translates to:
  /// **'Registration confirmed! Please sign in.'**
  String get verify_success_message;

  /// No description provided for @nav_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get nav_analytics;

  /// No description provided for @nav_alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get nav_alerts;

  /// No description provided for @nav_spaces.
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get nav_spaces;

  /// No description provided for @analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Air Quality'**
  String get analytics_title;

  /// No description provided for @analytics_live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get analytics_live;

  /// No description provided for @analytics_live_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Live data is not available right now.'**
  String get analytics_live_unavailable;

  /// No description provided for @analytics_no_measurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements available'**
  String get analytics_no_measurements;

  /// No description provided for @analytics_no_data_detail.
  ///
  /// In en, this message translates to:
  /// **'This device has no telemetry or historical data for the selected period.'**
  String get analytics_no_data_detail;

  /// No description provided for @analytics_no_measurements_short.
  ///
  /// In en, this message translates to:
  /// **'No measurements'**
  String get analytics_no_measurements_short;

  /// No description provided for @analytics_updated_label.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get analytics_updated_label;

  /// No description provided for @analytics_dropdown_org.
  ///
  /// In en, this message translates to:
  /// **'ORGANIZATION'**
  String get analytics_dropdown_org;

  /// No description provided for @analytics_dropdown_space.
  ///
  /// In en, this message translates to:
  /// **'SPACE'**
  String get analytics_dropdown_space;

  /// No description provided for @analytics_dropdown_device.
  ///
  /// In en, this message translates to:
  /// **'DEVICE'**
  String get analytics_dropdown_device;

  /// No description provided for @analytics_metric_pm25.
  ///
  /// In en, this message translates to:
  /// **'PM2.5'**
  String get analytics_metric_pm25;

  /// No description provided for @analytics_metric_co2.
  ///
  /// In en, this message translates to:
  /// **'CO₂'**
  String get analytics_metric_co2;

  /// No description provided for @analytics_metric_temp.
  ///
  /// In en, this message translates to:
  /// **'TEMP'**
  String get analytics_metric_temp;

  /// No description provided for @analytics_metric_humidity.
  ///
  /// In en, this message translates to:
  /// **'HUMIDITY'**
  String get analytics_metric_humidity;

  /// No description provided for @analytics_metric_aqi.
  ///
  /// In en, this message translates to:
  /// **'AQI'**
  String get analytics_metric_aqi;

  /// No description provided for @time_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get time_just_now;

  /// No description provided for @time_seconds_ago.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds ago'**
  String time_seconds_ago(int seconds);

  /// No description provided for @time_minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String time_minutes_ago(int minutes);

  /// No description provided for @time_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String time_hours_ago(int hours);

  /// No description provided for @time_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String time_days_ago(int days);

  /// No description provided for @time_updated_just_now.
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get time_updated_just_now;

  /// No description provided for @alerts_title.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts_title;

  /// No description provided for @alerts_tab_active.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get alerts_tab_active;

  /// No description provided for @alerts_tab_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get alerts_tab_history;

  /// No description provided for @alerts_btn_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get alerts_btn_previous;

  /// No description provided for @alerts_btn_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get alerts_btn_next;

  /// No description provided for @alerts_page_info.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String alerts_page_info(int current, int total);

  /// No description provided for @org_title.
  ///
  /// In en, this message translates to:
  /// **'Organizations'**
  String get org_title;

  /// No description provided for @org_empty.
  ///
  /// In en, this message translates to:
  /// **'No organizations yet'**
  String get org_empty;

  /// No description provided for @org_btn_add.
  ///
  /// In en, this message translates to:
  /// **'Add Organization'**
  String get org_btn_add;

  /// No description provided for @org_form_create_title.
  ///
  /// In en, this message translates to:
  /// **'Create organization'**
  String get org_form_create_title;

  /// No description provided for @org_form_name_label.
  ///
  /// In en, this message translates to:
  /// **'Organization name'**
  String get org_form_name_label;

  /// No description provided for @org_form_name_required.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get org_form_name_required;

  /// No description provided for @org_form_name_short.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get org_form_name_short;

  /// No description provided for @org_form_name_long.
  ///
  /// In en, this message translates to:
  /// **'Name is too long'**
  String get org_form_name_long;

  /// No description provided for @org_form_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit organization'**
  String get org_form_edit_title;

  /// No description provided for @org_dialog_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete organization?'**
  String get org_dialog_delete_title;

  /// No description provided for @org_dialog_delete_content.
  ///
  /// In en, this message translates to:
  /// **'This will delete \"{name}\".'**
  String org_dialog_delete_content(String name);

  /// No description provided for @spaces_title.
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get spaces_title;

  /// No description provided for @spaces_empty.
  ///
  /// In en, this message translates to:
  /// **'No spaces yet'**
  String get spaces_empty;

  /// No description provided for @spaces_btn_create.
  ///
  /// In en, this message translates to:
  /// **'Create space'**
  String get spaces_btn_create;

  /// No description provided for @spaces_form_name_label.
  ///
  /// In en, this message translates to:
  /// **'Space name'**
  String get spaces_form_name_label;

  /// No description provided for @spaces_form_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit space'**
  String get spaces_form_edit_title;

  /// No description provided for @spaces_dialog_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete space?'**
  String get spaces_dialog_delete_title;

  /// No description provided for @spaces_dialog_delete_content.
  ///
  /// In en, this message translates to:
  /// **'This will delete \"{name}\".'**
  String spaces_dialog_delete_content(String name);

  /// No description provided for @devices_title.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get devices_title;

  /// No description provided for @devices_empty.
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get devices_empty;

  /// No description provided for @devices_btn_add.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get devices_btn_add;

  /// No description provided for @devices_form_claim_title.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get devices_form_claim_title;

  /// No description provided for @devices_form_claim_token.
  ///
  /// In en, this message translates to:
  /// **'Claim token'**
  String get devices_form_claim_token;

  /// No description provided for @devices_form_claim_token_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the one-time token'**
  String get devices_form_claim_token_hint;

  /// No description provided for @devices_form_claim_token_required.
  ///
  /// In en, this message translates to:
  /// **'Claim token is required'**
  String get devices_form_claim_token_required;

  /// No description provided for @devices_form_pair_title.
  ///
  /// In en, this message translates to:
  /// **'Pair device'**
  String get devices_form_pair_title;

  /// No description provided for @devices_form_pair_hardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware ID'**
  String get devices_form_pair_hardware;

  /// No description provided for @devices_form_pair_hardware_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. CLAIR-AB12'**
  String get devices_form_pair_hardware_hint;

  /// No description provided for @devices_form_pair_hardware_required.
  ///
  /// In en, this message translates to:
  /// **'Hardware ID is required'**
  String get devices_form_pair_hardware_required;

  /// No description provided for @devices_form_pair_button.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get devices_form_pair_button;

  /// No description provided for @devices_dialog_pairing_title.
  ///
  /// In en, this message translates to:
  /// **'Pairing started'**
  String get devices_dialog_pairing_title;

  /// No description provided for @devices_dialog_pairing_no_token.
  ///
  /// In en, this message translates to:
  /// **'No claim token returned.'**
  String get devices_dialog_pairing_no_token;

  /// No description provided for @devices_dialog_pairing_token.
  ///
  /// In en, this message translates to:
  /// **'Claim token: {token}'**
  String devices_dialog_pairing_token(String token);

  /// No description provided for @devices_not_found.
  ///
  /// In en, this message translates to:
  /// **'Device not found'**
  String get devices_not_found;

  /// No description provided for @devices_dialog_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete device'**
  String get devices_dialog_delete_title;

  /// No description provided for @devices_dialog_delete_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action will reset the device assignment.'**
  String devices_dialog_delete_content(String name);

  /// No description provided for @devices_thresholds.
  ///
  /// In en, this message translates to:
  /// **'Thresholds'**
  String get devices_thresholds;

  /// No description provided for @devices_thresholds_health.
  ///
  /// In en, this message translates to:
  /// **'May affect device health'**
  String get devices_thresholds_health;

  /// No description provided for @devices_thresholds_saved.
  ///
  /// In en, this message translates to:
  /// **'Thresholds saved successfully.'**
  String get devices_thresholds_saved;

  /// No description provided for @devices_thresholds_reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get devices_thresholds_reset;

  /// No description provided for @devices_thresholds_save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get devices_thresholds_save;

  /// No description provided for @devices_thresholds_max.
  ///
  /// In en, this message translates to:
  /// **'max'**
  String get devices_thresholds_max;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settings_logout;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settings_select_language;

  /// No description provided for @settings_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_english;

  /// No description provided for @settings_spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settings_spanish;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifications_empty_title;

  /// No description provided for @notifications_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We will let you know when something important happens.'**
  String get notifications_empty_subtitle;

  /// No description provided for @analytics_device_offline_message.
  ///
  /// In en, this message translates to:
  /// **'Device with ID \"{deviceName}\" has no recent live telemetry data; it might be turned off or disconnected.'**
  String analytics_device_offline_message(String deviceName);

  /// No description provided for @alerts_last_30_days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get alerts_last_30_days;

  /// No description provided for @alerts_col_device.
  ///
  /// In en, this message translates to:
  /// **'DEVICE'**
  String get alerts_col_device;

  /// No description provided for @alerts_col_severity.
  ///
  /// In en, this message translates to:
  /// **'SEVERITY'**
  String get alerts_col_severity;

  /// No description provided for @alerts_col_space.
  ///
  /// In en, this message translates to:
  /// **'SPACE'**
  String get alerts_col_space;

  /// No description provided for @alerts_col_variable.
  ///
  /// In en, this message translates to:
  /// **'VARIABLE'**
  String get alerts_col_variable;

  /// No description provided for @alerts_col_time.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get alerts_col_time;

  /// No description provided for @alerts_col_status.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get alerts_col_status;

  /// No description provided for @alerts_no_alerts_found.
  ///
  /// In en, this message translates to:
  /// **'No alerts found'**
  String get alerts_no_alerts_found;

  /// No description provided for @alerts_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading alerts...'**
  String get alerts_loading;

  /// No description provided for @spaces_card_devices.
  ///
  /// In en, this message translates to:
  /// **'{count} DEVICES'**
  String spaces_card_devices(String count);

  /// No description provided for @common_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get common_open;

  /// No description provided for @time_updated_recently.
  ///
  /// In en, this message translates to:
  /// **'Updated recently'**
  String get time_updated_recently;

  /// No description provided for @time_updated_seconds_ago.
  ///
  /// In en, this message translates to:
  /// **'Updated {seconds}s ago'**
  String time_updated_seconds_ago(int seconds);

  /// No description provided for @time_updated_minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'Updated {minutes}m ago'**
  String time_updated_minutes_ago(int minutes);

  /// No description provided for @time_updated_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'Updated {hours}h ago'**
  String time_updated_hours_ago(int hours);

  /// No description provided for @time_updated_days_ago.
  ///
  /// In en, this message translates to:
  /// **'Updated {days}d ago'**
  String time_updated_days_ago(int days);

  /// No description provided for @devices_vitals_connectivity.
  ///
  /// In en, this message translates to:
  /// **'CONNECTIVITY'**
  String get devices_vitals_connectivity;

  /// No description provided for @devices_vitals_uptime.
  ///
  /// In en, this message translates to:
  /// **'UPTIME'**
  String get devices_vitals_uptime;

  /// No description provided for @devices_vitals_uptime_unit.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get devices_vitals_uptime_unit;

  /// No description provided for @devices_vitals_health.
  ///
  /// In en, this message translates to:
  /// **'DEVICE HEALTH'**
  String get devices_vitals_health;

  /// No description provided for @devices_vitals_last_update.
  ///
  /// In en, this message translates to:
  /// **'LAST UPDATE'**
  String get devices_vitals_last_update;

  /// No description provided for @devices_vitals_last_update_unit.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get devices_vitals_last_update_unit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
