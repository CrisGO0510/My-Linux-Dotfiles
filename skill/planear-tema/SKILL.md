---
name: planear-tema
description: Use when the user asks for a study plan for a topic, unit or range of topics of one of their university courses — e.g. "hazme el plan de flip-flops", "plan de estudio para el 11 de Com II", "cómo estudio FSM a fondo", "/planear-tema 05 - RV32I". First recommends which study technique fits that topic (mapa, iceberg, puntos en conflicto, Feynman, or none), showing how each would apply, waits for the user to confirm, and only then writes the plan as a note in the vault.
---

# Planear tema

Arma el plan de estudio de un tema en dos fases: primero **recomienda** qué técnicas le sirven a
ese tema y cómo se aplicarían; cuando el usuario **confirma**, escribe el plan.

Son dos fases porque ninguna técnica sirve para todos los temas. Aplicarlas todas siempre llena el
bloque de pasos que no mejoran lo que el tema exige. Decidir con el tema delante, y con cada
técnica ya aplicada en una línea, deja la elección en manos de quien va a estudiar.

Vault: `~/Documents/obsidian`. Cada materia vive en `Estudio/<Materia>/`: una nota índice con el
nombre de la materia, un tema por nota (`NN - Nombre.md`), a veces notas de entregas (`P1 - …`) y
una carpeta `Material/`. `Estudio/Plan del semestre.md` trae el nivel y el presupuesto de cada tema.

## Lo que condiciona el plan

- **Solo hay bloques profundos**: tardes, noches y fines de semana. No existe tiempo muerto, así
  que nada se manda «a un hueco»; lo que no cabe en un bloque no entra en el plan.
- **`Plan del semestre` todavía reparte temas a la cola `#tm`, a «un hueco» y a hilos diarios.**
  Esa parte quedó desactualizada. De ese archivo se toman el nivel, el presupuesto y el
  entregable de dominio de la materia; el reparto por colas y por semanas se ignora. Un
  presupuesto «+ hilo» significa que el tema lleva calentamiento.
- **Una sesión del plan es un bloque** de unos 90 minutos.
- **El objetivo es profundizar, no cubrir.** Pocas piezas llevadas hasta el porqué sirven más que
  muchas tocadas por encima.
- **Se estudia en papel y lápiz.** Solo se menciona software si la materia ya lo usa (por ejemplo,
  Packet Tracer en Comunicaciones II). No proponer instalar nada.
- **Niveles**, tal como los define `Plan del semestre`:
  - **A · Dominio**: producir sin mirar (resolver, diseñar, calcular).
  - **B · Explicación**: explicarlo con palabras propias.
  - **C · Reconocimiento**: reconocer el término y saber dónde vive.

## Flujo (en orden)

1. **Ubicar el tema.** El argumento puede ser un número con la materia abreviada, un nombre o un
   rango (`01 a 05`).
   - Resolver la materia contra las carpetas de `Estudio/`. Preguntar solo si número y nombre
     juntos no señalan una única nota.
   - Buscar el tema dentro de `Plan del semestre` (no hace falta leerlo entero). La fila de la
     tabla de su materia da nivel, presupuesto y el porqué. La sección «entregable de dominio» de
     esa materia dice qué hay que producir: de ahí sale el **Núcleo**.
   - Si `Semana.md` menciona el tema, lo que diga ahí manda, porque es más reciente. Solo leerla.
   - Si el tema no está en el plan, proponer nivel con el criterio «¿procedimiento o
     vocabulario?» y un presupuesto en bloques, y decirlo en **Avisos** para que lo corrija.

2. **Leer lo que hay**, de lo más barato a lo más caro, y parar cuando ya se vea qué exige el tema:
   - la nota del tema (`## Notas` es material de clase);
   - la nota índice de la materia y las notas de entregas que el tema alimenta: dicen cómo se
     evalúa, que es lo que decide qué vale la pena profundizar;
   - los temas de los que depende, es decir, los que la nota o el plan nombran, aunque sean de
     otra materia. De ellos basta el encabezado;
   - de `Material/`, solo los archivos del tema que `## Notas` no resuma ya.

   Calificar el material. *Suficiente*: alcanza para escribir los ejercicios del núcleo sin salir
   del curso. *Mínimo*: dice qué hay que producir, pero no trae con qué practicarlo. *Nada*: solo
   el encabezado. Muchas notas solo tienen el encabezado; es el caso normal.

3. **Investigar por fuera, en proporción a lo que falte.** El fin es saber qué forma tiene el
   tema: si hay fallos que explicar, decisiones que tomar o posturas que discrepan. Con material
   suficiente basta una búsqueda de contraste, o ninguna si el material ya deja ver esa forma. Con
   material mínimo o nada, dos o tres. Antes de la confirmación no conviene más: casi todo lo que
   se investigue a fondo puede quedar descartado. La búsqueda web puede estar como herramienta
   diferida; cargarla antes de concluir que no hay. Si de verdad no hay, decirlo en **Avisos**.

4. **Recomendar.** Un solo mensaje con el formato de abajo.

5. **Parar y esperar.** No escribir nada del plan todavía. El usuario responde con los números de
   las técnicas que confirma; puede confirmar varias, ninguna, o pedir que se amplíe una fila.

6. **Investigar a fondo, solo lo confirmado.** Para puntos en conflicto, posturas reales y quién
   las sostiene; para iceberg, el fallo documentado y su causa; para el núcleo, ejercicios del
   tipo que pide el curso. Preferir libros de texto, documentación oficial y apuntes de cursos
   universitarios. Anotar la fuente de cada dato que no venga del material del curso.

7. **Escribir el plan** con el formato de abajo, en la carpeta de la materia. Si ya existe una
   nota de plan para ese tema, no sobrescribirla: avisar y preguntar si se reemplaza o se amplía.

8. **Avisar** dónde quedó la nota, en una línea.

## Las técnicas

El criterio describe la forma del tema, no la materia: así sirve igual en electrónica, en gestión
o en historia.

| Técnica | Se recomienda si el tema… | En el plan queda como… |
|---|---|---|
| **Mapa** | es una unidad nueva con varias piezas que dependen entre sí | `## Mapa`: las piezas que el tema tenga (sin forzar un número), de qué tema anterior depende cada una y, si los hay, qué temas C vecinos quedan cubiertos aquí |
| **Iceberg** | tiene hechos que se repiten y hay que explicar por qué pasan: un fallo, o un diseño que parece raro | Bloque **Capas** dentro del mini proyecto donde aparece: cuatro preguntas — evento, patrón, estructura, modelo mental |
| **Puntos en conflicto** | obliga a elegir entre opciones, o tiene posturas que discrepan | Bloque **Dilema** dentro del mini proyecto donde hay que elegir: las opciones, el criterio para juzgarlas, y la tarea de defender cada una y luego decidir para un caso concreto |
| **Feynman** | tiene un porqué que no se ve al ejecutarlo: se puede hacer bien sin entenderlo | `## Cierre · Feynman`: qué explicar, y la consigna lista para pegar en un chat |
| **Ninguna** | es un procedimiento que solo se gana repitiendo | El plan lleva solo el núcleo |

Cómo pesa el nivel:

- En un tema **A** el núcleo son ejercicios y las técnicas van alrededor, nunca en su lugar.
  Feynman va después de producir y pregunta por el porqué de cada paso, no pide una analogía
  para legos: explicar bien no predice resolver contra reloj.
- En un tema **B** explicar es el entregable, así que Feynman suele ser la recomendada.
- Un tema **C** casi nunca merece plan propio. Decirlo, y proponer en cuál `## Mapa` vecino entra.

Los veredictos:

- **Recomendada**: encaja, y lo que cuesta cabe en el presupuesto sin quitarle al núcleo.
- **Posible**: encaja, pero compite con el núcleo por el tiempo. Vale si sobra bloque o si es lo
  que más le interesa al usuario.
- **No hace falta**: no encaja, o repetiría lo que ya hace otra. Si dos técnicas caen sobre la
  misma pregunta, se recomienda la que mejor encaja y la otra lo dice: «repetiría la 1».

## Formato de la recomendación

```
**<NN - Tema>** · <Materia> · nivel <A/B/C> · <presupuesto> · material: <suficiente/mínimo/nada>
**Núcleo:** <lo que hay que producir en papel, en una línea>
**Avisos:** <solo si hay algo que decir>

| # | Técnica | Veredicto | Cómo se aplicaría |
|---|---|---|---|
| 1 | … | Recomendada · ~20 min | <este tema ya aplicado> |
| 2 | … | Posible · ~15 min | … |
| 3 | … | No hace falta | <por qué, una línea> |
| 4 | … | No hace falta | … |

¿Cuáles confirmas?
```

- Van siempre las cuatro técnicas, ordenadas de mayor a menor encaje. «Ninguna» no es una fila:
  es lo que pasa cuando las cuatro quedan en *No hace falta*.
- El veredicto lleva un costo aproximado en minutos de bloque, para que se vea cuánto le resta
  cada técnica al núcleo.
- «Cómo se aplicaría» lleva el contenido real del tema, no la definición de la técnica, en una o
  dos líneas. Nombra el hecho o la decisión y la pregunta, sin resolverla: «El latch falla cuando
  la salida vuelve a la entrada → ¿por qué existe el flanco?» sirve; «analizar causas en cuatro
  capas» no.
- La línea de **Núcleo** va siempre, para que la práctica no desaparezca detrás de las técnicas.
- **Avisos** es para lo que el usuario necesita saber antes de confirmar: nivel o presupuesto
  propuestos por no estar en el plan, material que falta y de dónde saldría, un dato de fuera
  usado en la tabla con su fuente, una diferencia entre el curso y una fuente externa, un tema C,
  o un plan que ya existe.
- Si ninguna encaja, decirlo sin rodeos y ofrecer el plan solo con el núcleo. Recomendar algo
  siempre, por no dejar la tabla vacía, es el fallo que esta skill existe para evitar.

## Formato del plan

Nota nueva en `Estudio/<Materia>/Plan · <NN - Tema>.md` (o `Plan · NN a NN.md` para un rango):

```
Plan de aprendizaje temporal de [[<Materia>]]. Se borra cuando se cierre el tema.

# Plan · <NN - Tema>

nivel <A/B/C> · <presupuesto> · técnicas: <las confirmadas, o «ninguna»>

| MP | Cubre | Presupuesto |
|---|---|---|

## Mapa                      (solo si se confirmó)

## Calentamiento             (10 min al abrir cada bloque)

## MP1 · <título>
**Escenario:** …
**Ejercicios guiados:** …
**Requisitos:** …
**Capas:** …                 (iceberg, si se confirmó y aparece aquí)
**Dilema:** …                (puntos en conflicto, si se confirmó y aparece aquí)
**Teoría:** …
**Lo logras cuando:** …

## Cierre · Sin mirar

## Cierre · Feynman          (solo si se confirmó)

## Fuentes
**De tu curso:** …
**De fuera:** …
```

- **Mini proyectos.** Cada uno parte de un escenario concreto y se construye sobre el anterior.
  Los ejercicios guiados van numerados y con su «Pasa si…». *Teoría* son las preguntas que hay
  que poder responder para explicar lo hecho. *Lo logras cuando* es un criterio verificable.
- **Calentamiento.** Un procedimiento corto de un tema anterior, repetido al abrir cada bloque
  hasta que salga sin dudar. Es el hilo continuo del tema, ahora dentro del bloque.
- **Cierre · Sin mirar.** Un solo enunciado integrador que se resuelve sin consultar nada.
- **Cierre · Feynman.** Qué explicar y esta consigna, adaptada al tema: «Voy a explicarte <X>. No
  me corrijas mientras explico. Al final dime máximo tres lagunas, ordenadas por gravedad, y no
  me des la respuesta». Las lagunas que salgan pasan al calentamiento del bloque siguiente.
- **Presupuesto.** El total del plan no supera el presupuesto del tema; la tabla lo reparte.
- **Enlaces.** A las notas de tema, con alias corto: `[[04 - Flip-flops|04]]`.

## Detalles que importan

- **Preguntas, no respuestas.** Ejercicios, *Capas* y *Dilema* llevan solo el enunciado: sin
  pasos, sin pistas y sin la solución. Quien estudia quiere resolverlo y pide las pistas cuando
  las necesita; un plan que ya trae la respuesta le quita justo el trabajo que lo hace aprender.
- **Lo de fuera va marcado.** Todo lo que no salga del material del curso lleva su fuente en
  `## Fuentes`. El examen se califica contra el curso: si una fuente externa lo contradice, manda
  el curso y la diferencia se anota en el plan.
- **Solo se escribe la nota del plan.** No tocar `Semana`, `Plan del semestre` ni la nota del
  tema: `## Notas` es material de clase y `## Lo que entendí` lo escribe el usuario sin mirar.
- **Nombres de materia completos**, tal como se llama su carpeta.
- **En español y de tú**, como el resto del vault.
