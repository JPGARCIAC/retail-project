-- ============================================================================
-- PROYECTO: Retail Project - Pre-entrega Módulo 4
-- DESCRIPCIÓN: Consultas multicapa para análisis de negocio (JOINs, GROUP BY, HAVING)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PREPARACIÓN / ACTUALIZACIÓN DEL ESQUEMA BASE
-- (Creación de tabla categorías y datos adicionales para soportar las consultas)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE
);

-- Migración/Actualización simple en caso de que productos usara VARCHAR antes
ALTER TABLE productos ADD COLUMN IF NOT EXISTS categoria_id INT;

-- Carga inicial de categorías de prueba
INSERT INTO categorias (nombre_categoria) VALUES 
('Electrónica'), 
('Hogar'), 
('Deportes') 
ON CONFLICT (nombre_categoria) DO NOTHING;

-- Asociamos los productos a las categorías
UPDATE productos SET categoria_id = 1 WHERE categoria = 'Electrónica' OR categoria_id IS NULL;
UPDATE productos SET categoria_id = 2 WHERE categoria = 'Hogar';

-- Clave foránea en productos hacia categorías
ALTER TABLE productos DROP CONSTRAINT IF EXISTS fk_categoria;
ALTER TABLE productos ADD CONSTRAINT fk_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id);

-- Cliente de prueba que NO ha realizado compras (para probar la Consulta 2)
INSERT INTO clientes (nombre, email, edad) VALUES 
('Mariana Torres', 'mariana.torres@example.com', 31)
ON CONFLICT (email) DO NOTHING;


-- ============================================================================
-- 1. RENTABILIDAD POR CATEGORÍA
-- ============================================================================
/*
 PROBLEMA DE NEGOCIO:
 La gerencia comercial necesita identificar qué categorías de productos están generando 
 mayores ingresos y volumen de ventas para enfocar las inversiones de inventario. 
 Se requiere filtrar únicamente aquellas categorías con ingresos totales superiores a $500.

 LÓGICA APLICADA:
 Unimos 3 tablas (ventas -> productos -> categorias) mediante INNER JOINs.
 Agrupamos por el nombre de la categoría y calculamos el total de unidades vendidas (SUM) 
 y el ingreso total producido (SUM de cantidad * precio unitario). 
 Se utiliza HAVING para filtrar sobre el agregador SUM(v.cantidad * p.precio) > 500.
*/

SELECT 
    cat.nombre_categoria AS categoria,
    COALESCE(SUM(v.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(v.cantidad * p.precio), 0) AS ingreso_total
FROM ventas v
INNER JOIN productos p ON v.producto_id = p.producto_id
INNER JOIN categorias cat ON p.categoria_id = cat.categoria_id
GROUP BY cat.categoria_id, cat.nombre_categoria
HAVING SUM(v.cantidad * p.precio) > 500.00
ORDER BY ingreso_total DESC;


-- ============================================================================
-- 2. CLIENTES ESCURRIDIZOS (CLIENTES SIN COMPRAS)
-- ============================================================================
/*
 PROBLEMA DE NEGOCIO:
 El equipo de Marketing busca ejecutar una campaña de reactivación dirigida a usuarios 
 registrados en la plataforma que nunca han realizado una compra, para ofrecerles un cupón 
 de primer pedido.

 LÓGICA APLICADA:
 Realizamos un LEFT JOIN desde la tabla 'clientes' hacia 'ventas'. Esto mantiene a todos
 los clientes registrados. Al filtrar en la cláusula WHERE por `v.venta_id IS NULL`, 
 nos quedamos únicamente con aquellos clientes que no tienen registros asociados en la 
 tabla de ventas. Se usa COALESCE para manejar de forma explícita valores nulos en el reporte.
*/

SELECT 
    c.cliente_id,
    c.nombre AS cliente_nombre,
    c.email,
    COALESCE(COUNT(v.venta_id), 0) AS total_compras_realizadas
FROM clientes c
LEFT JOIN ventas v ON c.cliente_id = v.cliente_id
WHERE v.venta_id IS NULL
GROUP BY c.cliente_id, c.nombre, c.email;


-- ============================================================================
-- 3. TOP RANKING DE COMPRAS POR CLIENTE
-- ============================================================================
/*
 PROBLEMA DE NEGOCIO:
 El departamento de CRM necesita personalizar el programa de fidelización analizando 
 el producto preferido (el más comprado) de cada cliente activo y conocer la fecha de su 
 última interacción con la marca.

 LÓGICA APLICADA:
 Unimos las tablas clientes, ventas y productos. Agrupamos por cliente y por producto 
 para obtener el total de veces que cada cliente compró dicho producto y su última fecha
 de compra (MAX).
*/

SELECT DISTINCT ON (c.cliente_id)
    c.cliente_id,
    c.nombre AS cliente_nombre,
    p.nombre AS producto_mas_comprado,
    SUM(v.cantidad) AS total_unidades_compradas,
    MAX(v.fecha) AS fecha_ultima_transaccion
FROM clientes c
INNER JOIN ventas v ON c.cliente_id = v.cliente_id
INNER JOIN productos p ON v.producto_id = p.producto_id
GROUP BY c.cliente_id, c.nombre, p.producto_id, p.nombre
ORDER BY c.cliente_id, total_unidades_compradas DESC, fecha_ultima_transaccion DESC;