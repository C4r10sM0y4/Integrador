---- Mantener la integridad de los datos mediante triggers que actualicen automáticamente
---- el estado de los vehículos al asignarlos, prevengan la eliminación de conductores con
---- asignaciones activas y registren auditorías al eliminar empleados administrativos.
CREATE OR REPLACE FUNCTION actualizar_estado_vehiculo()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.estado := 'Asignado';
    ELSIF TG_OP = 'DELETE' THEN
        OLD.estado := 'Disponible';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_estado_vehiculo
AFTER INSERT OR DELETE ON vehiculos
FOR EACH ROW EXECUTE FUNCTION actualizar_estado_vehiculo();

COMMENT ON TRIGGER trg_actualizar_estado_vehiculo ON vehiculos IS 'Actualiza el estado del vehículo al asignarlo o liberarlo';

CREATE OR REPLACE FUNCTION prevenir_eliminacion_conductor()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM asignaciones WHERE conductor_id = OLD.id AND estado = 'Activo') THEN
        RAISE EXCEPTION 'No se puede eliminar el conductor % porque tiene asignaciones activas', OLD.nombre;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevenir_eliminacion_conductor
BEFORE DELETE ON conductores
FOR EACH ROW EXECUTE FUNCTION prevenir_eliminacion_conductor();

COMMENT ON TRIGGER trg_prevenir_eliminacion_conductor ON conductores IS 'Previene la eliminación de conductores con asignaciones activas';

CREATE OR REPLACE FUNCTION registrar_auditoria_empleado()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria_empleados (empleado_id, accion, fecha)
    VALUES (OLD.id, 'ELIMINACION', NOW());
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_registrar_auditoria_empleado
AFTER DELETE ON empleados_administrativos
FOR EACH ROW EXECUTE FUNCTION registrar_auditoria_empleado();

COMMENT ON TRIGGER trg_registrar_auditoria_empleado ON empleados_administrativos IS 'Registra auditoría al eliminar empleados administrativos';
-- ============================================================================
-- 4. CONSULTAS DE VERIFICACIÓN
-- ============================================================================
-- Verificar triggers creados
SELECT tgname, tgrelid::regclass AS table_name, tgtype
FROM pg_trigger
WHERE tgrelid IN (SELECT oid FROM pg_class WHERE relkind = 'r');
-- Verificar funcionamiento de un trigger específico
-- Ejemplo: Verificar el trigger trg_actualizar_estado_vehiculo
INSERT INTO
    vehiculos (id_vehiculo, modelo, estado)
VALUES (1, 'Camioneta', 'Disponible');

UPDATE vehiculos SET id_conductor = 1 WHERE id_vehiculo = 1;

SELECT * FROM vehiculos WHERE id_vehiculo = 1;

DELETE FROM vehiculos WHERE id_vehiculo = 1;

SELECT * FROM vehiculos WHERE id_vehiculo = 1;
-- Verificar que no se pueda eliminar un conductor con asignaciones activas
DELETE FROM conductores WHERE id = 1;
-- Verificar que se registre una auditoría al eliminar un empleado administrativo
DELETE FROM empleados_administrativos WHERE id = 1;

SELECT * FROM auditoria_empleados WHERE empleado_id = 1;
-- ============================================================================