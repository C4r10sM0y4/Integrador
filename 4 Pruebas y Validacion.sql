-- ============================================================================
-- PRUEBAS Y VALIDACIÓN - TransExpress
-- ============================================================================
-- 1. Insertar Datos de Prueba: Registros representativos para las tablas.
-- 2. Verificación de Procedimientos y Triggers: Probar funcionamiento e integridad.
-- 3. Consulta de Vistas: Validar información correcta y optimizada.
-- ============================================================================

-- ============================================================================
-- 1. INSERTAR DATOS DE PRUEBA
-- ============================================================================

-- ============================================================================
-- 1.1 Esquema OPERACIONES - Datos de Prueba
-- ============================================================================

-- Insertar vehículos
INSERT INTO
    operaciones.vehiculos (
        matricula,
        modelo,
        capacidad_pasajeros,
        estado
    )
VALUES (
        'ABC-123',
        'Mercedes Sprinter',
        15,
        'Disponible'
    ),
    (
        'DEF-456',
        'Iveco Daily',
        12,
        'Disponible'
    ),
    (
        'GHI-789',
        'Ford Transit',
        18,
        'Disponible'
    ),
    (
        'JKL-012',
        'Renault Master',
        10,
        'en_Mantenimiento'
    ),
    (
        'MNO-345',
        'Fiat Ducato',
        14,
        'Disponible'
    ),
    (
        'PQR-678',
        'Volkswagen Crafter',
        16,
        'Disponible'
    ),
    (
        'STU-901',
        'Peugeot Boxer',
        13,
        'Disponible'
    ),
    (
        'VWX-234',
        'Citroën Jumper',
        11,
        'Disponible'
    );

-- Insertar rutas
INSERT INTO
    operaciones.rutas (origen, destino, distancia_km)
VALUES (
        'Buenos Aires',
        'Córdoba',
        710.50
    ),
    (
        'Buenos Aires',
        'Rosario',
        300.00
    ),
    ('Córdoba', 'Mendoza', 650.00),
    ('Rosario', 'Santa Fe', 170.00),
    (
        'Buenos Aires',
        'Mar del Plata',
        400.00
    ),
    ('Mendoza', 'San Juan', 165.00),
    (
        'Córdoba',
        'Villa Carlos Paz',
        36.00
    ),
    (
        'Buenos Aires',
        'La Plata',
        56.00
    );

-- Insertar conductores
INSERT INTO
    operaciones.conductores (
        nombre,
        apellido,
        licencia,
        telefono
    )
VALUES (
        'Juan',
        'Pérez',
        'LIC-001',
        '11-2345-6789'
    ),
    (
        'María',
        'González',
        'LIC-002',
        '11-3456-7890'
    ),
    (
        'Carlos',
        'Rodríguez',
        'LIC-003',
        '11-4567-8901'
    ),
    (
        'Ana',
        'Martínez',
        'LIC-004',
        '11-5678-9012'
    ),
    (
        'Luis',
        'López',
        'LIC-005',
        '11-6789-0123'
    ),
    (
        'Sofía',
        'Fernández',
        'LIC-006',
        '11-7890-1234'
    ),
    (
        'Diego',
        'García',
        'LIC-007',
        '11-8901-2345'
    );

-- Insertar asignaciones con diferentes estados
INSERT INTO
    operaciones.asignaciones (
        vehiculo_id,
        conductor_id,
        ruta_id,
        estado_asignacion
    )
VALUES (1, 1, 1, 'Activa'),
    (2, 2, 2, 'Activa'),
    (3, 3, 3, 'Completada'),
    (5, 4, 4, 'Completada'),
    (6, 5, 5, 'Completada'),
    (7, 6, 6, 'Cancelada'),
    (3, 7, 7, 'Completada');

-- ============================================================================
-- 1.2 Esquema ADMINISTRACION - Datos de Prueba
-- ============================================================================

-- Insertar departamentos
INSERT INTO
    administracion.departamentos (nombre, ubicacion)
VALUES ('Recursos Humanos', 'Piso 1'),
    ('Finanzas', 'Piso 2'),
    ('Operaciones', 'Piso 3'),
    ('Mantenimiento', 'Piso 3'),
    ('Planificación', 'Piso 2');

-- Insertar puestos
INSERT INTO
    administracion.puestos (nombre, salario)
VALUES ('Gerente', 150000.00),
    ('Supervisor', 100000.00),
    ('Analista', 80000.00),
    ('Administrativo', 60000.00),
    ('Técnico', 70000.00);

-- Insertar empleados
INSERT INTO
    administracion.empleados (
        nombre,
        apellido,
        departamento_id,
        puesto_id
    )
VALUES ('Pedro', 'Fernández', 1, 1),
    ('Laura', 'Sánchez', 1, 4),
    ('Roberto', 'García', 2, 1),
    ('Sofía', 'Díaz', 2, 3),
    ('Diego', 'Torres', 3, 2),
    ('Valentina', 'Ruiz', 3, 4),
    ('Martín', 'Morales', 4, 5),
    ('Camila', 'Castro', 4, 5),
    ('Javier', 'Vargas', 5, 3),
    ('Carolina', 'Silva', 5, 4);

-- Insertar roles
INSERT INTO
    administracion.roles (nombreRol, descripcion)
VALUES (
        'Administrador',
        'Acceso completo al sistema'
    ),
    (
        'Supervisor',
        'Acceso a operaciones y reportes'
    ),
    (
        'Consulta',
        'Solo lectura de datos'
    );

-- Asignar roles a empleados
INSERT INTO
    administracion.empleados_roles (empleado_id, rol_id)
VALUES (1, 1),
    (3, 1),
    (5, 2),
    (7, 2),
    (2, 3),
    (4, 3);

-- ============================================================================
-- 2. VERIFICACIÓN DE PROCEDIMIENTOS ALMACENADOS
-- ============================================================================

-- ============================================================================
-- 2.1 Procedimiento: asignar_vehiculo_ruta
-- ============================================================================

-- Prueba 1: Asignar vehículo disponible
SELECT operaciones.asignar_vehiculo_ruta (8, 7, 8);

-- Verificar que la asignación se creó
SELECT a.asignacion_id, a.fecha_asignacion, a.estado_asignacion, v.matricula, c.nombre, c.apellido, r.origen, r.destino
FROM operaciones.asignaciones a
    JOIN operaciones.vehiculos v ON a.vehiculo_id = v.vehiculo_id
    JOIN operaciones.conductores c ON a.conductor_id = c.conductor_id
    JOIN operaciones.rutas r ON a.ruta_id = r.ruta_id
WHERE
    a.vehiculo_id = 8
    AND a.estado_asignacion = 'Activa';

-- Verificar que el estado del vehículo cambió a 'Asignado'
SELECT vehiculo_id, matricula, estado
FROM operaciones.vehiculos
WHERE
    vehiculo_id = 8;

-- ============================================================================
-- 2.2 Procedimiento: transferir_empleado_departamento
-- ============================================================================

-- Prueba 1: Transferir empleado entre departamentos
SELECT administracion.transferir_empleado_departamento (2, 3);

-- Verificar la transferencia
SELECT e.empleado_id, e.nombre, e.apellido, d.nombre AS departamento_actual
FROM administracion.empleados e
    JOIN administracion.departamentos d ON e.departamento_id = d.departamento_id
WHERE
    e.empleado_id = 2;

-- Verificar el registro en el historial
SELECT
    h.historial_id,
    h.empleado_id,
    d1.nombre AS dept_anterior,
    d2.nombre AS dept_nuevo,
    h.fecha_transferencia,
    h.realizado_por
FROM administracion.historial_transferencias h
    JOIN administracion.departamentos d1 ON h.departamento_anterior = d1.departamento_id
    JOIN administracion.departamentos d2 ON h.departamento_nuevo = d2.departamento_id
WHERE
    h.empleado_id = 2;

-- ============================================================================
-- 3. VERIFICACIÓN DE TRIGGERS
-- ============================================================================

-- ============================================================================
-- 3.1 Trigger: actualizar_estado_vehiculo_asignado
-- ============================================================================

-- Crear una nueva asignación
INSERT INTO
    operaciones.asignaciones (
        vehiculo_id,
        conductor_id,
        ruta_id,
        estado_asignacion
    )
VALUES (3, 1, 2, 'Activa');

-- Verificar que el estado del vehículo cambió a 'Asignado'
SELECT
    vehiculo_id,
    matricula,
    modelo,
    estado
FROM operaciones.vehiculos
WHERE
    vehiculo_id = 3;

-- ============================================================================
-- 3.2 Trigger: actualizar_estado_vehiculo_liberado
-- ============================================================================

-- Completar la asignación recién creada
UPDATE operaciones.asignaciones
SET
    estado_asignacion = 'Completada'
WHERE
    vehiculo_id = 3
    AND estado_asignacion = 'Activa';

-- Verificar que el estado del vehículo cambió a 'Disponible'
SELECT
    vehiculo_id,
    matricula,
    modelo,
    estado
FROM operaciones.vehiculos
WHERE
    vehiculo_id = 3;

-- ============================================================================
-- 3.3 Trigger: prevenir_eliminacion_conductor
-- ============================================================================

-- Verificar que el conductor 1 tiene asignaciones activas
SELECT *
FROM operaciones.asignaciones
WHERE
    conductor_id = 1
    AND estado_asignacion = 'Activa';

-- Intentar eliminar el conductor (debería fallar con error)
-- DELETE FROM operaciones.conductores WHERE conductor_id = 1;
-- Resultado esperado: ERROR - No se puede eliminar el conductor

-- ============================================================================
-- 3.4 Trigger: registrar_auditoria_empleado
-- ============================================================================

-- Eliminar un empleado
DELETE FROM administracion.empleados WHERE empleado_id = 10;

-- Verificar que se registró en la auditoría
SELECT *
FROM administracion.auditoria_empleados
WHERE
    empleado_id = 10;

-- ============================================================================
-- 4. VALIDACIÓN DE VISTAS
-- ============================================================================

-- Listar todas las vistas creadas
SELECT
    schemaname,
    viewname,
    viewowner,
    definition
FROM pg_views
WHERE
    schemaname IN (
        'operaciones',
        'administracion'
    )
ORDER BY schemaname, viewname;

-- Listar vistas con sus comentarios
SELECT n.nspname AS schema_name, c.relname AS view_name, d.description
FROM
    pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    LEFT JOIN pg_description d ON d.objoid = c.oid
WHERE
    c.relkind = 'v'
    AND n.nspname IN (
        'operaciones',
        'administracion'
    )
ORDER BY n.nspname, c.relname;

-- ============================================================================
-- 4.1 Vista: vista_conductores_asignados
-- ============================================================================

SELECT * FROM operaciones.vista_conductores_asignados;

-- Validación: Verificar cantidad
SELECT (
        SELECT COUNT(*)
        FROM operaciones.vista_conductores_asignados
    ) AS total_vista,
    (
        SELECT COUNT(*)
        FROM operaciones.asignaciones
        WHERE
            estado_asignacion = 'Activa'
    ) AS total_real,
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM operaciones.vista_conductores_asignados
        ) = (
            SELECT COUNT(*)
            FROM operaciones.asignaciones
            WHERE
                estado_asignacion = 'Activa'
        ) THEN '✓ CORRECTO'
        ELSE '✗ ERROR'
    END AS validacion;

-- ============================================================================
-- 4.2 Vista: vista_conductores_disponibles
-- ============================================================================

SELECT * FROM operaciones.vista_conductores_disponibles;

-- Validación: No debe incluir conductores con asignaciones activas
SELECT
    COUNT(*) AS conductores_invalidos,
    CASE
        WHEN COUNT(*) = 0 THEN '✓ CORRECTO - No hay conductores con asignaciones activas'
        ELSE '✗ ERROR - Hay conductores con asignaciones activas'
    END AS validacion
FROM operaciones.vista_conductores_disponibles
WHERE
    conductor_id IN (
        SELECT conductor_id
        FROM operaciones.asignaciones
        WHERE
            estado_asignacion = 'Activa'
    );

-- ============================================================================
-- 4.3 Vista: vista_vehiculos_por_estado
-- ============================================================================

SELECT * FROM operaciones.vista_vehiculos_por_estado;

-- Validación: La suma debe ser igual al total de vehículos
SELECT (
        SELECT SUM(cantidad)
        FROM operaciones.vista_vehiculos_por_estado
    ) AS total_vista,
    (
        SELECT COUNT(*)
        FROM operaciones.vehiculos
    ) AS total_real,
    CASE
        WHEN (
            SELECT SUM(cantidad)
            FROM operaciones.vista_vehiculos_por_estado
        ) = (
            SELECT COUNT(*)
            FROM operaciones.vehiculos
        ) THEN '✓ CORRECTO'
        ELSE '✗ ERROR'
    END AS validacion;

-- Validación: Los porcentajes deben sumar aproximadamente 100
SELECT
    SUM(porcentaje) AS suma_porcentajes,
    CASE
        WHEN SUM(porcentaje) BETWEEN 99.99 AND 100.01  THEN '✓ CORRECTO'
        ELSE '✗ ERROR'
    END AS validacion
FROM operaciones.vista_vehiculos_por_estado;

-- ============================================================================
-- 4.4 Vista: vista_vehiculos_disponibles
-- ============================================================================

SELECT * FROM operaciones.vista_vehiculos_disponibles;

-- Validación: Solo debe incluir vehículos disponibles
SELECT (
        SELECT COUNT(*)
        FROM operaciones.vista_vehiculos_disponibles
    ) AS total_vista,
    (
        SELECT COUNT(*)
        FROM operaciones.vehiculos
        WHERE
            estado = 'Disponible'
    ) AS total_real,
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM operaciones.vista_vehiculos_disponibles
        ) = (
            SELECT COUNT(*)
            FROM operaciones.vehiculos
            WHERE
                estado = 'Disponible'
        ) THEN '✓ CORRECTO'
        ELSE '✗ ERROR'
    END AS validacion;

-- ============================================================================
-- 4.5 Vista: vista_historial_asignaciones
-- ============================================================================

SELECT *
FROM operaciones.vista_historial_asignaciones
ORDER BY fecha_asignacion DESC;

-- Validación: Debe incluir todas las asignaciones
SELECT (
        SELECT COUNT(*)
        FROM operaciones.vista_historial_asignaciones
    ) AS total_vista,
    (
        SELECT COUNT(*)
        FROM operaciones.asignaciones
    ) AS total_real,
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM operaciones.vista_historial_asignaciones
        ) = (
            SELECT COUNT(*)
            FROM operaciones.asignaciones
        ) THEN '✓ CORRECTO'
        ELSE '✗ ERROR'
    END AS validacion;

-- ============================================================================
-- 4.6 Vista: vista_ranking_conductores
-- ============================================================================

SELECT * FROM operaciones.vista_ranking_conductores;

-- Validación: Verificar que los km son correctos
SELECT
    c.conductor_id,
    c.nombre,
    c.apellido,
    COALESCE(
        SUM(
            CASE
                WHEN a.estado_asignacion = 'Completada' THEN r.distancia_km
                ELSE 0
            END
        ),
        0
    ) AS km_calculados,
    v.km_totales_completados AS km_vista,
    CASE
        WHEN COALESCE(
            SUM(
                CASE
                    WHEN a.estado_asignacion = 'Completada' THEN r.distancia_km
                    ELSE 0
                END
            ),
            0
        ) = v.km_totales_completados THEN '✓'
        ELSE '✗'
    END AS validacion
FROM operaciones.conductores c
    LEFT JOIN operaciones.asignaciones a ON c.conductor_id = a.conductor_id
    LEFT JOIN operaciones.rutas r ON a.ruta_id = r.ruta_id
    LEFT JOIN operaciones.vista_ranking_conductores v ON c.conductor_id = v.conductor_id
GROUP BY
    c.conductor_id,
    c.nombre,
    c.apellido,
    v.km_totales_completados;

-- ============================================================================
-- 4.7 Vista: vista_empleados_por_departamento
-- ============================================================================

SELECT * FROM administracion.vista_empleados_por_departamento;

-- Validación: Todos los empleados deben estar incluidos
SELECT (
        SELECT COUNT(*)
        FROM administracion.vista_empleados_por_departamento
    ) AS total_vista,
    (
        SELECT COUNT(*)
        FROM administracion.empleados
    ) AS total_real,
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM administracion.vista_empleados_por_departamento
        ) = (
            SELECT COUNT(*)
            FROM administracion.empleados
        ) THEN '✓ CORRECTO'
        ELSE '✗ ERROR'
    END AS validacion;

-- ============================================================================
-- 4.8 Vista: vista_resumen_departamentos
-- ============================================================================

SELECT * FROM administracion.vista_resumen_departamentos;

-- Validación: La suma de empleados debe coincidir
SELECT (
        SELECT SUM(cantidad_empleados)
        FROM administracion.vista_resumen_departamentos
    ) AS total_vista,
    (
        SELECT COUNT(*)
        FROM administracion.empleados
    ) AS total_real,
    CASE
        WHEN (
            SELECT SUM(cantidad_empleados)
            FROM administracion.vista_resumen_departamentos
        ) = (
            SELECT COUNT(*)
            FROM administracion.empleados
        ) THEN '✓ CORRECTO'
        ELSE '✗ ERROR'
    END AS validacion;

-- ============================================================================
-- 5. VALIDACIÓN DE VISTAS MATERIALIZADAS
-- ============================================================================

-- Refrescar las vistas materializadas
REFRESH MATERIALIZED VIEW administracion.mv_empleados_por_departamento;

REFRESH MATERIALIZED VIEW administracion.mv_salarios_por_puesto;



-- Listar todas las vistas materializadas creadas
SELECT
    schemaname,
    matviewname,
    matviewowner,
    ispopulated
FROM pg_matviews
WHERE
    schemaname = 'administracion'
ORDER BY matviewname;

-- Verificar índices creados en las vistas materializadas
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE
    schemaname = 'administracion'
    AND tablename LIKE 'mv_%'
ORDER BY tablename, indexname;
-- ============================================================================
-- 5.1 Vista Materializada: mv_empleados_por_departamento
-- ============================================================================

SELECT * FROM administracion.mv_empleados_por_departamento;

-- Validación: Comparar con datos reales
SELECT
    mv.departamento_id,
    mv.cantidad_empleados AS cantidad_mv,
    COUNT(e.empleado_id) AS cantidad_real,
    CASE
        WHEN mv.cantidad_empleados = COUNT(e.empleado_id) THEN '✓ CORRECTO'
        ELSE '✗ ERROR'
    END AS validacion
FROM administracion.mv_empleados_por_departamento mv
    LEFT JOIN administracion.empleados e ON mv.departamento_id = e.departamento_id
GROUP BY
    mv.departamento_id,
    mv.cantidad_empleados
ORDER BY mv.departamento_id;




-- ============================================================================
-- 5.2 Vista Materializada: mv_salarios_por_puesto
-- ============================================================================

SELECT * FROM administracion.mv_salarios_por_puesto;

-- Validación: Comparar con datos reales
SELECT
    mv.puesto_id,
    mv.cantidad_empleados AS cantidad_mv,
    COUNT(e.empleado_id) AS cantidad_real,
    mv.masa_salarial_total AS salario_mv,
    COALESCE(SUM(p.salario), 0) AS salario_real,
    CASE
        WHEN mv.cantidad_empleados = COUNT(e.empleado_id)
        AND mv.masa_salarial_total = COALESCE(SUM(p.salario), 0) THEN '✓ CORRECTO'
        ELSE '✗ ERROR'
    END AS validacion
FROM administracion.mv_salarios_por_puesto mv
    LEFT JOIN administracion.empleados e ON mv.puesto_id = e.puesto_id
    LEFT JOIN administracion.puestos p ON e.puesto_id = p.puesto_id
GROUP BY
    mv.puesto_id,
    mv.cantidad_empleados,
    mv.masa_salarial_total
ORDER BY mv.puesto_id;

-- ============================================================================
-- 6. RESUMEN FINAL DE VALIDACIONES
-- ============================================================================

-- Resumen de datos insertados
SELECT 'RESUMEN DE DATOS INSERTADOS' AS seccion;

SELECT 'Vehículos' AS entidad, COUNT(*) AS cantidad
FROM operaciones.vehiculos
UNION ALL
SELECT 'Rutas', COUNT(*)
FROM operaciones.rutas
UNION ALL
SELECT 'Conductores', COUNT(*)
FROM operaciones.conductores
UNION ALL
SELECT 'Asignaciones', COUNT(*)
FROM operaciones.asignaciones
UNION ALL
SELECT 'Departamentos', COUNT(*)
FROM administracion.departamentos
UNION ALL
SELECT 'Puestos', COUNT(*)
FROM administracion.puestos
UNION ALL
SELECT 'Empleados', COUNT(*)
FROM administracion.empleados
UNION ALL
SELECT 'Roles', COUNT(*)
FROM administracion.roles;

-- Resumen de asignaciones por estado
SELECT 'ASIGNACIONES POR ESTADO' AS seccion;

SELECT estado_asignacion, COUNT(*) AS cantidad
FROM operaciones.asignaciones
GROUP BY
    estado_asignacion
ORDER BY cantidad DESC;

-- Resumen de vehículos por estado
SELECT 'VEHÍCULOS POR ESTADO' AS seccion;

SELECT estado, COUNT(*) AS cantidad
FROM operaciones.vehiculos
GROUP BY
    estado
ORDER BY cantidad DESC;

-- Resumen de empleados por departamento
SELECT 'EMPLEADOS POR DEPARTAMENTO' AS seccion;

SELECT d.nombre AS departamento, COUNT(e.empleado_id) AS cantidad
FROM administracion.departamentos d
    LEFT JOIN administracion.empleados e ON d.departamento_id = e.departamento_id
GROUP BY
    d.departamento_id,
    d.nombre
ORDER BY cantidad DESC;