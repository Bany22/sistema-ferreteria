-- =========================================================
-- FERRETERÍA LA CURVA — Sistema de Ventas e Inventarios
-- Guatemala | Quetzales (Q) | IVA: 12% compras / 5% ventas
--
-- Optimizado para:
--   XAMPP 8.2.12  |  PHP 8.2  |  MariaDB 10.4.32
--
-- Motor: InnoDB (transacciones, FK, crash recovery)
-- Charset: utf8mb4_unicode_ci (soporte completo Unicode)
-- =========================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '-06:00';

DROP DATABASE IF EXISTS sistema_ventas;
CREATE DATABASE sistema_ventas
    CHARACTER SET  utf8mb4
    COLLATE        utf8mb4_unicode_ci;

USE sistema_ventas;

-- =====================================================
-- TABLAS BASE (sin dependencias)
-- =====================================================

CREATE TABLE roles (
    id          INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(50)      NOT NULL,
    descripcion TEXT,
    permisos    JSON,
    activo      TINYINT(1)       DEFAULT 1,
    created_at  TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categorias (
    id          INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100)     NOT NULL,
    descripcion TEXT,
    activo      TINYINT(1)       DEFAULT 1,
    created_at  TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE proveedores (
    id         INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(150)     NOT NULL,
    empresa    VARCHAR(150)     DEFAULT NULL,
    rfc        VARCHAR(20)      DEFAULT NULL,
    email      VARCHAR(150)     DEFAULT NULL,
    telefono   VARCHAR(20)      DEFAULT NULL,
    direccion  TEXT,
    ciudad     VARCHAR(100)     DEFAULT NULL,
    pais       VARCHAR(100)     DEFAULT 'Guatemala',
    notas      TEXT,
    activo     TINYINT(1)       DEFAULT 1,
    created_at TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_activo (activo),
    INDEX idx_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE clientes (
    id             INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(100)     NOT NULL,
    apellido       VARCHAR(100)     NOT NULL DEFAULT '',
    empresa        VARCHAR(150)     DEFAULT NULL,
    rfc            VARCHAR(20)      DEFAULT NULL,
    email          VARCHAR(150)     DEFAULT NULL,
    telefono       VARCHAR(20)      DEFAULT NULL,
    direccion      TEXT,
    ciudad         VARCHAR(100)     DEFAULT NULL,
    estado         VARCHAR(100)     DEFAULT NULL,
    cp             VARCHAR(20)      DEFAULT NULL,
    pais           VARCHAR(100)     DEFAULT 'Guatemala',
    limite_credito DECIMAL(15,2)    DEFAULT 0.00,
    notas          TEXT,
    activo         TINYINT(1)       DEFAULT 1,
    created_at     TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_activo  (activo),
    INDEX idx_nombre  (nombre, apellido),
    INDEX idx_empresa (empresa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE configuracion (
    id          INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    clave       VARCHAR(100)     NOT NULL,
    valor       TEXT,
    descripcion VARCHAR(255)     DEFAULT NULL,
    UNIQUE KEY uq_clave (clave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- USUARIOS (depende de roles)
-- =====================================================

CREATE TABLE usuarios (
    id           INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100)     NOT NULL,
    apellido     VARCHAR(100)     NOT NULL DEFAULT '',
    email        VARCHAR(150)     NOT NULL,
    username     VARCHAR(50)      NOT NULL,
    password     VARCHAR(255)     NOT NULL,
    rol_id       INT UNSIGNED     NOT NULL DEFAULT 1,
    telefono     VARCHAR(20)      DEFAULT NULL,
    activo       TINYINT(1)       DEFAULT 1,
    ultimo_login TIMESTAMP        NULL DEFAULT NULL,
    created_at   TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_email    (email),
    UNIQUE KEY uq_username (username),
    INDEX idx_rol    (rol_id),
    INDEX idx_activo (activo),
    CONSTRAINT fk_usuarios_rol FOREIGN KEY (rol_id)
        REFERENCES roles (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PRODUCTOS (depende de categorias, proveedores)
-- =====================================================

CREATE TABLE productos (
    id             INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    codigo         VARCHAR(50)      NOT NULL,
    nombre         VARCHAR(200)     NOT NULL,
    descripcion    TEXT,
    categoria_id   INT UNSIGNED     DEFAULT NULL,
    proveedor_id   INT UNSIGNED     DEFAULT NULL,
    tipo_producto  ENUM('producto','camara','kit','servicio') DEFAULT 'producto',
    es_kit         TINYINT(1)       DEFAULT 0,
    precio_costo   DECIMAL(15,2)    NOT NULL DEFAULT 0.00,
    precio_venta   DECIMAL(15,2)    NOT NULL DEFAULT 0.00,
    precio_mayoreo DECIMAL(15,2)    DEFAULT 0.00,
    precio1        DECIMAL(15,2)    DEFAULT 0.00,
    precio2        DECIMAL(15,2)    DEFAULT 0.00,
    iva_porcentaje DECIMAL(5,2)     DEFAULT 5.00,
    unidad_medida  VARCHAR(30)      DEFAULT 'PZA',
    stock_actual   DECIMAL(10,2)    DEFAULT 0.00,
    stock_minimo   DECIMAL(10,2)    DEFAULT 0.00,
    stock_maximo   DECIMAL(10,2)    DEFAULT 0.00,
    seccion_letra  VARCHAR(5)       DEFAULT NULL,
    seccion_numero VARCHAR(10)      DEFAULT NULL,
    activo         TINYINT(1)       DEFAULT 1,
    created_at     TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_codigo  (codigo),
    INDEX idx_categoria   (categoria_id),
    INDEX idx_proveedor   (proveedor_id),
    INDEX idx_activo      (activo),
    INDEX idx_stock       (stock_actual),
    INDEX idx_nombre      (nombre),
    INDEX idx_seccion     (seccion_letra, seccion_numero),
    CONSTRAINT fk_productos_categoria FOREIGN KEY (categoria_id)
        REFERENCES categorias (id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_productos_proveedor FOREIGN KEY (proveedor_id)
        REFERENCES proveedores (id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Specs de cámara
CREATE TABLE productos_camara_specs (
    id              INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    producto_id     INT UNSIGNED   NOT NULL,
    marca_id        INT UNSIGNED   DEFAULT NULL,
    resolucion      VARCHAR(50)    DEFAULT NULL,
    tipo_camara_id  INT UNSIGNED   DEFAULT NULL,
    tiene_audio     TINYINT(1)     DEFAULT 0,
    tiene_altavoz   TINYINT(1)     DEFAULT 0,
    full_color      TINYINT(1)     DEFAULT 0,
    wiz_color       TINYINT(1)     DEFAULT 0,
    ir_metros       INT UNSIGNED   DEFAULT NULL,
    tecnologia      VARCHAR(50)    DEFAULT NULL,
    lente_mm        DECIMAL(5,2)   DEFAULT NULL,
    angulo_vision   VARCHAR(30)    DEFAULT NULL,
    ip_rating       VARCHAR(10)    DEFAULT NULL,
    alimentacion    VARCHAR(50)    DEFAULT NULL,
    compresion      VARCHAR(30)    DEFAULT NULL,
    fps             VARCHAR(20)    DEFAULT NULL,
    extras          TEXT           DEFAULT NULL,
    UNIQUE KEY uq_producto (producto_id),
    CONSTRAINT fk_specs_producto FOREIGN KEY (producto_id)
        REFERENCES productos (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Componentes de kit
CREATE TABLE kit_componentes (
    id            INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    kit_id        INT UNSIGNED  NOT NULL,
    componente_id INT UNSIGNED  NOT NULL,
    cantidad      DECIMAL(10,2) NOT NULL DEFAULT 1,
    notas         VARCHAR(200)  DEFAULT NULL,
    INDEX idx_kit        (kit_id),
    INDEX idx_componente (componente_id),
    CONSTRAINT fk_kit_kit        FOREIGN KEY (kit_id)
        REFERENCES productos (id) ON DELETE CASCADE,
    CONSTRAINT fk_kit_componente FOREIGN KEY (componente_id)
        REFERENCES productos (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Catálogos de cámaras
CREATE TABLE camaras_marcas (
    id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    activo TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE camaras_tipos (
    id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    activo TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE camaras_resoluciones (
    id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)  NOT NULL,
    activo TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE camaras_tecnologias (
    id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)  NOT NULL,
    activo TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- COMPRAS (depende de proveedores, usuarios)
-- =====================================================

CREATE TABLE compras (
    id           INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    folio        VARCHAR(20)      NOT NULL,
    proveedor_id INT UNSIGNED     NOT NULL,
    usuario_id   INT UNSIGNED     NOT NULL,
    fecha        DATE             NOT NULL,
    subtotal     DECIMAL(15,2)    DEFAULT 0.00,
    descuento    DECIMAL(15,2)    DEFAULT 0.00,
    iva          DECIMAL(15,2)    DEFAULT 0.00,
    total        DECIMAL(15,2)    DEFAULT 0.00,
    estado       ENUM('pendiente','recibida','cancelada') DEFAULT 'recibida',
    notas        TEXT,
    activo       TINYINT(1)       DEFAULT 1,
    created_at   TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_folio     (folio),
    INDEX idx_proveedor     (proveedor_id),
    INDEX idx_usuario       (usuario_id),
    INDEX idx_fecha         (fecha),
    INDEX idx_estado        (estado),
    INDEX idx_activo        (activo),
    CONSTRAINT fk_compras_proveedor FOREIGN KEY (proveedor_id)
        REFERENCES proveedores (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_compras_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE compras_detalle (
    id              INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    compra_id       INT UNSIGNED     NOT NULL,
    producto_id     INT UNSIGNED     NOT NULL,
    cantidad        DECIMAL(10,2)    NOT NULL,
    precio_unitario DECIMAL(15,2)    NOT NULL,
    descuento       DECIMAL(15,2)    DEFAULT 0.00,
    subtotal        DECIMAL(15,2)    NOT NULL,
    activo          TINYINT(1)       DEFAULT 1,
    INDEX idx_compra   (compra_id),
    INDEX idx_producto (producto_id),
    CONSTRAINT fk_compras_det_compra FOREIGN KEY (compra_id)
        REFERENCES compras (id) ON DELETE CASCADE,
    CONSTRAINT fk_compras_det_prod FOREIGN KEY (producto_id)
        REFERENCES productos (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- VENTAS (depende de clientes, usuarios)
-- =====================================================

CREATE TABLE ventas (
    id         INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    folio      VARCHAR(20)      NOT NULL,
    cliente_id INT UNSIGNED     NOT NULL,
    usuario_id INT UNSIGNED     NOT NULL,
    fecha      DATE             NOT NULL,
    subtotal   DECIMAL(15,2)    DEFAULT 0.00,
    descuento  DECIMAL(15,2)    DEFAULT 0.00,
    iva        DECIMAL(15,2)    DEFAULT 0.00,
    total             DECIMAL(15,2)    DEFAULT 0.00,
    monto_pagado      DECIMAL(15,2)    DEFAULT 0.00,
    fecha_vencimiento DATE             DEFAULT NULL,
    tipo_pago  ENUM('contado','credito','transferencia','tarjeta') DEFAULT 'contado',
    estado     ENUM('pendiente','pagada','cancelada','parcial')    DEFAULT 'pagada',
    notas      TEXT,
    activo     TINYINT(1)       DEFAULT 1,
    created_at TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_folio    (folio),
    INDEX idx_cliente      (cliente_id),
    INDEX idx_usuario      (usuario_id),
    INDEX idx_fecha        (fecha),
    INDEX idx_estado       (estado),
    INDEX idx_activo       (activo),
    INDEX idx_fecha_estado (fecha, estado),
    CONSTRAINT fk_ventas_cliente FOREIGN KEY (cliente_id)
        REFERENCES clientes (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas_detalle (
    id              INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    venta_id        INT UNSIGNED     NOT NULL,
    producto_id     INT UNSIGNED     NOT NULL,
    cantidad        DECIMAL(10,2)    NOT NULL,
    precio_unitario DECIMAL(15,2)    NOT NULL,
    descuento       DECIMAL(15,2)    DEFAULT 0.00,
    subtotal        DECIMAL(15,2)    NOT NULL,
    activo          TINYINT(1)       DEFAULT 1,
    INDEX idx_venta    (venta_id),
    INDEX idx_producto (producto_id),
    CONSTRAINT fk_ventas_det_venta FOREIGN KEY (venta_id)
        REFERENCES ventas (id) ON DELETE CASCADE,
    CONSTRAINT fk_ventas_det_prod FOREIGN KEY (producto_id)
        REFERENCES productos (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas_pagos (
    id         INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    venta_id   INT UNSIGNED     NOT NULL,
    usuario_id INT UNSIGNED     NOT NULL,
    fecha      DATE             NOT NULL,
    monto      DECIMAL(15,2)    NOT NULL,
    tipo_pago  ENUM('contado','transferencia','tarjeta','cheque','otro') DEFAULT 'contado',
    referencia VARCHAR(100)     DEFAULT NULL,
    notas      TEXT,
    activo     TINYINT(1)       DEFAULT 1,
    created_at TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_venta   (venta_id),
    INDEX idx_usuario (usuario_id),
    INDEX idx_fecha   (fecha),
    CONSTRAINT fk_vp_venta   FOREIGN KEY (venta_id)   REFERENCES ventas   (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_vp_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INVENTARIO
-- =====================================================

CREATE TABLE inventario_movimientos (
    id              INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    producto_id     INT UNSIGNED     NOT NULL,
    tipo            ENUM('entrada','salida','ajuste','devolucion') NOT NULL,
    cantidad        DECIMAL(10,2)    NOT NULL,
    stock_anterior  DECIMAL(10,2)    NOT NULL,
    stock_nuevo     DECIMAL(10,2)    NOT NULL,
    referencia_tipo ENUM('compra','venta','ajuste','instalacion') DEFAULT NULL,
    referencia_id   INT UNSIGNED     DEFAULT NULL,
    usuario_id      INT UNSIGNED     NOT NULL,
    notas           TEXT,
    activo          TINYINT(1)       DEFAULT 1,
    created_at      TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_producto  (producto_id),
    INDEX idx_tipo      (tipo),
    INDEX idx_fecha     (created_at),
    INDEX idx_usuario   (usuario_id),
    INDEX idx_ref       (referencia_tipo, referencia_id),
    CONSTRAINT fk_inv_producto FOREIGN KEY (producto_id)
        REFERENCES productos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_inv_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSTALACIONES / COTIZACIONES
-- =====================================================

CREATE TABLE instalaciones (
    id            INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    folio         VARCHAR(20)      NOT NULL,
    cliente_id    INT UNSIGNED     NOT NULL,
    usuario_id    INT UNSIGNED     NOT NULL,
    fecha            DATE             NOT NULL,
    direccion        TEXT,
    direccion_inst   TEXT,
    tipo_pago        ENUM('contado','credito','transferencia','tarjeta') DEFAULT 'contado',
    subtotal         DECIMAL(15,2)    DEFAULT 0.00,
    descuento     DECIMAL(15,2)    DEFAULT 0.00,
    iva           DECIMAL(15,2)    DEFAULT 0.00,
    total         DECIMAL(15,2)    DEFAULT 0.00,
    estado        ENUM('cotizacion','aprobada','en_proceso','completada','cancelada') DEFAULT 'cotizacion',
    costo_mano_obra  DECIMAL(15,2) DEFAULT 0.00,
    costo_materiales DECIMAL(15,2) DEFAULT 0.00,
    garantia_meses   INT UNSIGNED  DEFAULT 12,
    notas         TEXT,
    activo        TINYINT(1)       DEFAULT 1,
    created_at    TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_folio   (folio),
    INDEX idx_cliente     (cliente_id),
    INDEX idx_usuario     (usuario_id),
    INDEX idx_fecha       (fecha),
    INDEX idx_estado      (estado),
    CONSTRAINT fk_inst_cliente FOREIGN KEY (cliente_id)
        REFERENCES clientes (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_inst_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE instalaciones_detalle (
    id              INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    instalacion_id  INT UNSIGNED     NOT NULL,
    producto_id     INT UNSIGNED     DEFAULT NULL,
    descripcion     VARCHAR(255)     NOT NULL,
    cantidad        DECIMAL(10,2)    NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(15,2)    NOT NULL DEFAULT 0.00,
    subtotal        DECIMAL(15,2)    NOT NULL DEFAULT 0.00,
    activo          TINYINT(1)       DEFAULT 1,
    INDEX idx_instalacion (instalacion_id),
    INDEX idx_producto    (producto_id),
    CONSTRAINT fk_instdet_inst FOREIGN KEY (instalacion_id)
        REFERENCES instalaciones (id) ON DELETE CASCADE,
    CONSTRAINT fk_instdet_prod FOREIGN KEY (producto_id)
        REFERENCES productos (id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- GASTOS
-- =====================================================

CREATE TABLE gastos_categorias (
    id          INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100)  NOT NULL,
    descripcion TEXT,
    tipo        ENUM('compra_productos','materiales','servicios','nomina','otros') DEFAULT 'otros',
    activo      TINYINT(1)    DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE gastos (
    id           INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    folio        VARCHAR(20)      NOT NULL,
    categoria_id INT UNSIGNED     DEFAULT NULL,
    concepto     VARCHAR(255)     NOT NULL,
    proveedor    VARCHAR(150)     DEFAULT NULL,
    fecha        DATE             NOT NULL,
    monto        DECIMAL(15,2)    NOT NULL DEFAULT 0.00,
    tipo_pago    ENUM('efectivo','transferencia','tarjeta','cheque','otro') DEFAULT 'efectivo',
    comprobante  VARCHAR(200)     DEFAULT NULL,
    periodo_mes  TINYINT UNSIGNED DEFAULT NULL,
    periodo_anio SMALLINT UNSIGNED DEFAULT NULL,
    estado       ENUM('pagado','pendiente','cancelado','anulado') DEFAULT 'pagado',
    notas        TEXT,
    usuario_id   INT UNSIGNED     NOT NULL,
    activo       TINYINT(1)       DEFAULT 1,
    created_at   TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_folio (folio),
    INDEX idx_fecha      (fecha),
    INDEX idx_categoria  (categoria_id),
    INDEX idx_estado     (estado),
    CONSTRAINT fk_gastos_cat FOREIGN KEY (categoria_id)
        REFERENCES gastos_categorias (id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_gastos_usr FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- DATOS INICIALES
-- =====================================================

INSERT INTO roles (nombre, descripcion, permisos) VALUES
('Administrador', 'Acceso total al sistema',   '{"all": true}'),
('Vendedor',      'Ventas y clientes',          '{"ventas": true, "clientes": true, "productos": true}'),
('Almacenista',   'Inventario y compras',       '{"inventario": true, "compras": true}');

-- admin / password (bcrypt, costo 10)
INSERT INTO usuarios (nombre, apellido, email, username, password, rol_id) VALUES
('Administrador', 'Sistema', 'admin@ferreteria.com', 'admin',
 '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1);

INSERT INTO categorias (nombre) VALUES
('Computadoras'), ('Impresoras'), ('Redes'),
('Accesorios'), ('Cámaras'), ('DVR/NVR'),
('Kits CCTV'), ('Instalación'), ('General');

INSERT INTO proveedores (nombre, empresa, email, telefono) VALUES
('Proveedor General', 'Distribuidora GT S.A.', 'proveedor@ejemplo.com', '22001122');

INSERT INTO clientes (nombre, apellido, rfc, telefono) VALUES
('Consumidor', 'Final', 'CF', '00000000');

INSERT INTO camaras_marcas (nombre) VALUES
('Dahua'), ('Hikvision'), ('Imou'), ('Ezviz'), ('Reolink'), ('Otras');

INSERT INTO camaras_tipos (nombre) VALUES
('Domo'), ('Bala'), ('PTZ'), ('Fisheye'), ('Box'), ('Mini Domo');

INSERT INTO camaras_resoluciones (nombre) VALUES
('720p HD'), ('1080p Full HD'), ('2MP'), ('4MP'), ('5MP'), ('8MP 4K');

INSERT INTO camaras_tecnologias (nombre) VALUES
('HDCVI'), ('HDTVI'), ('AHD'), ('IP/PoE'), ('WiFi'), ('Analógica');

INSERT INTO gastos_categorias (nombre) VALUES
('Combustible'), ('Alimentación'), ('Herramientas'),
('Papelería'), ('Servicios'), ('Otros');

INSERT INTO configuracion (clave, valor, descripcion) VALUES
('empresa_nombre',         'Ferretería La Curva',   'Nombre de la empresa'),
('empresa_rfc',            'CF',                    'NIT de la empresa'),
('empresa_direccion',      'Guatemala, Guatemala',   'Dirección'),
('empresa_telefono',       '',                      'Teléfono'),
('empresa_email',          '',                      'Email de contacto'),
('moneda_simbolo',         'Q',                     'Símbolo de moneda'),
('iva_venta',              '5',                     'IVA aplicado a ventas (%)'),
('iva_compra',             '12',                    'IVA aplicado a compras (%)'),
('folio_venta_prefijo',    'VTA',                   'Prefijo para folios de venta'),
('folio_compra_prefijo',   'CMP',                   'Prefijo para folios de compra'),
('folio_inst_prefijo',     'COT',                   'Prefijo para cotizaciones'),
('folio_gasto_prefijo',    'GST',                   'Prefijo para gastos'),
('folio_venta_contador',   '0',                     'Contador de ventas'),
('folio_compra_contador',  '0',                     'Contador de compras'),
('folio_inst_contador',    '0',                     'Contador de instalaciones'),
('folio_gasto_contador',   '0',                     'Contador de gastos');

-- Productos de ejemplo
INSERT INTO productos
    (codigo, nombre, categoria_id, precio_costo, precio_venta,
     precio_mayoreo, precio1, precio2, unidad_medida, stock_actual, stock_minimo)
VALUES
('LAPTOP-001', 'Laptop HP 15 Core i5',        1, 3000.00, 4200.00, 3900.00, 4000.00, 3800.00, 'PZA', 0, 2),
('MOUSE-001',  'Mouse Inalámbrico Logitech',   4,   80.00,  150.00,  130.00,  140.00,  125.00, 'PZA', 0, 5),
('IMP-001',    'Impresora Epson L3250',         2,  800.00, 1200.00, 1100.00, 1150.00, 1050.00, 'PZA', 0, 2);
