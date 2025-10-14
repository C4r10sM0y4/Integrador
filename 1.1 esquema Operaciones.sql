CREATE SCHEMA operaciones;

CREATE TABLE operaciones.vehiculos (
    vehiculo_id SERIAL PRIMARY KEY,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    modelo VARCHAR(150) NOT NULL,
    capacidad_pasajeros INT NOT NULL,
    estado VARCHAR(50) NOT NULL CHECK (
        estado IN (
            'Disponible',
            'en_Mantenimiento',
            'Asignado'
        )
    )
);

CREATE TABLE operaciones.rutas (
    ruta_id SERIAL PRIMARY KEY,
    origen VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    distancia_km DECIMAL(10, 2) NOT NULL CHECK (distancia_km > 0)
);

DROP TABLE IF EXISTS operaciones.conductores CASCADE;
CREATE TABLE operaciones.conductores (
    conductor_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    licencia VARCHAR(50) UNIQUE NOT NULL,
    telefono VARCHAR(15)
);

CREATE TABLE operaciones.asignaciones (
    asignacion_id SERIAL PRIMARY KEY,
    vehiculo_id INT NOT NULL,
    conductor_id INT NOT NULL,
    ruta_id INT NOT NULL,
    fecha_asignacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_asignacion VARCHAR(50) NOT NULL CHECK (
        estado_asignacion IN (
            'Activa',
            'Completada',
            'Cancelada'
        )
    ),
    FOREIGN KEY (vehiculo_id) REFERENCES operaciones.vehiculos (vehiculo_id),
    FOREIGN KEY (conductor_id) REFERENCES operaciones.conductores (conductor_id),
    FOREIGN KEY (ruta_id) REFERENCES operaciones.rutas (ruta_id)
);


-- 1. Eliminar el constraint antiguo
ALTER TABLE operaciones.vehiculos DROP CONSTRAINT IF EXISTS vehiculos_estado_check;

-- 2. Crear el constraint con los valores correctos
ALTER TABLE operaciones.vehiculos 
ADD CONSTRAINT vehiculos_estado_check 
CHECK (estado IN ('Disponible', 'en_Mantenimiento', 'Asignado'));

-- 3. Actualizar registros existentes si los hay
UPDATE operaciones.vehiculos 
SET estado = 'Disponible' 
WHERE LOWER(estado) = 'disponible';

UPDATE operaciones.vehiculos 
SET estado = 'Asignado' 
WHERE LOWER(estado) = 'asignado';

-- 4. Verificar que funcionó
SELECT pg_get_constraintdef(oid) 
FROM pg_constraint 
WHERE conname = 'vehiculos_estado_check';