// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_create => 'Create';

  @override
  String get common_add => 'Add';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_close => 'Close';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_none => 'None';

  @override
  String get common_select => 'Select';

  @override
  String get common_email => 'Email*';

  @override
  String get common_password => 'Password*';

  @override
  String get login_title => 'Login to Clair';

  @override
  String get login_subtitle => 'Enter your credentials';

  @override
  String get login_email_required => 'Email is required';

  @override
  String get login_password_required => 'Password is required';

  @override
  String get login_button => 'Login';

  @override
  String get login_or_with => 'OR LOGIN WITH';

  @override
  String get login_google => 'Google';

  @override
  String get login_no_account => 'Do not have an account? ';

  @override
  String get login_register_link => 'Register';

  @override
  String get register_title => 'Create Account';

  @override
  String get register_subtitle => 'Sign up to get started';

  @override
  String get register_email_required => 'Email is required';

  @override
  String get register_password_required => 'Password is required';

  @override
  String get register_password_length =>
      'Password must be at least 8 characters';

  @override
  String get register_button => 'Sign Up';

  @override
  String get register_or_with => 'OR REGISTER WITH';

  @override
  String get register_google => 'Google';

  @override
  String get register_already_account => 'Already have an account? ';

  @override
  String get register_login_link => 'Login';

  @override
  String get verify_title => 'Verify Account';

  @override
  String get verify_subtitle =>
      'Enter the verification code sent to your email';

  @override
  String get verify_code_label => 'Verification Code';

  @override
  String get verify_code_hint => 'ABCD-1234';

  @override
  String get verify_code_required => 'Verification code is required';

  @override
  String get verify_button => 'Verify';

  @override
  String get verify_back_login => 'Back to Login';

  @override
  String get verify_success_message =>
      'Registration confirmed! Please sign in.';

  @override
  String get nav_analytics => 'Analytics';

  @override
  String get nav_alerts => 'Alerts';

  @override
  String get nav_spaces => 'Spaces';

  @override
  String get analytics_title => 'Air Quality';

  @override
  String get analytics_live => 'LIVE';

  @override
  String get analytics_live_unavailable =>
      'Live data is not available right now.';

  @override
  String get analytics_no_measurements => 'No measurements available';

  @override
  String get analytics_no_data_detail =>
      'This device has no telemetry or historical data for the selected period.';

  @override
  String get analytics_no_measurements_short => 'No measurements';

  @override
  String get analytics_updated_label => 'Updated';

  @override
  String get analytics_dropdown_org => 'ORGANIZATION';

  @override
  String get analytics_dropdown_space => 'SPACE';

  @override
  String get analytics_dropdown_device => 'DEVICE';

  @override
  String get analytics_metric_pm25 => 'PM2.5';

  @override
  String get analytics_metric_co2 => 'CO₂';

  @override
  String get analytics_metric_temp => 'TEMP';

  @override
  String get analytics_metric_humidity => 'HUMIDITY';

  @override
  String get analytics_metric_aqi => 'AQI';

  @override
  String get time_just_now => 'Just now';

  @override
  String time_seconds_ago(int seconds) {
    return '$seconds seconds ago';
  }

  @override
  String time_minutes_ago(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String time_hours_ago(int hours) {
    return '${hours}h ago';
  }

  @override
  String time_days_ago(int days) {
    return '${days}d ago';
  }

  @override
  String get time_updated_just_now => 'Updated just now';

  @override
  String get alerts_title => 'Alerts';

  @override
  String get alerts_tab_active => 'Active Alerts';

  @override
  String get alerts_tab_history => 'History';

  @override
  String get alerts_btn_previous => 'Previous';

  @override
  String get alerts_btn_next => 'Next';

  @override
  String alerts_page_info(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get org_title => 'Organizations';

  @override
  String get org_empty => 'No organizations yet';

  @override
  String get org_btn_add => 'Add Organization';

  @override
  String get org_form_create_title => 'Create organization';

  @override
  String get org_form_name_label => 'Organization name';

  @override
  String get org_form_name_required => 'Name is required';

  @override
  String get org_form_name_short => 'Name is too short';

  @override
  String get org_form_name_long => 'Name is too long';

  @override
  String get org_form_edit_title => 'Edit organization';

  @override
  String get org_dialog_delete_title => 'Delete organization?';

  @override
  String org_dialog_delete_content(String name) {
    return 'This will delete \"$name\".';
  }

  @override
  String get spaces_title => 'Spaces';

  @override
  String get spaces_empty => 'No spaces yet';

  @override
  String get spaces_btn_create => 'Create space';

  @override
  String get spaces_form_name_label => 'Space name';

  @override
  String get spaces_form_edit_title => 'Edit space';

  @override
  String get spaces_dialog_delete_title => 'Delete space?';

  @override
  String spaces_dialog_delete_content(String name) {
    return 'This will delete \"$name\".';
  }

  @override
  String get devices_title => 'Space';

  @override
  String get devices_empty => 'No devices yet';

  @override
  String get devices_btn_add => 'Add device';

  @override
  String get devices_form_claim_title => 'Add device';

  @override
  String get devices_form_claim_token => 'Claim token';

  @override
  String get devices_form_claim_token_hint => 'Enter the one-time token';

  @override
  String get devices_form_claim_token_required => 'Claim token is required';

  @override
  String get devices_form_pair_title => 'Pair device';

  @override
  String get devices_form_pair_hardware => 'Hardware ID';

  @override
  String get devices_form_pair_hardware_hint => 'e.g. CLAIR-AB12';

  @override
  String get devices_form_pair_hardware_required => 'Hardware ID is required';

  @override
  String get devices_form_pair_button => 'Pair';

  @override
  String get devices_dialog_pairing_title => 'Pairing started';

  @override
  String get devices_dialog_pairing_no_token => 'No claim token returned.';

  @override
  String devices_dialog_pairing_token(String token) {
    return 'Claim token: $token';
  }

  @override
  String get devices_not_found => 'Device not found';

  @override
  String get devices_dialog_delete_title => 'Delete device';

  @override
  String devices_dialog_delete_content(String name) {
    return 'Are you sure you want to delete \"$name\"? This action will reset the device assignment.';
  }

  @override
  String get devices_thresholds => 'Thresholds';

  @override
  String get devices_thresholds_health => 'May affect device health';

  @override
  String get devices_thresholds_saved => 'Thresholds saved successfully.';

  @override
  String get devices_thresholds_reset => 'RESET';

  @override
  String get devices_thresholds_save => 'SAVE';

  @override
  String get devices_thresholds_max => 'max';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_logout => 'Logout';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_select_language => 'Select Language';

  @override
  String get settings_english => 'English';

  @override
  String get settings_spanish => 'Spanish';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_empty_title => 'No notifications yet';

  @override
  String get notifications_empty_subtitle =>
      'We will let you know when something important happens.';

  @override
  String analytics_device_offline_message(String deviceName) {
    return 'Device with ID \"$deviceName\" has no recent live telemetry data; it might be turned off or disconnected.';
  }

  @override
  String get alerts_last_30_days => 'Last 30 days';

  @override
  String get alerts_col_device => 'DEVICE';

  @override
  String get alerts_col_severity => 'SEVERITY';

  @override
  String get alerts_col_space => 'SPACE';

  @override
  String get alerts_col_variable => 'VARIABLE';

  @override
  String get alerts_col_time => 'TIME';

  @override
  String get alerts_col_status => 'STATUS';

  @override
  String get alerts_no_alerts_found => 'No alerts found';

  @override
  String get alerts_loading => 'Loading alerts...';

  @override
  String spaces_card_devices(String count) {
    return '$count DEVICES';
  }

  @override
  String get common_open => 'Open';

  @override
  String get time_updated_recently => 'Updated recently';

  @override
  String time_updated_seconds_ago(int seconds) {
    return 'Updated ${seconds}s ago';
  }

  @override
  String time_updated_minutes_ago(int minutes) {
    return 'Updated ${minutes}m ago';
  }

  @override
  String time_updated_hours_ago(int hours) {
    return 'Updated ${hours}h ago';
  }

  @override
  String time_updated_days_ago(int days) {
    return 'Updated ${days}d ago';
  }

  @override
  String get devices_vitals_connectivity => 'CONNECTIVITY';

  @override
  String get devices_vitals_uptime => 'UPTIME';

  @override
  String get devices_vitals_uptime_unit => 'hours';

  @override
  String get devices_vitals_health => 'DEVICE HEALTH';

  @override
  String get devices_vitals_last_update => 'LAST UPDATE';

  @override
  String get devices_vitals_last_update_unit => 'h';
}
