# Ejercicio Integrador de Base de Datos – TransExpress

Proyecto integrador para el diseño, implementación y gestión de una base de datos empresarial en SQL. Elaborado en el marco de la materia **Base de Datos** de la carrera **Ingeniería en Sistemas**.

---

## Contenido del Ejercicio

1. Creación de la Base de Datos y Esquemas
2. Creación de Tablas con Relaciones y Restricciones
3. Creación de Usuarios y Roles con Permisos
4. Implementación de Procedimientos Almacenados
5. Implementación de Triggers para Automatización y Auditoría
6. Creación de Vistas y Vistas Materializadas
7. Pruebas y Validaciones

---

## Contexto Empresarial: TransExpress

**TransExpress** es una empresa de transporte de pasajeros y mercancías en rutas nacionales. Requiere una base de datos robusta que permita gestionar eficientemente sus recursos, empleados, vehículos, rutas y asignaciones.

### 1. Características de la Empresa

#### 1.1 Operaciones de Transporte

* **Flota de Vehículos:** Colectivos, camiones y combis, cada uno con capacidad, tipo de carga y estado operativo.
* **Conductores:** Certificados con licencias específicas según el tipo de vehículo.
* **Rutas:** Con origen, destino y distancia en kilómetros.
* **Asignaciones:** Vehículos asignados diariamente a conductores y rutas. Estados posibles: *Activa*, *Completada* o *Cancelada*.

#### 1.2 Gestión Administrativa

* **Empleados Administrativos:** Gestionan RRHH, finanzas, mantenimiento y planificación de rutas.
* **Departamentos y Puestos:** Organización interna con salarios asociados.
* **Roles y Permisos:** Control de acceso según el perfil del empleado.

---

## 2. Requisitos del Sistema de Base de Datos

### 2.1 Estructura de la Base de Datos

* **Base de Datos Principal:** `transporte_db`
* **Esquemas:**

  * `operaciones`: Vehículos, conductores, rutas y asignaciones.
  * `administracion`: Empleados, departamentos, puestos, roles y relaciones entre ellos.

### 2.2 Entidades y Relaciones Principales

#### Esquema `operaciones`

1. **vehiculos**

   * Atributos: `vehiculo_id`, `matricula`, `modelo`, `capacidad_pasajeros`, `estado`
   * Descripción: Estado operativo (*Disponible*, *En Mantenimiento*, *Asignado*).

2. **rutas**

   * Atributos: `ruta_id`, `origen`, `destino`, `distancia_km`
   * Descripción: Define rutas con origen, destino y distancia.

3. **conductores**

   * Atributos: `conductor_id`, `nombre`, `apellido`, `licencia`, `telefono`
   * Descripción: Datos personales y licencias de los conductores.

4. **asignaciones**

   * Atributos: `asignacion_id`, `conductor_id`, `vehiculo_id`, `ruta_id`, `fecha_asignacion`, `estado_asignacion`
   * Descripción: Registra las asignaciones diarias.

#### Esquema `administracion`

1. **empleados**

   * Atributos: `empleado_id`, `nombre`, `apellido`, `departamento_id`, `puesto_id`
   * Descripción: Datos básicos del personal administrativo.

2. **departamentos**

   * Atributos: `departamento_id`, `nombre`, `ubicacion`
   * Descripción: Departamentos y ubicaciones.

3. **puestos**

   * Atributos: `puesto_id`, `nombre`, `salario`
   * Descripción: Puestos y salarios asociados.

4. **roles**

   * Atributos: `rol_id`, `nombre_rol`, `descripcion`
   * Descripción: Define niveles de acceso dentro del sistema.

5. **empleados_roles**

   * Atributos: `empleado_id`, `rol_id`
   * Descripción: Relación entre empleados y sus roles.

### 2.3 Funcionalidades Específicas

#### 1. Gestión de Usuarios y Permisos

* Crear roles con distintos niveles de acceso (*lectura*, *gestión completa*) para cada esquema.
* Asignar roles a usuarios específicos.

#### 2. Procedimientos Almacenados

* Automatizar tareas como asignar vehículos a conductores/rutas.
* Transferir empleados administrativos entre departamentos.

#### 3. Triggers

* Actualizar automáticamente el estado de vehículos al ser asignados.
* Evitar eliminar conductores con asignaciones activas.
* Registrar auditorías al eliminar empleados.

#### 4. Vistas y Vistas Materializadas

* Vistas: consultas simplificadas (conductores asignados, vehículos por estado, etc.).
* Vistas materializadas: consultas sumarias optimizadas (empleados por departamento, salarios por puesto).

---

## 3. Tareas a Realizar

### 3.1 Diseño e Implementación de la Base de Datos

1. **Crear la base de datos y esquemas**

   * Crear `transporte_db`.
   * Crear esquemas `operaciones` y `administracion`.

2. **Definir y crear tablas**

   * Crear las tablas según lo indicado en cada esquema.

3. **Establecer relaciones y restricciones**

   * Definir claves primarias, foráneas y restricciones de integridad referencial.

### 3.2 Gestión de Usuarios, Roles y Permisos

1. Crear un usuario **administrador** con privilegios completos.
2. Crear roles sin *LOGIN* para lectura y gestión completa en ambos esquemas.
3. Asignar roles a usuarios con *LOGIN* para controlar accesos.

### 3.3 Procedimientos Almacenados

1. **Asignar vehículo a ruta:** Procedimiento que vincula vehículo disponible a conductor/ruta y actualiza estado.
2. **Transferir empleado:** Procedimiento que cambia el departamento de un empleado y registra el movimiento en un historial.

### 3.4 Creación de Triggers

1. **Actualizar estado del vehículo:** Al crear una asignación, el vehículo pasa a estado *Asignado*.
2. **Evitar eliminación de conductores activos:** Impide borrar conductores con asignaciones vigentes.
3. **Registrar auditoría:** Al eliminar un empleado, se guarda un registro en tabla de auditoría.

### 3.5 Creación de Vistas y Vistas Materializadas

1. **Vistas:** Para consultas frecuentes como lista de conductores asignados o cantidad de vehículos por estado.
2. **Vistas Materializadas:** Para optimizar consultas agregadas (empleados por departamento, salarios totales por puesto).

---

## 4. Pruebas y Validación

1. **Datos de Prueba:** Insertar registros representativos.
2. **Verificación de Procedimientos y Triggers:** Probar su funcionamiento e integridad de datos.
3. **Consulta de Vistas:** Validar que las vistas devuelvan información correcta y optimizada.

---

**Material elaborado por la Cátedra de Base de Datos**
Ingeniería en Sistemas – Práctico XIV – Ejercicio Integrador
