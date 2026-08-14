-- ============================================================================
-- PROYECTO: Retail Project - Módulo 5 (Análisis Avanzado con CTEs)
-- ARCHIVO: modulo_5/analisis_ctes.sql
-- DESCRIPCIÓN: Informe de rendimiento regional de ventas utilizando CTEs (WITH)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PREPARACIÓN / ACTUALIZACIÓN DEL ESQUEMA
-- (Creación de tabla regiones y vinculación con ventas para soportar la CTE)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS regiones (
    region_id SERIAL PRIMARY KEY,
    nombre_region VARCHAR(100) NOT NULL UNIQUE
);

-- Agregamos la columna region_id a la tabla ventas si no existe
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS region_id INT;

-- Insertamos regiones de prueba
INSERT INTO regiones (nombre_region) VALUES 
('Norte'), 
('Sur'), 
('Centro'), 
('Este') 
ON CONFLICT (nombre_region) DO NOTHING;

-- Asignamos regiones a las ventas existentes de forma distributiva
UPDATE ventas SET region_id = 1 WHERE region_id IS NULL AND venta_id % 4 = 0;
UPDATE ventas SET region_id = 2 WHERE region_id IS NULL AND venta_id % 4 = 1;
UPDATE ventas SET region_id = 3 WHERE region_id IS NULL AND venta_id % 4 = 2;
UPDATE ventas SET region_id = 4 WHERE region_id IS NULL AND venta_id % 4 = 3;

-- Clave foránea hacia la tabla regiones
ALTER TABLE ventas DROP CONSTRAINT IF EXISTS fk_region;
ALTER TABLE ventas ADD CONSTRAINT fk_region FOREIGN KEY (region_id) REFERENCES regiones(region_id);


-- ============================================================================
-- INFORME DE RENDIMIENTO REGIONAL
-- ============================================================================
/*
 PROBLEMA DE NEGOCIO:
 La dirección ejecutiva requiere un informe estratégico de ventas regionales. 
 El objetivo es identificar las regiones con un desempeño comercial sobresaliente,
 definiendo como "sobresaliente" a aquellas cuyo total de ventas supere el promedio 
 general de ventas históricas.

 ESTRUCTURA TÉCNICA (CTE):
 1. CTE 'ventas_por_region': Realiza la agregación (SUM) uniendo las tablas 
    'ventas' y 'regiones'. Genera el total vendido por cada región con su alias.
 2. Consulta Principal (SELECT final): Filtra mediante una subconsulta en el WHERE 
    aquellas regiones cuyo monto superó el promedio global, y las ordena de mayor a menor.
*/

WITH ventas_por_region AS (
    -- Paso 1: Agregación de ventas por cada región
    SELECT 
        r.region_id,
        r.nombre_region,
        SUM(v.monto) AS total_ventas_region
    FROM regiones r
    INNER JOIN ventas v ON r.region_id = v.region_id
    GROUP BY r.region_id, r.nombre_region
)

-- Paso 2: Consulta final con filtrado sobre la CTE y ordenamiento
SELECT 
    nombre_region,
    total_ventas_region
FROM ventas_por_region
WHERE total_ventas_region > (
    -- Subconsulta simple: Calcula el promedio general del total de ventas
    SELECT AVG(monto) 
    FROM ventas
)
ORDER BY total_ventas_region DESC;
