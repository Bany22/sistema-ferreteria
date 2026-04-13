# DIGICOMP — Instalación en Windows 11 con XAMPP
### PHP 8.2.12 · MariaDB 10.4.32 · Apache 2.4.58

---

## PASO 1 — Instalar XAMPP 8.2.12

1. Descargar: https://www.apachefriends.org/download.html
   - Buscar la versión **8.2.12** (PHP 8.2)
2. Instalar en: `C:\xampp\` ← ruta SIN espacios, NO en "Archivos de programa"
3. Abrir **XAMPP Control Panel** (como Administrador)
4. Hacer clic en **Start** en:
   - ✅ **Apache**
   - ✅ **MySQL** (es MariaDB 10.4.32)
5. Verificar: abrir `http://localhost` → debe mostrar la página de XAMPP

---

## PASO 2 — Copiar los archivos del sistema

Copiar la carpeta `ferreteria` a:

```
C:\xampp\htdocs\ferreteria\
```

La estructura debe quedar así:
```
C:\xampp\htdocs\ferreteria\
    ├── includes\
    ├── modules\
    ├── api\
    ├── css\
    ├── js\
    ├── uploads\
    ├── migrations\
    ├── index.php
    ├── login.php
    ├── logout.php
    ├── .htaccess
    └── database.sql
```

---

## PASO 3 — Crear la base de datos

1. Abrir **phpMyAdmin**: `http://localhost/phpmyadmin`
2. Clic en **Importar** (menú superior)
3. Seleccionar el archivo: `database.sql`  ← está dentro de la carpeta ferreteria
4. Clic en **Continuar**

✅ Crea automáticamente la BD `sistema_ventas` con todas las tablas y datos.

> ⚠️ Este `database.sql` ya incluye TODO. No necesitas ejecutar ningún otro .sql.

---

## PASO 4 — Habilitar AllowOverride en Apache (necesario para .htaccess)

1. En XAMPP Control Panel → Apache → **Config** → `httpd.conf`
2. Buscar el bloque `<Directory "C:/xampp/htdocs">` y cambiar:
   ```apache
   AllowOverride None   →   AllowOverride All
   ```
3. Guardar y en XAMPP Control Panel → Apache → **Stop** → **Start**

---

## PASO 5 — Verificar configuración

El archivo `includes\config.php` ya viene configurado para XAMPP:

```php
define('DB_HOST',    'localhost');
define('DB_USER',    'root');
define('DB_PASS',    '');          // XAMPP sin contraseña
define('DB_NAME',    'sistema_ventas');
define('APP_URL',    'http://localhost/ferreteria');
define('DEBUG_MODE', true);
```

> No necesitas cambiar nada si instalaste XAMPP con la configuración predeterminada.

---

## PASO 6 — Ingresar al sistema

URL: **`http://localhost/ferreteria`**

| Campo    | Valor      |
|----------|------------|
| Usuario  | `admin`    |
| Password | `password` |

---

## Solución de errores comunes en Windows 11

### ❌ Error 403 — Forbidden
Apache no puede leer el `.htaccess`.

**Solución:** Seguir el Paso 4 (AllowOverride All) y reiniciar Apache.

### ❌ Puerto 80 ocupado (IIS, Skype, otro programa)
**Solución:** En XAMPP → Apache → Config → `httpd.conf`:
- Cambiar `Listen 80` → `Listen 8080`
- Cambiar en `config.php`: `APP_URL` → `http://localhost:8080/ferreteria`
- Reiniciar Apache

### ❌ Pantalla en blanco
`DEBUG_MODE` ya está en `true`, abre `http://localhost/ferreteria` y verás el error exacto.

### ❌ "Call to undefined function" o error de extensión PHP
Abrir `C:\xampp\php\php.ini` y verificar que estas líneas NO tengan `;` al inicio:
```ini
extension=pdo_mysql
extension=mbstring
extension=openssl
```
Reiniciar Apache.

### ❌ phpMyAdmin pide contraseña de root
Entrar con usuario `root` y contraseña en **blanco**.

---

## Para producción (entregar al cliente)

En `includes\config.php`:
```php
define('DEBUG_MODE', false);
```

En `.htaccess`:
```apache
php_flag display_errors Off
```
