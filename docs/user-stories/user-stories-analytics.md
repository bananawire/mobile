# Historias de Usuario - Bounded Context de Analytics

Esta sección presenta las Epics y User Stories identificadas para el Bounded Context de Analytics de la plataforma IoT. Todas las historias están escritas desde la perspectiva de un rol real de la plataforma (Usuario), enfocándose en el valor de negocio y con criterios de aceptación específicos sin hacer referencia a detalles de la interfaz de usuario.

## Epics

| Epic / Story ID | Título | Descripción | Criterios de Aceptación | Relacionado con (Epic ID) |
| --------------- | ------ | ----------- | ----------------------- | ------------------------- |
| MA-EP-04 | Monitoreo y Análisis de Telemetría | Como Usuario, quiero monitorear métricas en tiempo real y analizar las tendencias históricas de calidad del aire, para que pueda comprender el estado actual e histórico de mis dispositivos. | La Epic se completa cuando todas las historias de usuario relacionadas han sido implementadas, validadas y aceptadas. | - |

## User Stories

| Epic / Story ID | Título | Descripción | Criterios de Aceptación | Relacionado con (Epic ID) |
| --------------- | ------ | ----------- | ----------------------- | ------------------------- |
| MA-US-23 | Ver Métricas Actuales del Dashboard | Como Usuario, quiero ver las métricas actuales de calidad del aire del dispositivo, para que pueda conocer el estado actual de mi entorno de manera rápida. | Dado que el Usuario tiene acceso a un dispositivo activo, cuando el Usuario solicita las métricas del dashboard para ese dispositivo, entonces el sistema retorna los valores de telemetría más recientes, incluyendo el índice de calidad del aire (AQI) y la variación porcentual en comparación con el periodo anterior. | MA-EP-04 |
| MA-US-24 | Monitorear Telemetría en Tiempo Real | Como Usuario, quiero ver lecturas de telemetría en tiempo real con un indicador en vivo, para que pueda reaccionar ante cambios inmediatos en el entorno. | Dado que el Usuario está visualizando el dashboard de un dispositivo conectado, cuando el dispositivo transmite nuevos datos de telemetría al servidor, entonces el sistema actualiza automáticamente los valores mostrados en el dashboard y activa el indicador de estado de lectura en vivo. | MA-EP-04 |
| MA-US-25 | Visualizar Gráfico de Tendencias | Como Usuario, quiero ver un gráfico de tendencias de las métricas del dispositivo, para que pueda identificar patrones o anomalías visualmente. | Dado que el Usuario tiene un dispositivo con datos históricos registrados, cuando el Usuario solicita las tendencias para una métrica específica, entonces el sistema procesa los datos y retorna una serie temporal con los puntos de tendencia que contienen marcas de tiempo y valores medidos. | MA-EP-04 |
| MA-US-26 | Filtrar Tendencias por Rango de Fechas | Como Usuario, quiero seleccionar un rango de fechas para el gráfico de tendencias, para que pueda analizar datos históricos en un intervalo específico de tiempo. | Dado que el Usuario está visualizando el gráfico de tendencias, cuando el Usuario ingresa una fecha de inicio y una fecha de fin, entonces el sistema valida que la fecha de inicio sea menor o igual a la fecha de fin y retorna los puntos de tendencia registrados que correspondan exclusivamente a ese periodo seleccionado. | MA-EP-04 |
