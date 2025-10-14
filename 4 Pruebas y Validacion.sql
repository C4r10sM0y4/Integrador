-- 1. Insertar Datos de Prueba: Población inicial de las tablas con datos representativos para realizar pruebas.
-- 2. Probar Procedimientos y Triggers: Ejecutar procedimientos almacenados y verificar que los triggers funcionen correctamente,
-- manteniendo la integridad de los datos.
-- 3. Consultar Vistas y Vistas Materializadas: Realizar consultas sobre las vistas creadas para asegurarse de que proporcionan la
-- información correcta y optimizada.

-- ============================================================================
-- 1. INSERTAR DATOS DE PRUEBA
-- ============================================================================
-- Insertar datos de prueba en la tabla "clientes"
INSERT INTO
    operaciones.clientes (nombre, email, telefono)
VALUES (
        'Juan Perez',
        'juan.perez@example.com',
        '555-1234'
    ),
    (
        'Maria Gomez',
        'maria.gomez@example.com',
        '555-5678'
    ),
    (
        'Carlos Sanchez',
        'carlos.sanchez@example.com',
        '555-8765'
    );

-- Insertar datos de prueba en la tabla "productos"
INSERT INTO
    operaciones.productos (nombre, descripcion, precio)
VALUES (
        'Producto A',
        'Descripción del Producto A',
        100.00
    ),
    (
        'Producto B',
        'Descripción del Producto B',
        150.00
    ),
    (
        'Producto C',
        'Descripción del Producto C',
        200.00
    );

-- Insertar datos de prueba en la tabla "ordenes"
INSERT INTO
    operaciones.ordenes (
        cliente_id,
        producto_id,
        cantidad,
        fecha_orden
    )
VALUES (1, 1, 2, '2024-01-15'),
    (2, 3, 1, '2024-01-16'),
    (3, 2, 5, '2024-01-17');

-- ============================================================================
-- 2. PROBAR PROCEDIMIENTOS Y TRIGGERS
-- Probar el procedimiento almacenado "actualizar_precio_producto"
CALL operaciones.actualizar_precio_producto (1, 120.00);
-- Actualiza el precio del Producto A a 120.00
CALL operaciones.actualizar_precio_producto (2, 160.00);
-- Actualiza el precio del Producto B a 160.00
CALL operaciones.actualizar_precio_producto (3, 210.00);
-- Actualiza el precio del Producto C a 210.00
-- Verificar que los precios se hayan actualizado correctamente
SELECT * FROM operaciones.productos;

-- Probar el trigger "trg_actualizar_stock" insertando una nueva orden
INSERT INTO
    operaciones.ordenes (
        cliente_id,
        producto_id,
        cantidad,
        fecha_orden
    )
VALUES (1, 1, 3, '2024-01-18');
-- Esto debería activar el trigger para actualizar el stock
-- Verificar que el stock se haya actualizado correctamente
SELECT * FROM operaciones.productos WHERE id = 1;
-- Verificar el stock del Producto A
-- ============================================================================
-- 3. CONSULTAR VISTAS Y VISTAS MATERIALIZADAS
-- Consultar la vista "vista_clientes_activos"
SELECT * FROM operaciones.vista_clientes_activos;
-- Consultar la vista materializada "vista_materializada_ordenes_resumen"
SELECT * FROM operaciones.vista_materializada_ordenes_resumen;