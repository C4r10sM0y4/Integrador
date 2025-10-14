-- ============================================================================
-- VISTAS MATERIALIZADAS - TransExpress
-- ============================================================================
-- Vistas materializadas para optimizar consultas agregadas que se consultan
-- frecuentemente pero cuyos datos no cambian constantemente.
-- ============================================================================

-- ============================================================================
-- 1. Vista Materializada: Empleados por departamento
-- ============================================================================
-- Almacena el resumen de empleados agrupados por departamento con estadísticas
-- de cantidad y salarios. Se debe refrescar manualmente cuando hay cambios.
-- ============================================================================
CREATE MATERIALIZED VIEW administracion.mv_empleados_por_departamento AS
SELECT
    d.departamento_id,
    d.nombre AS departamento_nombre,
    d.ubicacion AS departamento_ubicacion,
    COUNT(e.empleado_id) AS cantidad_empleados,
    COALESCE(AVG(p.salario), 0) AS salario_promedio,
    COALESCE(MIN(p.salario), 0) AS salario_minimo,
    COALESCE(MAX(p.salario), 0) AS salario_maximo,
    COALESCE(SUM(p.salario), 0) AS masa_salarial_total
FROM administracion.departamentos d
    LEFT JOIN administracion.empleados e ON d.departamento_id = e.departamento_id
    LEFT JOIN administracion.puestos p ON e.puesto_id = p.puesto_id
GROUP BY
    d.departamento_id,
    d.nombre,
    d.ubicacion;

-- Crear índice para búsquedas rápidas por departamento
CREATE UNIQUE INDEX idx_mv_empleados_dept_id ON administracion.mv_empleados_por_departamento (departamento_id);

COMMENT ON MATERIALIZED VIEW administracion.mv_empleados_por_departamento IS 'Vista materializada con resumen de empleados por departamento y estadísticas salariales';

-- ============================================================================
-- 2. Vista Materializada: Salarios totales por puesto
-- ============================================================================
-- Almacena el resumen de salarios agrupados por puesto con cantidad de empleados
-- y masa salarial total.
-- ============================================================================
CREATE MATERIALIZED VIEW administracion.mv_salarios_por_puesto AS
SELECT
    p.puesto_id,
    p.nombre AS puesto_nombre,
    p.salario AS salario_base,
    COUNT(e.empleado_id) AS cantidad_empleados,
    COALESCE(SUM(p.salario), 0) AS masa_salarial_total,
    ROUND(
        COALESCE(SUM(p.salario), 0) * 100.0 / NULLIF(
            (
                SELECT SUM(
                        p2.salario * (
                            SELECT COUNT(*)
                            FROM administracion.empleados e2
                            WHERE
                                e2.puesto_id = p2.puesto_id
                        )
                    )
                FROM administracion.puestos p2
            ),
            0
        ),
        2
    ) AS porcentaje_masa_salarial
FROM administracion.puestos p
    LEFT JOIN administracion.empleados e ON p.puesto_id = e.puesto_id
GROUP BY
    p.puesto_id,
    p.nombre,
    p.salario;

-- Crear índice para búsquedas rápidas por puesto
CREATE UNIQUE INDEX idx_mv_salarios_puesto_id ON administracion.mv_salarios_por_puesto (puesto_id);

COMMENT ON MATERIALIZED VIEW administracion.mv_salarios_por_puesto IS 'Vista materializada con salarios totales agrupados por puesto y cantidad de empleados';

-- ============================================================================
-- COMANDOS PARA REFRESCAR LAS VISTAS MATERIALIZADAS
-- ============================================================================

-- Refrescar vista de empleados por departamento
-- REFRESH MATERIALIZED VIEW administracion.mv_empleados_por_departamento;

-- Refrescar vista de salarios por puesto
-- REFRESH MATERIALIZED VIEW administracion.mv_salarios_por_puesto;

-- Refrescar ambas vistas concurrentemente (sin bloquear lecturas)
-- REFRESH MATERIALIZED VIEW CONCURRENTLY administracion.mv_empleados_por_departamento;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY administracion.mv_salarios_por_puesto;

-- ============================================================================
-- CONSULTAS DE VERIFICACIÓN
-- ============================================================================

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