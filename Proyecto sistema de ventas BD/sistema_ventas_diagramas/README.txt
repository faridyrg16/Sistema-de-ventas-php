SISTEMA DE VENTAS – DIAGRAMAS (PlantUML)
========================================

Qué hay aquí
------------
- 01_casos_uso.puml — Diagrama de casos de uso (Admin, Vendedor, Cliente).
- 02_clases.puml — Diagrama de clases: Persona→Cliente/Vendedor, Producto, Categoría, Venta, DetalleVenta, Usuario.
- 03_arquitectura.puml — Arquitectura en capas: Presentación → Lógica → Datos, más exportaciones.
- 04_secuencia_registrar_venta.puml — Secuencia completa para Registrar Venta.

Cómo generar IMÁGENES (PNG/SVG)
-------------------------------
Opción A: VS Code + extensión “PlantUML”
1. Instala Java y Graphviz (si no lo tienes).
2. Abre el archivo .puml y presiona Alt+D (Windows) para previsualizar.
3. Clic derecho → “Export Current Diagram” → PNG o SVG.

Opción B: IntelliJ/IDEA con plugin PlantUML o PlantUML Server local.

Opción C: PlantUML CLI
1. java -jar plantuml.jar *.puml
2. Se crearán .png al lado de cada archivo.

Cómo mapear con tus mensajes/figuras
------------------------------------
- Tercer mensaje (imagen 1): usa 01_casos_uso.puml
- Cuarto mensaje (imagen 2): usa 02_clases.puml
- Quinto mensaje (imagen 3): usa 03_arquitectura.puml
- Sexto mensaje (imagen 4): usa 04_secuencia_registrar_venta.puml

DBeaver – exportar ERD y BD
---------------------------
1) ERD: Database → ER Diagram → tu esquema → ícono de cámara → Export Image (PNG/SVG).
2) SQL: clic derecho en la BD/esquema → Tools → Dump database → elige formato (SQL), marca “create/insert”.

Sugerencia de empaquetado para enviar por correo
------------------------------------------------
/documentacion/
  00_Resumen_Tecnico.pdf
  01_casos_de_uso.png
  02_diagrama_clases.png
  03_arquitectura.png
  04_secuencia_registrar_venta.png
  erd_dbeaver.png
  backup_bd.sql
/plantuml/
  (estos .puml)

Licencia: úsalo libremente en tu proyecto.