-- ============================================================
-- PROYECTO: Retail Project - Pre-entrega
-- DESCRIPCIÓN: Creación de base de datos, tablas con restricciones
--              y carga inicial de datos con transacciones.
-- ============================================================

-- 1. CREACIÓN Y CONEXIÓN A LA BASE DE DATOS
CREATE DATABASE retail_project;

-- Si ejecutas desde la consola psql de PostgreSQL, descomenta la siguiente línea:
-- \c retail_project;

-- 2. DDL: CREACIÓN DE TABLAS CON RESTRICCIONES Y CHECKS

-- Tabla Clientes
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    edad INT CHECK (edad >= 18) -- RESTRICCIÓN CHECK 1: edad del cliente
);

-- Tabla Productos
CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio DECIMAL(10, 2) CHECK (precio > 0), -- RESTRICCIÓN CHECK 2: precio unitario positivo
    stock INT CHECK (stock >= 0) -- RESTRICCIÓN CHECK 3: stock no negativo
);

-- Tabla Ventas (Creada al final por las Foreign Keys)
CREATE TABLE ventas (
    venta_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT CHECK (cantidad > 0), -- RESTRICCIÓN CHECK adicional (opcional pero recomendada)
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Claves Foráneas
    CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    CONSTRAINT fk_producto FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);


-- 3. DML: CARGA INICIAL DE DATOS (TRANSACCIÓN EXPLÍCITA)
BEGIN;

-- Inserts en Clientes (Mínimo 5)
INSERT INTO clientes (nombre, email, edad) VALUES
('Ana Gómez', 'ana.gomez@example.com', 25),
('Carlos López', 'carlos.lopez@example.com', 34),
('María Rodríguez', 'maria.rodriguez@example.com', 29),
('Juan Pérez', 'juan.perez@example.com', 45),
('Laura Martínez', 'laura.martinez@example.com', 22);

-- Inserts en Productos (Mínimo 5)
INSERT INTO productos (nombre, categoria, precio, stock) VALUES
('Laptop Pro 15', 'Electrónica', 1200.00, 15),
('Smartphone X', 'Electrónica', 800.00, 30),
('Silla Ergonomica', 'Hogar', 150.00, 20),
('Cafetera Express', 'Hogar', 90.00, 10),
('Auriculares Bluetooth', 'Electrónica', 60.00, 50);

-- Inserts en Ventas (Mínimo 5)
INSERT INTO ventas (cliente_id, producto_id, cantidad, fecha) VALUES
(1, 2, 1, '2026-08-01 10:30:00'),
(2, 1, 1, '2026-08-02 11:15:00'),
(3, 4, 2, '2026-08-03 14:20:00'),
(4, 3, 1, '2026-08-04 16:45:00'),
(5, 5, 3, '2026-08-05 09:10:00');

COMMIT;


-- 4. MANIPULACIÓN Y MANTENIMIENTO DE DATOS

-- UPDATE masivo: Modifica el precio de una categoría completa de productos usando WHERE
UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Electrónica';

-- DELETE: Elimina un registro específico de prueba usando WHERE
DELETE FROM ventas
WHERE venta_id = 3;