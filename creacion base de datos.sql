-- Active: 1747403850087@@127.0.0.1@5432@transporte_db
-- creacion base de datos transporte_db
CREATE DATABASE transporte_db;
-- creacion de los esquemas y tablas solicitados
CREATE SCHEMA operaciones;

CREATE TABLE operaciones.vehiculos(
    vehiculo_id SERIAL PRIMARY KEY,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    modelo VARCHAR(150) NOT NULL,
    capacidad_pasajeros INT NOT NULL,
    estado VARCHAR(50) NOT NULL CHECK (estado IN ('Disponible', 'en_Mantenimiento', 'Asignado'))
);
