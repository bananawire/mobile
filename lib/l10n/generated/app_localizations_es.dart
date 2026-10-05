// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_create => 'Crear';

  @override
  String get common_add => 'Agregar';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_none => 'Ninguno';

  @override
  String get common_select => 'Seleccionar';

  @override
  String get common_email => 'Correo electrónico*';

  @override
  String get common_password => 'Contraseña*';

  @override
  String get login_title => 'Iniciar sesión en Clair';

  @override
  String get login_subtitle => 'Ingrese sus credenciales';

  @override
  String get login_email_required => 'El correo electrónico es requerido';

  @override
  String get login_password_required => 'La contraseña es requerida';

  @override
  String get login_button => 'Iniciar sesión';

  @override
  String get login_or_with => 'O INICIAR SESIÓN CON';

  @override
  String get login_google => 'Google';

  @override
  String get login_no_account => '¿No tiene una cuenta? ';

  @override
  String get login_register_link => 'Registrarse';

  @override
  String get register_title => 'Crear cuenta';

  @override
  String get register_subtitle => 'Regístrese para comenzar';

  @override
  String get register_email_required => 'El correo electrónico es requerido';

  @override
  String get register_password_required => 'La contraseña es requerida';

  @override
  String get register_password_length =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get register_button => 'Registrarse';

  @override
  String get register_or_with => 'O REGISTRARSE CON';

  @override
  String get register_google => 'Google';

  @override
  String get register_already_account => '¿Ya tiene una cuenta? ';

  @override
  String get register_login_link => 'Iniciar sesión';

  @override
  String get verify_title => 'Verificar cuenta';

  @override
  String get verify_subtitle =>
      'Ingrese el código de verificación enviado a su correo';

  @override
  String get verify_code_label => 'Código de verificación';

  @override
  String get verify_code_hint => 'ABCD-1234';

  @override
  String get verify_code_required => 'El código de verificación es requerido';

  @override
  String get verify_button => 'Verificar';

  @override
  String get verify_back_login => 'Volver al inicio de sesión';

  @override
  String get verify_success_message =>
      '¡Registro confirmado! Por favor inicie sesión.';

  @override
  String get nav_analytics => 'Análisis';

  @override
  String get nav_alerts => 'Alertas';

  @override
  String get nav_spaces => 'Espacios';

  @override
  String get analytics_title => 'Calidad del aire';

  @override
  String get analytics_live => 'EN VIVO';

  @override
  String get analytics_live_unavailable =>
      'Los datos en vivo no están disponibles en este momento.';

  @override
  String get analytics_no_measurements => 'No hay mediciones disponibles';

  @override
  String get analytics_no_data_detail =>
      'Este dispositivo no tiene telemetría o datos históricos para el período seleccionado.';

  @override
  String get analytics_no_measurements_short => 'Sin mediciones';

  @override
  String get analytics_updated_label => 'Actualizado';

  @override
  String get analytics_dropdown_org => 'ORGANIZACIÓN';

  @override
  String get analytics_dropdown_space => 'ESPACIO';

  @override
  String get analytics_dropdown_device => 'DISPOSITIVO';

  @override
  String get analytics_metric_pm25 => 'PM2.5';

  @override
  String get analytics_metric_co2 => 'CO₂';

  @override
  String get analytics_metric_temp => 'TEMP';

  @override
  String get analytics_metric_humidity => 'HUMEDAD';

  @override
  String get analytics_metric_aqi => 'AQI';

  @override
  String get time_just_now => 'Hace un momento';

  @override
  String time_seconds_ago(int seconds) {
    return 'Hace ${seconds}s';
  }

  @override
  String time_minutes_ago(int minutes) {
    return 'Hace ${minutes}m';
  }

  @override
  String time_hours_ago(int hours) {
    return 'Hace ${hours}h';
  }

  @override
  String time_days_ago(int days) {
    return 'Hace ${days}d';
  }

  @override
  String get time_updated_just_now => 'Actualizado hace un momento';

  @override
  String get alerts_title => 'Alertas';

  @override
  String get alerts_tab_active => 'Alertas activas';

  @override
  String get alerts_tab_history => 'Historial';

  @override
  String get alerts_btn_previous => 'Anterior';

  @override
  String get alerts_btn_next => 'Siguiente';

  @override
  String alerts_page_info(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get org_title => 'Organizaciones';

  @override
  String get org_empty => 'Aún no hay organizaciones';

  @override
  String get org_btn_add => 'Agregar organización';

  @override
  String get org_form_create_title => 'Crear organización';

  @override
  String get org_form_name_label => 'Nombre de la organización';

  @override
  String get org_form_name_required => 'El nombre es requerido';

  @override
  String get org_form_name_short => 'El nombre es demasiado corto';

  @override
  String get org_form_name_long => 'El nombre es demasiado largo';

  @override
  String get org_form_edit_title => 'Editar organización';

  @override
  String get org_dialog_delete_title => '¿Eliminar organización?';

  @override
  String org_dialog_delete_content(String name) {
    return 'Esto eliminará \"$name\".';
  }

  @override
  String get spaces_title => 'Espacios';

  @override
  String get spaces_empty => 'Aún no hay espacios';

  @override
  String get spaces_btn_create => 'Crear espacio';

  @override
  String get spaces_form_name_label => 'Nombre del espacio';

  @override
  String get spaces_form_edit_title => 'Editar espacio';

  @override
  String get spaces_dialog_delete_title => '¿Eliminar espacio?';

  @override
  String spaces_dialog_delete_content(String name) {
    return 'Esto eliminará \"$name\".';
  }

  @override
  String get devices_title => 'Espacio';

  @override
  String get devices_empty => 'Aún no hay dispositivos';

  @override
  String get devices_btn_add => 'Agregar dispositivo';

  @override
  String get devices_form_claim_title => 'Agregar dispositivo';

  @override
  String get devices_form_claim_token => 'Token de reclamo';

  @override
  String get devices_form_claim_token_hint => 'Ingrese el token de un solo uso';

  @override
  String get devices_form_claim_token_required =>
      'El token de reclamo es requerido';

  @override
  String get devices_form_pair_title => 'Emparejar dispositivo';

  @override
  String get devices_form_pair_hardware => 'ID de hardware';

  @override
  String get devices_form_pair_hardware_hint => 'ej. CLAIR-AB12';

  @override
  String get devices_form_pair_hardware_required =>
      'El ID de hardware es requerido';

  @override
  String get devices_form_pair_button => 'Emparejar';

  @override
  String get devices_dialog_pairing_title => 'Emparejamiento iniciado';

  @override
  String get devices_dialog_pairing_no_token =>
      'No se devolvió ningún token de reclamo.';

  @override
  String devices_dialog_pairing_token(String token) {
    return 'Token de reclamo: $token';
  }

  @override
  String get devices_not_found => 'Dispositivo no encontrado';

  @override
  String get devices_dialog_delete_title => 'Eliminar dispositivo';

  @override
  String devices_dialog_delete_content(String name) {
    return '¿Está seguro de que desea eliminar \"$name\"? Esta acción restablecerá la asignación del dispositivo.';
  }

  @override
  String get devices_thresholds => 'Umbrales';

  @override
  String get devices_thresholds_health =>
      'Puede afectar la salud del dispositivo';

  @override
  String get devices_thresholds_saved => 'Umbrales guardados con éxito.';

  @override
  String get devices_thresholds_reset => 'RESTABLECER';

  @override
  String get devices_thresholds_save => 'GUARDAR';

  @override
  String get devices_thresholds_max => 'máx';

  @override
  String get settings_title => 'Ajustes';

  @override
  String get settings_logout => 'Cerrar sesión';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_select_language => 'Seleccionar idioma';

  @override
  String get settings_english => 'Inglés';

  @override
  String get settings_spanish => 'Español';

  @override
  String get notifications_title => 'Notificaciones';

  @override
  String get notifications_empty_title => 'Aún no hay notificaciones';

  @override
  String get notifications_empty_subtitle =>
      'Le avisaremos cuando ocurra algo importante.';

  @override
  String analytics_device_offline_message(String deviceName) {
    return 'El dispositivo con ID \"$deviceName\" no tiene datos de telemetría en vivo recientes; podría estar apagado o desconectado.';
  }

  @override
  String get alerts_last_30_days => 'Últimos 30 días';

  @override
  String get alerts_col_device => 'DISPOSITIVO';

  @override
  String get alerts_col_severity => 'SEVERIDAD';

  @override
  String get alerts_col_space => 'ESPACIO';

  @override
  String get alerts_col_variable => 'VARIABLE';

  @override
  String get alerts_col_time => 'HORA';

  @override
  String get alerts_col_status => 'ESTADO';

  @override
  String get alerts_no_alerts_found => 'No se encontraron alertas';

  @override
  String get alerts_loading => 'Cargando alertas...';

  @override
  String spaces_card_devices(String count) {
    return '$count DISPOSITIVOS';
  }

  @override
  String get common_open => 'Abrir';

  @override
  String get time_updated_recently => 'Actualizado recientemente';

  @override
  String time_updated_seconds_ago(int seconds) {
    return 'Actualizado hace ${seconds}s';
  }

  @override
  String time_updated_minutes_ago(int minutes) {
    return 'Actualizado hace ${minutes}m';
  }

  @override
  String time_updated_hours_ago(int hours) {
    return 'Actualizado hace ${hours}h';
  }

  @override
  String time_updated_days_ago(int days) {
    return 'Actualizado hace ${days}d';
  }

  @override
  String get devices_vitals_connectivity => 'CONECTIVIDAD';

  @override
  String get devices_vitals_uptime => 'TIEMPO DE ACTIVIDAD';

  @override
  String get devices_vitals_uptime_unit => 'horas';

  @override
  String get devices_vitals_health => 'SALUD DEL DISPOSITIVO';

  @override
  String get devices_vitals_last_update => 'ÚLTIMA ACTUALIZACIÓN';

  @override
  String get devices_vitals_last_update_unit => 'h';
}
