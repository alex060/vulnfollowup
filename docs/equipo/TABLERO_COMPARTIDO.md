# Tablero compartido de Alex, Adri y Pablo

Este es el reparto inicial propuesto, no un registro de trabajo ya realizado. Todo empieza en **Pendiente**. Cambiad responsables si las horas reales quedan desequilibradas, manteniendo una revisión y una demostración por alguien distinto del autor.

**Lleva:** construye y explica. **Revisa:** comprueba y aporta una prueba, corrección o mejora. **Demuestra:** ejecuta y explica sin que el autor le dicte los pasos. Todos tienen que entender el objetivo, el recorrido de datos y las pruebas.

Estados sugeridos: Pendiente > En curso > En revisión > Por explicar > Terminada. Un bloqueo se anota con la dependencia que falta. No marcar Terminada porque solo funcione en el equipo del autor.

## Tareas técnicas

| Tarea | Lleva | Revisa | Demuestra | Hace falta antes | Estado |
| --- | --- | --- | --- | --- | --- |
| T01. Alcance, tecnologías y contrato inicial | Alex | Adri | Pablo | Leer el enunciado juntos | Pendiente |
| T02. Proyectos y arranque | Adri | Pablo | Alex | T01 | Pendiente |
| T03. Tablas y datos de prueba | Pablo | Alex | Adri | T01-T02 | Pendiente |
| T04. Login y permisos | Alex | Pablo | Adri | T03 | Pendiente |
| T05. API de activos | Adri | Alex | Pablo | T03-T04 | Pendiente |
| T06. API de vulnerabilidades y relaciones | Pablo | Adri | Alex | T05 | Pendiente |
| T07. Validación CVSS | Alex | Adri | Pablo | T06 | Pendiente |
| T08. Importación y rollback | Adri | Pablo | Alex | T03, T06-T07 | Pendiente |
| T09. Remediación y auditoría | Pablo | Alex | Adri | T06-T07 | Pendiente |
| T10. Concurrencia y protección | Alex | Pablo | Adri | T09 | Pendiente |
| T11. Tarea y proceso de informe | Adri | Alex | Pablo | Consulta de pendientes y permisos | Pendiente |
| T12. Proveedores, regla e informe | Pablo | Adri | Alex | Modelo T03 y API básica T04-T06 | Pendiente |
| T13. Web: login, formularios y detalle | Alex | Adri | Pablo | Contrato T04-T09; bocetos antes | Pendiente |
| T14. Web: filtros, dashboard y exportación | Adri | Pablo | Alex | Consultas API y T13 | Pendiente |
| T15. Android: login, lista, filtros y detalle | Pablo | Alex | Adri | Contrato T04-T07; conexión mínima tras T06 | Pendiente |
| T16. Android: cambios y caché | Alex | Pablo | Adri | T09, T15 y control de versión | Pendiente |
| T17. Distribución web y APK | Adri | Alex | Pablo | T13-T16 | Pendiente |
| T18. Pruebas integradas | Pablo | Adri | Alex | Repetir pruebas desde cada tarea; cierre tras T17 | Pendiente |

Cada persona lidera seis tareas, revisa seis y demuestra seis. La cantidad de tareas no mide su dificultad: anotad horas y ajustad. Una primera lectura real desde web y móvil se hace tras T06 para detectar problemas pronto, sin esperar a terminar todas las pantallas.

## Trabajos transversales

| Trabajo | Lleva | Revisa | Demuestra o defiende | Estado |
| --- | --- | --- | --- | --- |
| Inglés escrito: README, API, glosario y resumen | Alex | Adri | Pablo | Pendiente |
| Inglés oral: vídeo, guion y defensa | Adri | Pablo | Alex | Pendiente |
| IPE: negocio, costes, plan y actas | Pablo | Alex | Adri | Pendiente |
| Digitalización | Alex | Pablo | Adri | Pendiente |
| Sostenibilidad y mediciones | Adri | Alex | Pablo | Pendiente |
| Memoria común y declaración de IA | Pablo | Adri | Alex | Pendiente |

Los tres participan en vídeo y defensa, revisan sus contribuciones y actualizan sus portfolios. Quien lleva la memoria coordina, no redacta a ciegas todo lo de los otros.

## Ficha que copiáis para cada tarea

- Identificador y objetivo: qué comportamiento tiene que funcionar.
- Lleva / revisa / demuestra: nombres de los tres.
- Dependencias: qué datos o funciones deben existir antes.
- Pasos pequeños: lo que vais a realizar en esta sesión.
- Comprobación normal y de error: cómo sabréis que funciona.
- Aportación de revisión: prueba, corrección o mejora realizada.
- Evidencia: ruta de la prueba, captura o documento.
- Explicación compartida: qué dudas surgieron y qué falta entender.
- Tiempo real: construcción, revisión y explicación, por persona.
- Estado y siguiente paso.

## Requisitos para cerrar una tarea

- [ ] Se ha probado el caso correcto y un error relevante.
- [ ] El revisor ha comprobado el trabajo y dejado una aportación.
- [ ] El demostrador puede ejecutarlo siguiendo instrucciones.
- [ ] Los tres explican objetivo, recorrido, decisión y prueba.
- [ ] La evidencia y las instrucciones están guardadas.
- [ ] Se ha actualizado la matriz de conocimiento sin inventar avances.

## Rutina compartida

Al empezar: cinco minutos para decir qué hizo cada uno, qué hará y qué necesita. Al terminar una tarea: explicación breve, revisión y demostración por otro. Ajustar la duración a la dificultad; dividir tareas demasiado grandes.

Antes de entregar: ensayo con intercambio de presentadores y preguntas individuales mezcladas. Ninguno responde por otro antes de que termine su explicación.
