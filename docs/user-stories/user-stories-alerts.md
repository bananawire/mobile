# Historias de Usuario - Bounded Context de Alerts

Esta sección presenta las Epics y User Stories identificadas para el Bounded Context de Alerts de la plataforma IoT. Todas las historias están escritas desde la perspectiva de un rol real de la plataforma (Usuario), enfocándose en el valor de negocio y con criterios de aceptación específicos sin hacer referencia a detalles de la interfaz de usuario.

## Epics

| Epic / Story ID | Título | Descripción | Criterios de Aceptación | Relacionado con (Epic ID) |
| --------------- | ------ | ----------- | ----------------------- | ------------------------- |
| MA-EP-03 | Monitoreo y Gestión de Alertas | Como Usuario, quiero visualizar, filtrar y gestionar el estado de las alertas generadas por mis dispositivos, para que pueda responder oportunamente ante eventos críticos e incidencias. | La Epic se completa cuando todas las historias de usuario relacionadas han sido implementadas, validadas y aceptadas. | - |

## User Stories

| Epic / Story ID | Título | Descripción | Criterios de Aceptación | Relacionado con (Epic ID) |
| --------------- | ------ | ----------- | ----------------------- | ------------------------- |
| MA-US-19 | Ver Lista Completa de Alertas | Como Usuario, quiero ver la lista completa de alertas generadas en mi plataforma, para que pueda conocer todas las notificaciones de problemas en mis dispositivos. | Dado que el Usuario tiene acceso a la sección de alertas, cuando el Usuario solicita el listado de alertas generales, entonces el sistema retorna una lista paginada de alertas que contiene el ID de la alerta, el ID del dispositivo afectado, la descripción de la incidencia, la severidad (baja, media, alta), el estado actual (activa, reconocida) y la fecha de creación. | MA-EP-03 |
| MA-US-20 | Filtrar Alertas por Dispositivo o Espacio | Como Usuario, quiero filtrar las alertas por un dispositivo o espacio específico, para que pueda enfocar mi atención en áreas particulares del sistema. | Dado que el Usuario está visualizando el historial de alertas, cuando el Usuario selecciona un ID de dispositivo o un ID de espacio como filtro de búsqueda, entonces el sistema valida el identificador y retorna únicamente las alertas asociadas a ese dispositivo o espacio. | MA-EP-03 |
| MA-US-21 | Ver Resumen Diario de Alertas | Como Usuario, quiero ver un resumen diario del conteo de alertas generadas, para que pueda comprender la frecuencia y evolución de las incidencias en el tiempo. | Dado que el Usuario desea analizar la recurrencia de fallos, cuando el Usuario solicita el resumen diario de alertas, entonces el sistema computa los registros y retorna el conteo agrupado de alertas por día y clasificado por nivel de severidad. | MA-EP-03 |
| MA-US-22 | Reconocer Alerta Activa | Como Usuario, quiero reconocer una alerta activa en el sistema, para que quede registrado que la incidencia ha sido revisada o atendida. | Dado que el Usuario tiene una alerta en estado activa, cuando el Usuario envía la solicitud de reconocimiento especificando el ID de la alerta, entonces el sistema valida la existencia de la alerta, cambia su estado a reconocida y guarda la fecha y hora de la actualización. | MA-EP-03 |
