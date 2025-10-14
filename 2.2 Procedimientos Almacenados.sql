---- Automatizar tareas comunes como la asignación de vehículos a conductores y rutas, y
---- la transferencia de empleados administrativos entre departamentos.

CREATE OR REPLACE FUNCTION asignar_vehiculo_conductor(
    p_id_vehiculo INT,
    p_id_conductor INT
) RETURNS VOID AS $$

BEGIN
    UPDATE vehiculos
    SET id_conductor = p_id_conductor
    WHERE id_vehiculo = p_id_vehiculo;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION asignar_vehiculo_conductor (INT, INT) IS 'Asigna un vehículo a un conductor específico';

CREATE OR REPLACE FUNCTION asignar_ruta_conductor(
    p_id_ruta INT,
    p_id_conductor INT
) RETURNS VOID AS $$

BEGIN
    UPDATE rutas
    SET id_conductor = p_id_conductor
    WHERE id_ruta = p_id_ruta;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION asignar_ruta_conductor (INT, INT) IS 'Asigna una ruta a un conductor específico';

CREATE OR REPLACE FUNCTION transferir_empleado_departamento(
    p_id_empleado INT,
    p_id_departamento INT
) RETURNS VOID AS $$

BEGIN
    UPDATE empleados
    SET id_departamento = p_id_departamento
    WHERE id_empleado = p_id_empleado;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION transferir_empleado_departamento (INT, INT) IS 'Transfiere un empleado a un departamento específico';