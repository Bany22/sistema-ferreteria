-- ============================================================
-- PARCHE BD — Ferretería La Curva
-- Aplica SOLO si ya tienes la BD instalada y ves el error:
-- "Unknown column 'v.monto_pagado'"
--
-- Cómo usar: phpMyAdmin → selecciona sistema_ventas → SQL → ejecutar
-- ============================================================

USE sistema_ventas;

-- 1. Agregar columnas faltantes a la tabla ventas
ALTER TABLE ventas
    ADD COLUMN IF NOT EXISTS monto_pagado      DECIMAL(15,2) DEFAULT 0.00 AFTER total,
    ADD COLUMN IF NOT EXISTS fecha_vencimiento DATE          DEFAULT NULL  AFTER monto_pagado;

-- 2. Inicializar monto_pagado en ventas ya marcadas como pagadas
UPDATE ventas SET monto_pagado = total WHERE estado = 'pagada' AND monto_pagado = 0;

-- 3. Crear tabla de abonos/pagos parciales si no existe
CREATE TABLE IF NOT EXISTS ventas_pagos (
    id         INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    venta_id   INT UNSIGNED     NOT NULL,
    usuario_id INT UNSIGNED     NOT NULL,
    fecha      DATE             NOT NULL,
    monto      DECIMAL(15,2)    NOT NULL,
    tipo_pago  ENUM('contado','transferencia','tarjeta','cheque','otro') DEFAULT 'contado',
    referencia VARCHAR(100)     DEFAULT NULL COMMENT 'No. transferencia, cheque, etc.',
    notas      TEXT,
    activo     TINYINT(1)       DEFAULT 1,
    created_at TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_venta   (venta_id),
    INDEX idx_usuario (usuario_id),
    INDEX idx_fecha   (fecha),
    CONSTRAINT fk_vp_venta   FOREIGN KEY (venta_id)
        REFERENCES ventas   (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_vp_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verificación final
SELECT 'Parche aplicado correctamente' AS resultado;
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'sistema_ventas' AND TABLE_NAME = 'ventas'
  AND COLUMN_NAME IN ('monto_pagado','fecha_vencimiento');
