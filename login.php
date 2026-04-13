<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/auth.php';

if (Auth::isLoggedIn()) {
    header('Location: ' . APP_URL . '/index.php');
    exit;
}

$error   = '';
$empresa = getSetting('empresa_nombre') ?? 'Sistema de Ventas';
$logo    = getSetting('logo_empresa')   ?? '';

// Verificar que el archivo exista físicamente
$logoValido = $logo && file_exists(APP_PATH . '/' . ltrim($logo, '/'));

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';

    if (empty($username) || empty($password)) {
        $error = 'Por favor ingrese usuario y contraseña.';
    } elseif (!Auth::login($username, $password)) {
        $error = 'Usuario o contraseña incorrectos.';
    } else {
        header('Location: ' . APP_URL . '/index.php');
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión — <?= htmlspecialchars($empresa) ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<?= APP_URL ?>/css/app.css" rel="stylesheet">
    <style>
        .login-logo-img {
            max-width: 220px;
            max-height: 90px;
            object-fit: contain;
            display: block;
            margin: 0 auto 6px;
            /* fondo claro para logos con transparencia sobre fondo oscuro */
            background: rgba(255,255,255,0.08);
            border-radius: 10px;
            padding: 8px 16px;
        }
    </style>
</head>
<body style="background: linear-gradient(135deg,#1e293b 0%,#0f172a 100%); min-height:100vh;">
<div class="login-wrapper">
    <div class="login-card">

        <!-- LOGO: imagen si existe, ícono predeterminado si no -->
        <?php if ($logoValido): ?>
            <img src="<?= APP_URL ?>/<?= htmlspecialchars($logo) ?>?v=<?= filemtime(APP_PATH . '/' . ltrim($logo, '/')) ?>"
                 alt="<?= htmlspecialchars($empresa) ?>"
                 class="login-logo-img">
        <?php else: ?>
            <div class="login-logo"><i class="bi bi-shop-window"></i></div>
        <?php endif; ?>

        <h2 class="login-title"><?= htmlspecialchars($empresa) ?></h2>
        <p class="login-subtitle">Sistema de Ventas e Inventarios</p>

        <?php if ($error): ?>
        <div class="alert alert-danger d-flex align-items-center gap-2" role="alert">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <?= htmlspecialchars($error) ?>
        </div>
        <?php endif; ?>

        <form method="POST" action="">
            <div class="mb-3">
                <label class="form-label">Usuario o Email</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person"></i></span>
                    <input type="text" name="username" class="form-control"
                           placeholder="admin" value="<?= htmlspecialchars($_POST['username'] ?? '') ?>"
                           required autofocus>
                </div>
            </div>
            <div class="mb-4">
                <label class="form-label">Contraseña</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                    <input type="password" name="password" id="passwordInput" class="form-control"
                           placeholder="••••••••" required>
                    <button class="btn btn-outline-secondary" type="button" id="togglePwd">
                        <i class="bi bi-eye" id="eyeIcon"></i>
                    </button>
                </div>
            </div>
            <button type="submit" class="btn btn-primary w-100 py-2 fw-bold">
                <i class="bi bi-box-arrow-in-right me-2"></i>Iniciar Sesión
            </button>
        </form>


    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.getElementById('togglePwd').addEventListener('click', function () {
    const pwd  = document.getElementById('passwordInput');
    const icon = document.getElementById('eyeIcon');
    if (pwd.type === 'password') {
        pwd.type = 'text';
        icon.className = 'bi bi-eye-slash';
    } else {
        pwd.type = 'password';
        icon.className = 'bi bi-eye';
    }
});
</script>
</body>
</html>
