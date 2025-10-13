CREATE SCHEMA operaciones;

CREATE TABLE operaciones.vehiculos (
    vehiculo_id SERIAL PRIMARY KEY,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    modelo VARCHAR(150) NOT NULL,
    capacidad_pasajeros INT NOT NULL,
    estado VARCHAR(50) NOT NULL CHECK (
        estado IN (
            'disponible',
            'en_mantenimiento',
            'asignado'
        )
    )
);

CREATE TABLE operaciones.rutas (
    ruta_id SERIAL PRIMARY KEY,
    origen VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    distancia_km DECIMAL(10, 2) NOT NULL CHECK (distancia_km > 0)
);

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