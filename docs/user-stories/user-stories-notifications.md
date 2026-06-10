# Historias de Usuario - Bounded Context de Notifications

Esta sección presenta las Epics y User Stories identificadas para el Bounded Context de Notifications de la plataforma IoT. Todas las historias están escritas desde la perspectiva de un rol real de la plataforma (Usuario), enfocándose en el valor de negocio y con criterios de aceptación específicos sin hacer referencia a detalles de la interfaz de usuario.

## Epics

| Epic / Story ID | Título | Descripción | Criterios de Aceptación | Relacionado con (Epic ID) |
| --------------- | ------ | ----------- | ----------------------- | ------------------------- |
| MA-EP-05 | Visualización del Historial de Notificaciones | Como Usuario, quiero visualizar mis notificaciones recibidas en la plataforma, para que pueda revisar los avisos y alertas importantes enviados a mi cuenta. | La Epic se completa cuando todas las historias de usuario relacionadas han sido implementadas, validadas y aceptadas. | - |

## User Stories

| Epic / Story ID | Título | Descripción | Criterios de Aceptación | Relacionado con (Epic ID) |
| --------------- | ------ | ----------- | ----------------------- | ------------------------- |
| MA-US-27 | Ver Lista de Notificaciones | Como Usuario, quiero ver el listado de mis notificaciones recibidas, para que pueda enterarme de los avisos del sistema y eventos ocurridos. | Dado que el Usuario está autenticado y tiene acceso a la sección de notificaciones, cuando el Usuario solicita su listado de notificaciones, entonces el sistema retorna una lista paginada de notificaciones conteniendo el ID de la notificación, el título del aviso, el mensaje detallado y la fecha de recepción. | MA-EP-05 |
