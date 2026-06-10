# Historias de Usuario - Bounded Context de IAM (Identity and Access Management)

Esta sección presenta las Epics y User Stories identificadas para el Bounded Context de IAM de la plataforma IoT. Todas las historias están escritas desde la perspectiva de un rol real de la plataforma (Visitante o Usuario), enfocándose en el valor de negocio y con criterios de aceptación específicos sin hacer referencia a detalles de la interfaz de usuario.

## Epics

| Epic / Story ID | Título | Descripción | Criterios de Aceptación | Relacionado con (Epic ID) |
| --------------- | ------ | ----------- | ----------------------- | ------------------------- |
| MA-EP-01 | Gestión de Identidad y Sesión | Como Visitante o Usuario, quiero registrar una cuenta, autenticarme y gestionar mi sesión activa, para que pueda acceder de forma segura y controlada a las funciones de la plataforma. | La Epic se completa cuando todas las historias de usuario relacionadas han sido implementadas, validadas y aceptadas. | - |

## User Stories

| Epic / Story ID | Título | Descripción | Criterios de Aceptación | Relacionado con (Epic ID) |
| --------------- | ------ | ----------- | ----------------------- | ------------------------- |
| MA-US-01 | Iniciar Registro de Cuenta | Como Visitante, quiero iniciar mi registro proporcionando mis datos básicos, para que el sistema comience mi proceso de alta en la plataforma. | Dado que el Visitante está en el proceso de inicio de registro, cuando el Visitante ingresa su correo electrónico y contraseña, entonces el sistema valida que el correo electrónico tenga un formato correcto, que la contraseña cumpla con las reglas de seguridad mínimas, inicia la sesión de registro temporal y genera un código de verificación. | MA-EP-01 |
| MA-US-02 | Confirmar Registro con Código | Como Visitante, quiero ingresar mi código de verificación recibido, para que mi cuenta de usuario quede activada de manera definitiva. | Dado que el Visitante ha iniciado el registro y tiene una sesión de registro temporal activa, cuando el Visitante ingresa el código de verificación de 6 dígitos, entonces el sistema valida el código y activa la cuenta del usuario para permitir accesos futuros. | MA-EP-01 |
| MA-US-03 | Iniciar Sesión con Correo y Contraseña | Como Visitante, quiero iniciar sesión con mi correo electrónico y contraseña, para que pueda acceder de forma segura a mi cuenta. | Dado que el Visitante tiene una cuenta activa y confirmada en la plataforma, cuando el Visitante ingresa su correo electrónico registrado y contraseña, entonces el sistema valida las credenciales y genera un token de acceso junto con un token de actualización de sesión. | MA-EP-01 |
| MA-US-04 | Autenticar con Cuenta de Google | Como Visitante, quiero iniciar sesión usando mi cuenta de Google, para que pueda acceder de forma simplificada sin recordar contraseñas adicionales. | Dado que el Visitante desea acceder de manera simplificada, cuando el Visitante proporciona un token de identidad válido de Google, entonces el sistema verifica la validez del token con el proveedor, busca o registra al usuario en la plataforma y otorga un token de acceso activo. | MA-EP-01 |
| MA-US-05 | Cerrar Sesión | Como Usuario, quiero cerrar mi sesión activa, para que mis credenciales se invaliden y se evite el acceso no autorizado en mi dispositivo. | Dado que el Usuario tiene una sesión autenticada activa, cuando el Usuario solicita cerrar la sesión, entonces el sistema invalida los tokens de acceso y actualización almacenados en el dispositivo y destruye la sesión activa en el servidor. | MA-EP-01 |
