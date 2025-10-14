---- Mantener la integridad de los datos mediante triggers que actualicen automáticamente
---- el estado de los vehículos al asignarlos, prevengan la eliminación de conductores con
---- asignaciones activas y registren auditorías al eliminar empleados administrativos.

-- ============================================================================
-- 1. TRIGGER: Actualizar estado del vehículo al crear una asignación
-- ============================================================================
CREATE OR REPLACE FUNCTION actualizar_estado_vehiculo_asignado()
RETURNS TRIGGER AS $$
BEGIN
    -- Al insertar una asignación activa, marcar el vehículo como 'Asignado'
    IF NEW.estado_asignacion = 'Activa' THEN
        UPDATE operaciones.vehiculos
        SET estado = 'Asignado'
        WHERE vehiculo_id = NEW.vehiculo_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_actualizar_estado_vehiculo_asignado ON operaciones.asignaciones;

CREATE TRIGGER trg_actualizar_estado_vehiculo_asignado
AFTER INSERT ON operaciones.asignaciones
FOR EACH ROW EXECUTE FUNCTION actualizar_estado_vehiculo_asignado();

COMMENT ON TRIGGER trg_actualizar_estado_vehiculo_asignado ON operaciones.asignaciones IS 'Actualiza el estado del vehículo a asignado cuando se crea una asignación activa';

-- ============================================================================
-- 2. TRIGGER: Actualizar estado del vehículo al completar/cancelar asignación
-- ============================================================================
CREATE OR REPLACE FUNCTION actualizar_estado_vehiculo_liberado()
RETURNS TRIGGER AS $$
BEGIN
    -- Al cambiar el estado de la asignación a Completada o Cancelada, 
    -- verificar si el vehículo tiene otras asignaciones activas
    IF NEW.estado_asignacion IN ('Completada', 'Cancelada') 
       AND OLD.estado_asignacion = 'Activa' THEN
        
        -- Si no hay otras asignaciones activas para ese vehículo, marcarlo como disponible
        IF NOT EXISTS (
            SELECT 1 FROM operaciones.asignaciones 
            WHERE vehiculo_id = NEW.vehiculo_id 
            AND estado_asignacion = 'Activa'
            AND asignacion_id != NEW.asignacion_id
        ) THEN
            UPDATE operaciones.vehiculos
            SET estado = 'Disponible'
            WHERE vehiculo_id = NEW.vehiculo_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_actualizar_estado_vehiculo_liberado ON operaciones.asignaciones;

CREATE TRIGGER trg_actualizar_estado_vehiculo_liberado
AFTER UPDATE ON operaciones.asignaciones
FOR EACH ROW EXECUTE FUNCTION actualizar_estado_vehiculo_liberado();

COMMENT ON TRIGGER trg_actualizar_estado_vehiculo_liberado ON operaciones.asignaciones IS 'Actualiza el estado del vehículo a disponible cuando se completa o cancela una asignación';

-- ============================================================================
-- 3. TRIGGER: Prevenir eliminación de conductores con asignaciones activas
-- ============================================================================
CREATE OR REPLACE FUNCTION prevenir_eliminacion_conductor()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM operaciones.asignaciones 
        WHERE conductor_id = OLD.conductor_id 
        AND estado_asignacion = 'Activa'
    ) THEN
        RAISE EXCEPTION 'No se puede eliminar el conductor % % porque tiene asignaciones activas', 
                        OLD.nombre, OLD.apellido;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevenir_eliminacion_conductor ON operaciones.conductores;

CREATE TRIGGER trg_prevenir_eliminacion_conductor
BEFORE DELETE ON operaciones.conductores
FOR EACH ROW EXECUTE FUNCTION prevenir_eliminacion_conductor();

COMMENT ON TRIGGER trg_prevenir_eliminacion_conductor ON operaciones.conductores IS 'Previene la eliminación de conductores con asignaciones activas';

-- ============================================================================
-- 4. TRIGGER: Registrar auditoría al eliminar empleados administrativos
-- ============================================================================
-- Primero crear la tabla de auditoría si no existe
CREATE TABLE IF NOT EXISTS administracion.auditoria_empleados (
    auditoria_id SERIAL PRIMARY KEY,
    empleado_id INT NOT NULL,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    departamento_id INT,
    puesto_id INT,
    accion VARCHAR(50) NOT NULL,
    fecha_auditoria TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) DEFAULT CURRENT_USER
);

CREATE OR REPLACE FUNCTION registrar_auditoria_empleado()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO administracion.auditoria_empleados (
        empleado_id, nombre, apellido, departamento_id, puesto_id, accion
    )
    VALUES (
        OLD.empleado_id, OLD.nombre, OLD.apellido, 
        OLD.departamento_id, OLD.puesto_id, 'ELIMINACION'
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_registrar_auditoria_empleado ON administracion.empleados;

CREATE TRIGGER trg_registrar_auditoria_empleado
AFTER DELETE ON administracion.empleados
FOR EACH ROW EXECUTE FUNCTION registrar_auditoria_empleado();

COMMENT ON TRIGGER trg_registrar_auditoria_empleado ON administracion.empleados IS 'Registra auditoría al eliminar empleados administrativos';
-- ============================================================================
-- 5. CONSULTAS DE VERIFICACIÓN
-- ============================================================================

-- Verificar triggers creados
SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name,
    proname AS function_name,
    CASE
        WHEN tgtype & 1 = 1 THEN 'ROW'
        ELSE 'STATEMENT'
    END AS trigger_level,
    CASE
        WHEN tgtype & 2 = 2 THEN 'BEFORE'
        WHEN tgtype & 64 = 64 THEN 'INSTEAD OF'
        ELSE 'AFTER'
    END AS trigger_timing,
    CASE
        WHEN tgtype & 4 = 4 THEN 'INSERT'
        WHEN tgtype & 8 = 8 THEN 'DELETE'
        WHEN tgtype & 16 = 16 THEN 'UPDATE'
    END AS trigger_event
FROM pg_trigger t
    JOIN pg_proc p ON t.tgfoid = p.oid
WHERE
    tgrelid IN (
        SELECT oid
        FROM pg_class
        WHERE
            relnamespace IN (
                SELECT oid
                FROM pg_namespace
                WHERE
                    nspname IN (
                        'operaciones',
                        'administracion'
                    )
            )
            AND relkind = 'r'
    )
    AND tgisinternal = false
ORDER BY tgrelid::regclass, tgname;
