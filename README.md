Informe de Examen - Unidad III
Nombre del curso: Desarrollo de Aplicaciones Móviles
Fecha: [DD/MM/AAAA]
Nombres completos del estudiante: [Nombre Apellido]

🔗 URL del Repositorio en GitHub
📌 https://github.com/[TU_USUARIO]/SM2_ExamenUnidad3

📸 Capturas de Pantalla
1. Estructura de Carpetas .github/workflows/
https://via.placeholder.com/600x300?text=Carpeta+.github%252Fworkflows+con+quality-check.yml
(Se muestra la ubicación correcta del archivo quality-check.yml dentro de .github/workflows/.)

2. Contenido del Archivo quality-check.yml
https://via.placeholder.com/600x300?text=Contenido+de+quality-check.yml
(Se evidencia el código YAML configurado para análisis y pruebas automáticas.)

3. Ejecución del Workflow en GitHub Actions
https://via.placeholder.com/600x300?text=Workflow+ejecut%C3%A1ndose+en+la+pesta%C3%B1a+Actions
(Workflow exitoso con todos los pasos en verde y 100% de pruebas aprobadas.)

📝 Explicación de lo Realizado
1. Configuración del Repositorio
Se creó un repositorio público en GitHub con el nombre exacto SM2_ExamenUnidad3.

Se copió el proyecto móvil desarrollado durante el curso.

2. Implementación del Workflow
Se creó el archivo quality-check.yml en .github/workflows/ con el siguiente flujo:

Trigger: Se ejecuta automáticamente en cada push o pull request a la rama main.

Pasos:

Configuración de Flutter (versión 3.19.0).

Instalación de dependencias (flutter pub get).

Análisis de código (flutter analyze).

Ejecución de pruebas unitarias (flutter test).

3. Pruebas Unitarias
Se implementaron 3 pruebas en main_test.dart para validar:

División de strings con split().

Eliminación de espacios con trim().

Conversión de strings a enteros con int.parse().

4. Verificación
El workflow se ejecutó correctamente en GitHub Actions.

Todos los pasos (analyze y test) fueron exitosos (100% passed).



