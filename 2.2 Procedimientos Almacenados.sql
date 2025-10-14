-- ============================================================================
-- 1. PROCEDIMIENTO: Asignar vehículo a ruta
-- ============================================================================
-- Vincula un vehículo disponible a un conductor y ruta, y actualiza el estado
-- del vehículo a 'Asignado'
-- ============================================================================
CREATE OR REPLACE FUNCTION operaciones.asignar_vehiculo_ruta(
    p_vehiculo_id INT,
    p_conductor_id INT,
    p_ruta_id INT
) RETURNS INT AS $$
DECLARE
    v_asignacion_id INT;
    v_estado_vehiculo VARCHAR(50);
BEGIN
    -- Validar que el vehículo existe y obtener su estado
    SELECT estado INTO v_estado_vehiculo
    FROM operaciones.vehiculos
    WHERE vehiculo_id = p_vehiculo_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El vehículo con ID % no existe', p_vehiculo_id;
    END IF;
    
    -- Validar que el vehículo esté disponible
    IF v_estado_vehiculo != 'Disponible' THEN
        RAISE EXCEPTION 'El vehículo % no está disponible (estado actual: %)', 
                        p_vehiculo_id, v_estado_vehiculo;
    END IF;
    
    -- Validar que el conductor existe
    IF NOT EXISTS (SELECT 1 FROM operaciones.conductores WHERE conductor_id = p_conductor_id) THEN
        RAISE EXCEPTION 'El conductor con ID % no existe', p_conductor_id;
    END IF;
    
    -- Validar que la ruta existe
    IF NOT EXISTS (SELECT 1 FROM operaciones.rutas WHERE ruta_id = p_ruta_id) THEN
        RAISE EXCEPTION 'La ruta con ID % no existe', p_ruta_id;
    END IF;
    
    -- Validar que el conductor no tenga asignaciones activas
    IF EXISTS (
        SELECT 1 FROM operaciones.asignaciones 
        WHERE conductor_id = p_conductor_id 
        AND estado_asignacion = 'Activa'
    ) THEN
        RAISE EXCEPTION 'El conductor % ya tiene una asignación activa', p_conductor_id;
    END IF;
    
    -- Crear la asignación (el trigger actualizará el estado del vehículo automáticamente)
    INSERT INTO operaciones.asignaciones (
        vehiculo_id, conductor_id, ruta_id, estado_asignacion
    )
    VALUES (
        p_vehiculo_id, p_conductor_id, p_ruta_id, 'Activa'
    )
    RETURNING asignacion_id INTO v_asignacion_id;
    
    RAISE NOTICE 'Asignación creada exitosamente: ID %', v_asignacion_id;
    
    RETURN v_asignacion_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION operaciones.asignar_vehiculo_ruta (INT, INT, INT) IS 'Vincula un vehículo disponible a un conductor y ruta, y actualiza el estado del vehículo. Retorna el ID de la asignación.';

-- ============================================================================
-- 2. PROCEDIMIENTO: Transferir empleado entre departamentos
-- ============================================================================
-- Cambia el departamento de un empleado y registra el movimiento en un historial
-- ============================================================================

-- Primero crear la tabla de historial si no existe
CREATE TABLE IF NOT EXISTS administracion.historial_transferencias (
    historial_id SERIAL PRIMARY KEY,
    empleado_id INT NOT NULL,
    departamento_anterior INT NOT NULL,
    departamento_nuevo INT NOT NULL,
    fecha_transferencia TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    realizado_por VARCHAR(100) DEFAULT CURRENT_USER,
    FOREIGN KEY (empleado_id) REFERENCES administracion.empleados (empleado_id),
    FOREIGN KEY (departamento_anterior) REFERENCES administracion.departamentos (departamento_id),
    FOREIGN KEY (departamento_nuevo) REFERENCES administracion.departamentos (departamento_id)
);

CREATE OR REPLACE FUNCTION administracion.transferir_empleado_departamento(
    p_empleado_id INT,
    p_nuevo_departamento_id INT
) RETURNS VOID AS $$
DECLARE
    v_departamento_actual INT;
    v_nombre_empleado VARCHAR(100);
    v_apellido_empleado VARCHAR(100);
BEGIN
    -- Validar que el empleado existe y obtener datos actuales
    SELECT departamento_id, nombre, apellido 
    INTO v_departamento_actual, v_nombre_empleado, v_apellido_empleado
    FROM administracion.empleados
    WHERE empleado_id = p_empleado_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El empleado con ID % no existe', p_empleado_id;
    END IF;
    
    -- Validar que el nuevo departamento existe
    IF NOT EXISTS (
        SELECT 1 FROM administracion.departamentos 
        WHERE departamento_id = p_nuevo_departamento_id
    ) THEN
        RAISE EXCEPTION 'El departamento con ID % no existe', p_nuevo_departamento_id;
    END IF;
    
    -- Validar que no sea el mismo departamento
    IF v_departamento_actual = p_nuevo_departamento_id THEN
        RAISE EXCEPTION 'El empleado % % ya está en el departamento %', 
                        v_nombre_empleado, v_apellido_empleado, p_nuevo_departamento_id;
    END IF;
    
    -- Registrar en el historial ANTES de hacer el cambio
    INSERT INTO administracion.historial_transferencias (
        empleado_id, departamento_anterior, departamento_nuevo
    )
    VALUES (
        p_empleado_id, v_departamento_actual, p_nuevo_departamento_id
    );
    
    -- Realizar la transferencia
    UPDATE administracion.empleados
    SET departamento_id = p_nuevo_departamento_id
    WHERE empleado_id = p_empleado_id;
    
    RAISE NOTICE 'Empleado % % transferido del departamento % al departamento %. Registrado en historial.', 
                 v_nombre_empleado, v_apellido_empleado, 
                 v_departamento_actual, p_nuevo_departamento_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION administracion.transferir_empleado_departamento (INT, INT) IS 'Cambia el departamento de un empleado y registra el movimiento en la tabla historial_transferencias.';

COMMENT ON TABLE administracion.historial_transferencias IS 'Registra el historial de transferencias de empleados entre departamentos.';

-- ============================================================================
-- 3. CONSULTAS DE VERIFICACIÓN
-- ============================================================================

-- Verificar funciones creadas
SELECT
    n.nspname AS schema_name,
    p.proname AS function_name,
    pg_get_function_arguments(p.oid) AS arguments,
    pg_get_function_result(p.oid) AS return_type,
    d.description
FROM
    pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    LEFT JOIN pg_description d ON p.oid = d.objoid
WHERE
    n.nspname IN (
        'operaciones',
        'administracion'
    )
    AND p.prokind = 'f'
    AND p.proname IN (
        'asignar_vehiculo_ruta',
        'transferir_empleado_departamento'
    )
ORDER BY n.nspname, p.proname;

-- Verificar tabla de historial creada
SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE
    table_schema = 'administracion'
    AND table_name = 'historial_transferencias'
ORDER BY ordinal_position;