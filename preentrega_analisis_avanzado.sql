-- ============================================================================
-- PROYECTO: Retail Project - Pre-entrega Módulo 6 / Análisis Avanzado
-- ARCHIVO: preentrega_analisis_avanzado.sql
-- DESCRIPCIÓN: Reporte de rendimiento con CTEs, Window Functions y Lógica Condicional
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PREPARACIÓN / ESTRUCTURA DE TABLAS (Por si ejecutas el script desde cero)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS productos (
    producto_id SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria_id INT REFERENCES categorias(categoria_id)
);

CREATE TABLE IF NOT EXISTS ventas (
    venta_id SERIAL PRIMARY KEY,
    producto_id INT REFERENCES productos(producto_id),
    fecha_venta DATE NOT NULL,
    monto NUMERIC(10, 2) NOT NULL
);

-- Insertar datos de prueba en caso de que la base esté vacía
INSERT INTO categorias (nombre_categoria) VALUES ('Electrónica'), ('Ropa')
ON CONFLICT (nombre_categoria) DO NOTHING;

INSERT INTO productos (nombre_producto, categoria_id) VALUES 
('Laptop', 1), ('Televisor', 1), ('Remera', 2), ('Pantalón', 2)
ON CONFLICT DO NOTHING;

INSERT INTO ventas (producto_id, fecha_venta, monto) VALUES 
(1, '2024-01-15', 1200.00), (2, '2024-01-20', 800.00),
(3, '2024-01-10', 300.00),  (4, '2024-01-25', 150.00),
(1, '2024-02-14', 1500.00), (2, '2024-02-18', 400.00),
(3, '2024-02-05', 600.00),  (4, '2024-02-22', 200.00)
ON CONFLICT DO NOTHING;


-- ============================================================================
-- CONSULTA PRINCIPAL CON CTEs Y WINDOW FUNCTIONS
-- ============================================================================

-- PASO 1: CTE 'ventas_mensuales'
-- Trunca las fechas a nivel mensual y realiza la suma total por mes y categoría.
WITH ventas_mensuales AS (
    SELECT 
        DATE_TRUNC('month', v.fecha_venta)::DATE AS mes,
        c.nombre_categoria,
        SUM(v.monto) AS venta_total
    FROM ventas v
    INNER JOIN productos p ON v.producto_id = p.producto_id
    INNER JOIN categorias c ON p.categoria_id = c.categoria_id
    GROUP BY DATE_TRUNC('month', v.fecha_venta), c.nombre_categoria
),

-- PASO 2: CTE 'metricas_ventana'
-- Aplica Window Functions para calcular Ranking mensual, Acumulado histórico y Promedio por categoría.
metricas_ventana AS (
    SELECT 
        mes,
        nombre_categoria,
        venta_total,
        -- Ranking mensual entre categorías (1 = categoría más vendida de ese mes)
        RANK() OVER (
            PARTITION BY mes 
            ORDER BY venta_total DESC
        ) AS ranking_categoria_mes,
        -- Total Acumulado (Running Total) de la categoría a lo largo del tiempo
        SUM(venta_total) OVER (
            PARTITION BY nombre_categoria 
            ORDER BY mes
        ) AS acumulado_categoria,
        -- Promedio histórico mensual de la categoría para poder comparar en la consulta final
        AVG(venta_total) OVER (
            PARTITION BY nombre_categoria
        ) AS promedio_historico_categoria
    FROM ventas_mensuales
)

-- PASO 3: CONSULTA FINAL
-- Agrega el mensaje condicional comparando la venta del mes contra el promedio histórico de la categoría.
SELECT 
    mes,
    nombre_categoria,
    venta_total,
    ranking_categoria_mes,
    acumulado_categoria,
    -- Evaluación condicional de rendimiento
    CASE 
        WHEN venta_total >= promedio_historico_categoria THEN 'Exitoso'
        ELSE 'Bajo el promedio'
    END AS estado_rendimiento
FROM metricas_ventana
ORDER BY mes ASC, ranking_categoria_mes ASC;
