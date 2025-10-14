-- ============================================================================
-- VISTAS - TransExpress
-- ============================================================================
-- Creación de vistas para consultas frecuentes que simplifican el acceso a datos
-- y mejoran el rendimiento de consultas complejas.
-- ============================================================================

-- ============================================================================
-- ESQUEMA OPERACIONES - VISTAS
-- ============================================================================

-- ============================================================================
-- 1. Vista: Lista de conductores con sus asignaciones activas
-- ============================================================================
-- Muestra información completa de conductores que tienen asignaciones activas,
-- incluyendo detalles del vehículo y la ruta asignada
-- ============================================================================
CREATE OR REPLACE VIEW operaciones.vista_conductores_asignados AS
SELECT c.conductor_id, c.nombre, c.apellido, c.licencia, c.telefono, a.asignacion_id, a.fecha_asignacion, v.vehiculo_id, v.matricula, v.modelo, v.capacidad_pasajeros, r.ruta_id, r.origen, r.destino, r.distancia_km
FROM operaciones.conductores c
    INNER JOIN operaciones.asignaciones a ON c.conductor_id = a.conductor_id
    INNER JOIN operaciones.vehiculos v ON a.vehiculo_id = v.vehiculo_id
    INNER JOIN operaciones.rutas r ON a.ruta_id = r.ruta_id
WHERE
    a.estado_asignacion = 'Activa';

COMMENT ON VIEW operaciones.vista_conductores_asignados IS 'Lista de conductores con asignaciones activas, incluyendo detalles del vehículo y ruta';

-- ============================================================================
-- 2. Vista: Conductores disponibles (sin asignaciones activas)
-- ============================================================================
-- Muestra conductores que NO tienen asignaciones activas y están disponibles
-- para ser asignados a nuevas rutas
-- ============================================================================
CREATE OR REPLACE VIEW operaciones.vista_conductores_disponibles AS
SELECT
    c.conductor_id,
    c.nombre,
    c.apellido,
    c.licencia,
    c.telefono,
    COUNT(a.asignacion_id) AS total_asignaciones_historicas,
    MAX(a.fecha_asignacion) AS ultima_asignacion
FROM operaciones.conductores c
    LEFT JOIN operaciones.asignaciones a ON c.conductor_id = a.conductor_id
WHERE
    NOT EXISTS (
        SELECT 1
        FROM operaciones.asignaciones a2
        WHERE
            a2.conductor_id = c.conductor_id
            AND a2.estado_asignacion = 'Activa'
    )
GROUP BY
    c.conductor_id,
    c.nombre,
    c.apellido,
    c.licencia,
    c.telefono;

COMMENT ON VIEW operaciones.vista_conductores_disponibles IS 'Conductores sin asignaciones activas, disponibles para nuevas rutas';

-- ============================================================================
-- 3. Vista: Cantidad de vehículos por estado
-- ============================================================================
-- Resume la cantidad de vehículos agrupados por su estado operativo
-- ============================================================================
CREATE OR REPLACE VIEW operaciones.vista_vehiculos_por_estado AS
SELECT estado, COUNT(*) AS cantidad, ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*)
            FROM operaciones.vehiculos
        ), 2
    ) AS porcentaje
FROM operaciones.vehiculos
GROUP BY
    estado
ORDER BY cantidad DESC;

COMMENT ON VIEW operaciones.vista_vehiculos_por_estado IS 'Resumen de vehículos agrupados por estado operativo con porcentajes';

-- ============================================================================
-- 4. Vista: Vehículos disponibles para asignación
-- ============================================================================
-- Lista completa de vehículos en estado 'Disponible' con su información
-- ============================================================================
CREATE OR REPLACE VIEW operaciones.vista_vehiculos_disponibles AS
SELECT
    v.vehiculo_id,
    v.matricula,
    v.modelo,
    v.capacidad_pasajeros,
    v.estado,
    COUNT(a.asignacion_id) AS total_asignaciones_historicas,
    MAX(a.fecha_asignacion) AS ultima_asignacion
FROM operaciones.vehiculos v
    LEFT JOIN operaciones.asignaciones a ON v.vehiculo_id = a.vehiculo_id
WHERE
    v.estado = 'Disponible'
GROUP BY
    v.vehiculo_id,
    v.matricula,
    v.modelo,
    v.capacidad_pasajeros,
    v.estado
ORDER BY v.matricula;

COMMENT ON VIEW operaciones.vista_vehiculos_disponibles IS 'Vehículos disponibles para ser asignados a rutas';

-- ============================================================================
-- 5. Vista: Resumen de asignaciones por estado
-- ============================================================================
-- Cuenta las asignaciones agrupadas por estado (Activa, Completada, Cancelada)
-- ============================================================================
CREATE OR REPLACE VIEW operaciones.vista_asignaciones_por_estado AS
SELECT
    estado_asignacion,
    COUNT(*) AS cantidad,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*)
            FROM operaciones.asignaciones
        ),
        2
    ) AS porcentaje
FROM operaciones.asignaciones
GROUP BY
    estado_asignacion
ORDER BY cantidad DESC;

COMMENT ON VIEW operaciones.vista_asignaciones_por_estado IS 'Resumen de asignaciones agrupadas por estado';

-- ============================================================================
-- 6. Vista: Historial completo de asignaciones
-- ============================================================================
-- Muestra todas las asignaciones con información completa de conductor, vehículo y ruta
-- ============================================================================
CREATE OR REPLACE VIEW operaciones.vista_historial_asignaciones AS
SELECT
    a.asignacion_id,
    a.fecha_asignacion,
    a.estado_asignacion,
    c.conductor_id,
    c.nombre || ' ' || c.apellido AS conductor_nombre_completo,
    c.licencia AS conductor_licencia,
    v.vehiculo_id,
    v.matricula AS vehiculo_matricula,
    v.modelo AS vehiculo_modelo,
    v.estado AS vehiculo_estado_actual,
    r.ruta_id,
    r.origen AS ruta_origen,
    r.destino AS ruta_destino,
    r.distancia_km AS ruta_distancia
FROM operaciones.asignaciones a
    INNER JOIN operaciones.conductores c ON a.conductor_id = c.conductor_id
    INNER JOIN operaciones.vehiculos v ON a.vehiculo_id = v.vehiculo_id
    INNER JOIN operaciones.rutas r ON a.ruta_id = r.ruta_id
ORDER BY a.fecha_asignacion DESC;

COMMENT ON VIEW operaciones.vista_historial_asignaciones IS 'Historial completo de todas las asignaciones con detalles de conductor, vehículo y ruta';

-- ============================================================================
-- 7. Vista: Rutas más utilizadas
-- ============================================================================
-- Muestra las rutas ordenadas por cantidad de asignaciones
-- ============================================================================
CREATE OR REPLACE VIEW operaciones.vista_rutas_mas_utilizadas AS
SELECT
    r.ruta_id,
    r.origen,
    r.destino,
    r.distancia_km,
    COUNT(a.asignacion_id) AS total_asignaciones,
    COUNT(
        CASE
            WHEN a.estado_asignacion = 'Completada' THEN 1
        END
    ) AS asignaciones_completadas,
    COUNT(
        CASE
            WHEN a.estado_asignacion = 'Activa' THEN 1
        END
    ) AS asignaciones_activas,
    COUNT(
        CASE
            WHEN a.estado_asignacion = 'Cancelada' THEN 1
        END
    ) AS asignaciones_canceladas
FROM operaciones.rutas r
    LEFT JOIN operaciones.asignaciones a ON r.ruta_id = a.ruta_id
GROUP BY
    r.ruta_id,
    r.origen,
    r.destino,
    r.distancia_km
ORDER BY total_asignaciones DESC;

COMMENT ON VIEW operaciones.vista_rutas_mas_utilizadas IS 'Rutas ordenadas por cantidad de asignaciones con desglose por estado';

-- ============================================================================
-- 8. Vista: Conductores con más asignaciones completadas
-- ============================================================================
-- Ranking de conductores por cantidad de asignaciones completadas
-- ============================================================================
CREATE OR REPLACE VIEW operaciones.vista_ranking_conductores AS
SELECT
    c.conductor_id,
    c.nombre,
    c.apellido,
    c.licencia,
    COUNT(a.asignacion_id) AS total_asignaciones,
    COUNT(
        CASE
            WHEN a.estado_asignacion = 'Completada' THEN 1
        END
    ) AS asignaciones_completadas,
    COUNT(
        CASE
            WHEN a.estado_asignacion = 'Activa' THEN 1
        END
    ) AS asignaciones_activas,
    COUNT(
        CASE
            WHEN a.estado_asignacion = 'Cancelada' THEN 1
        END
    ) AS asignaciones_canceladas,
    COALESCE(
        SUM(
            CASE
                WHEN a.estado_asignacion = 'Completada' THEN r.distancia_km
                ELSE 0
            END
        ),
        0
    ) AS km_totales_completados
FROM operaciones.conductores c
    LEFT JOIN operaciones.asignaciones a ON c.conductor_id = a.conductor_id
    LEFT JOIN operaciones.rutas r ON a.ruta_id = r.ruta_id
GROUP BY
    c.conductor_id,
    c.nombre,
    c.apellido,
    c.licencia
ORDER BY
    asignaciones_completadas DESC,
    km_totales_completados DESC;

COMMENT ON VIEW operaciones.vista_ranking_conductores IS 'Ranking de conductores por asignaciones completadas y kilómetros recorridos';

-- ============================================================================
-- ESQUEMA ADMINISTRACION - VISTAS
-- ============================================================================

-- ============================================================================
-- 9. Vista: Empleados por departamento
-- ============================================================================
-- Lista empleados con información de su departamento y puesto
-- ============================================================================
CREATE OR REPLACE VIEW administracion.vista_empleados_por_departamento AS
SELECT
    e.empleado_id,
    e.nombre,
    e.apellido,
    d.departamento_id,
    d.nombre AS departamento_nombre,
    d.ubicacion AS departamento_ubicacion,
    p.puesto_id,
    p.nombre AS puesto_nombre,
    p.salario AS puesto_salario
FROM administracion.empleados e
    INNER JOIN administracion.departamentos d ON e.departamento_id = d.departamento_id
    INNER JOIN administracion.puestos p ON e.puesto_id = p.puesto_id
ORDER BY d.nombre, e.apellido, e.nombre;

COMMENT ON VIEW administracion.vista_empleados_por_departamento IS 'Lista de empleados con información completa de departamento y puesto';

-- ============================================================================
-- 10. Vista: Cantidad de empleados por departamento
-- ============================================================================
-- Resume la cantidad de empleados agrupados por departamento
-- ============================================================================
CREATE OR REPLACE VIEW administracion.vista_resumen_departamentos AS
SELECT
    d.departamento_id,
    d.nombre AS departamento_nombre,
    d.ubicacion,
    COUNT(e.empleado_id) AS cantidad_empleados,
    COALESCE(AVG(p.salario), 0) AS salario_promedio,
    COALESCE(SUM(p.salario), 0) AS masa_salarial_total
FROM administracion.departamentos d
    LEFT JOIN administracion.empleados e ON d.departamento_id = e.departamento_id
    LEFT JOIN administracion.puestos p ON e.puesto_id = p.puesto_id
GROUP BY
    d.departamento_id,
    d.nombre,
    d.ubicacion
ORDER BY cantidad_empleados DESC;

COMMENT ON VIEW administracion.vista_resumen_departamentos IS 'Resumen de departamentos con cantidad de empleados y estadísticas salariales';

-- ============================================================================
-- 11. Vista: Empleados por puesto
-- ============================================================================
-- Agrupa empleados por puesto con información salarial
-- ============================================================================
CREATE OR REPLACE VIEW administracion.vista_empleados_por_puesto AS
SELECT
    p.puesto_id,
    p.nombre AS puesto_nombre,
    p.salario AS salario_puesto,
    COUNT(e.empleado_id) AS cantidad_empleados,
    COALESCE(SUM(p.salario), 0) AS masa_salarial_total
FROM administracion.puestos p
    LEFT JOIN administracion.empleados e ON p.puesto_id = e.puesto_id
GROUP BY
    p.puesto_id,
    p.nombre,
    p.salario
ORDER BY cantidad_empleados DESC, p.salario DESC;

COMMENT ON VIEW administracion.vista_empleados_por_puesto IS 'Resumen de empleados agrupados por puesto con información salarial';
