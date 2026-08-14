# Proyecto Retail - Base de Datos (`retail_project`)

Este repositorio contiene la pre-entrega del esquema base para la base de datos `retail_project` en PostgreSQL.

## 📁 Estructura del Repositorio
* `script_retail.sql`: Contiene las sentencias DDL (creación de base de datos, tablas y restricciones) y DML (inserción de datos con transacción, actualización y eliminación).

## 🛠️ Requisitos
* PostgreSQL (v12 o superior)
* Cliente SQL como pgAdmin, DBeaver o la consola `psql`.

## 🚀 Instrucciones de Ejecución

1. Clonar el repositorio o descargar el archivo `script_retail.sql`.
2. Conectarse a la instancia de PostgreSQL.
3. Ejecutar el script SQL:
   - **Desde la terminal `psql`:**
     ```bash
     psql -U tu_usuario -f script_retail.sql
     ```
   - **Desde pgAdmin / DBeaver:**
     Abrir una ventana de consultas (Query Tool), copiar el contenido de `script_retail.sql` y ejecutar todo el script.

## 📋 Características Implementadas
- **Tablas:** `clientes`, `productos` y `ventas`.
- **Restricciones Integradas:**
  - Claves Primarias (`PRIMARY KEY`) en las 3 tablas.
  - Claves Foráneas (`FOREIGN KEY`) en `ventas` apuntando a `clientes` y `productos`.
  - 3 restricciones `CHECK` (edad del cliente $\ge 18$, precio de producto $> 0$, stock $\ge 0$).
- **Transacción Segura:** Carga inicial encapsulada dentro de un bloque `BEGIN ... COMMIT`.
- **Mantenimiento:** Sentencias `UPDATE` y `DELETE` filtradas correctamente con `WHERE`.