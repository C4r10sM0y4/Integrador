CREATE SCHEMA administracion;

CREATE TABLE administracion.departamentos(
    departamento_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(100) NOT NULL
);

CREATE TABLE administracion.puestos(
    puesto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    salario DECIMAL(10, 2) NOT NULL CHECK (salario > 0)
);

CREATE TABLE administracion.empleados(
    empleado_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    puesto_id INT NOT NULL,
    departamento_id INT NOT NULL,
    FOREIGN KEY (puesto_id) REFERENCES administracion.puestos(puesto_id),
    FOREIGN KEY (departamento_id) REFERENCES administracion.departamentos(departamento_id)
);

CREATE TABLE administracion.roles(
    rol_id SERIAL PRIMARY KEY,
    nombreRol VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE administracion.empleados_roles(
    empleado_id INT NOT NULL,
    rol_id INT NOT NULL,
    PRIMARY KEY (empleado_id, rol_id),
    FOREIGN KEY (empleado_id) REFERENCES administracion.empleados(empleado_id),
    FOREIGN KEY (rol_id) REFERENCES administracion.roles(rol_id)
);