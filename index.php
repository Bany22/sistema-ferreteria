<?php
$pageTitle = 'Dashboard';
require_once __DIR__ . '/includes/header.php';

$db = Database::getInstance();

// Estadísticas del día
$hoy = date('Y-m-d');
$mesActual = date('Y-m');

$ventasHoy = $db->fetchOne("SELECT COUNT(*) as cnt, COALESCE(SUM(total),0) as total FROM ventas WHERE fecha = ? AND activo=1 AND estado != 'cancelada'", [$hoy]);
$ventasMes = $db->fetchOne("SELECT COUNT(*) as cnt, COALESCE(SUM(total),0) as total FROM ventas WHERE DATE_FORMAT(fecha,'%Y-%m') = ? AND activo=1 AND estado != 'cancelada'", [$mesActual]);
$comprasMes = $db->fetchOne("SELECT COALESCE(SUM(total),0) as total FROM compras WHERE DATE_FORMAT(fecha,'%Y-%m') = ? AND activo=1 AND estado != 'cancelada'", [$mesActual]);
$totalClientes = $db->fetchOne("SELECT COUNT(*) as cnt FROM clientes WHERE activo=1");
$totalProductos = $db->fetchOne("SELECT COUNT(*) as cnt FROM productos WHERE activo=1");
$stockBajo = $db->fetchOne("SELECT COUNT(*) as cnt FROM productos WHERE activo=1 AND stock_actual <= stock_minimo AND stock_minimo > 0");

// Ventas últimos 7 días para gráfica
$ventas7dias = $db->fetchAll(
    "SELECT DATE(fecha) as dia, COALESCE(SUM(total),0) as total, COUNT(*) as cnt
     FROM ventas WHERE fecha >= DATE_SUB(?, INTERVAL 6 DAY) AND activo=1 AND estado != 'cancelada'
     GROUP BY DATE(fecha) ORDER BY dia",
    [$hoy]
);

// Top 5 productos más vendidos este mes
$topProductos = $db->fetchAll(
    "SELECT p.nombre, p.codigo, SUM(vd.cantidad) as qty_vendida, SUM(vd.subtotal) as total_venta
     FROM ventas_detalle vd
     JOIN ventas v ON vd.venta_id = v.id
     JOIN productos p ON vd.producto_id = p.id
     WHERE DATE_FORMAT(v.fecha,'%Y-%m') = ? AND v.activo=1 AND v.estado != 'cancelada' AND vd.activo=1
     GROUP BY p.id, p.nombre, p.codigo ORDER BY qty_vendida DESC LIMIT 5",
    [$mesActual]
);

// Últimas ventas
$ultimasVentas = $db->fetchAll(
    "SELECT v.folio, v.fecha, v.total, v.estado, v.tipo_pago,
            CONCAT(c.nombre,' ',c.apellido) as cliente
     FROM ventas v JOIN clientes c ON v.cliente_id = c.id
     WHERE v.activo=1 ORDER BY v.id DESC LIMIT 8"
);

// Prepare chart data
$chartLabels = [];
$chartData = [];
$startDate = new DateTime(date('Y-m-d', strtotime('-6 days')));
for ($i = 0; $i <= 6; $i++) {
    $d = clone $startDate;
    $d->modify("+$i days");
    $key = $d->format('Y-m-d');
    $label = $d->format('d/m');
    $chartLabels[] = $label;
    $keyLocal = $key; $found = array_filter($ventas7dias, function($r) use ($keyLocal) { return $r['dia'] === $keyLocal; });
    $chartData[] = $found ? array_values($found)[0]['total'] : 0;
}
?>

<div class="page-header">
    <div>
        <h1><i class="bi bi-speedometer2 me-2 text-primary"></i>Dashboard</h1>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb"><li class="breadcrumb-item active">Inicio</li></ol>
        </nav>
    </div>
    <div class="text-muted small"><i class="bi bi-calendar3 me-1"></i><?= date('d/m/Y') ?></div>
</div>

<!-- Stats Row -->
<div class="row g-3 mb-4">
    <div class="col-xl-2 col-md-4 col-sm-6">
        <div class="stat-card">
            <div class="stat-icon green"><i class="bi bi-cart-check"></i></div>
            <div>
                <div class="stat-value">Q <?= number_format($ventasHoy['total'], 2) ?></div>
                <div class="stat-label">Ventas Hoy</div>
                <div class="stat-change up"><i class="bi bi-receipt me-1"></i><?= $ventasHoy['cnt'] ?> transacciones</div>
            </div>
        </div>
    </div>
    <div class="col-xl-2 col-md-4 col-sm-6">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="bi bi-graph-up-arrow"></i></div>
            <div>
                <div class="stat-value">Q <?= number_format($ventasMes['total'], 0) ?></div>
                <div class="stat-label">Ventas del Mes</div>
                <div class="stat-change up"><i class="bi bi-receipt me-1"></i><?= $ventasMes['cnt'] ?> ventas</div>
            </div>
        </div>
    </div>
    <div class="col-xl-2 col-md-4 col-sm-6">
        <div class="stat-card">
            <div class="stat-icon orange"><i class="bi bi-truck"></i></div>
            <div>
                <div class="stat-value">Q <?= number_format($comprasMes['total'], 0) ?></div>
                <div class="stat-label">Compras del Mes</div>
                <div class="stat-change"><i class="bi bi-calendar-month me-1"></i><?= date('M Y') ?></div>
            </div>
        </div>
    </div>
    <div class="col-xl-2 col-md-4 col-sm-6">
        <div class="stat-card">
            <div class="stat-icon purple"><i class="bi bi-people"></i></div>
            <div>
                <div class="stat-value"><?= $totalClientes['cnt'] ?></div>
                <div class="stat-label">Clientes Activos</div>
                <div class="stat-change"><a href="modules/clientes/index.php" class="text-primary">Ver todos</a></div>
            </div>
        </div>
    </div>
    <div class="col-xl-2 col-md-4 col-sm-6">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="bi bi-box-seam"></i></div>
            <div>
                <div class="stat-value"><?= $totalProductos['cnt'] ?></div>
                <div class="stat-label">Productos</div>
                <div class="stat-change"><a href="modules/productos/index.php" class="text-primary">Ver todos</a></div>
            </div>
        </div>
    </div>
    <div class="col-xl-2 col-md-4 col-sm-6">
        <div class="stat-card">
            <div class="stat-icon red"><i class="bi bi-exclamation-triangle"></i></div>
            <div>
                <div class="stat-value"><?= $stockBajo['cnt'] ?></div>
                <div class="stat-label">Stock Bajo</div>
                <div class="stat-change down"><a href="modules/existencias/index.php" class="text-danger">Ver alerta</a></div>
            </div>
        </div>
    </div>
</div>

<div class="row g-4">
    <!-- Gráfica de ventas -->
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="bi bi-bar-chart me-2"></i>Ventas - Últimos 7 Días</span>
                <a href="modules/ventas/index.php" class="btn btn-sm btn-outline-primary">Ver ventas</a>
            </div>
            <div class="card-body">
                <canvas id="salesChart" height="100"></canvas>
            </div>
        </div>
    </div>

    <!-- Top Productos -->
    <div class="col-lg-4">
        <div class="card">
            <div class="card-header"><i class="bi bi-trophy me-2"></i>Top Productos del Mes</div>
            <div class="card-body p-0">
                <?php if (empty($topProductos)): ?>
                <div class="p-4 text-center text-muted">Sin datos este mes</div>
                <?php else: ?>
                <div class="list-group list-group-flush">
                    <?php foreach ($topProductos as $i => $p): ?>
                    <div class="list-group-item d-flex align-items-center gap-3 py-3">
                        <span class="badge bg-primary rounded-circle d-flex align-items-center justify-content-center" 
                              style="width:28px;height:28px"><?= $i+1 ?></span>
                        <div class="flex-grow-1 min-w-0">
                            <div class="fw-semibold text-truncate small"><?= htmlspecialchars($p['nombre']) ?></div>
                            <div class="text-muted" style="font-size:.75rem"><?= number_format($p['qty_vendida'],0) ?> uds</div>
                        </div>
                        <span class="fw-bold text-success small">Q <?= number_format($p['total_venta'],0) ?></span>
                    </div>
                    <?php endforeach; ?>
                </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<!-- Últimas Ventas -->
<div class="card mt-4">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="bi bi-clock-history me-2"></i>Últimas Ventas</span>
        <a href="modules/ventas/crear.php" class="btn btn-sm btn-primary">
            <i class="bi bi-plus me-1"></i>Nueva Venta
        </a>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead>
                    <tr>
                        <th>Folio</th><th>Cliente</th><th>Fecha</th>
                        <th>Total</th><th>Pago</th><th>Estado</th><th>Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($ultimasVentas as $v): ?>
                    <tr>
                        <td><code><?= htmlspecialchars($v['folio']) ?></code></td>
                        <td><?= htmlspecialchars($v['cliente']) ?></td>
                        <td><?= date('d/m/Y', strtotime($v['fecha'])) ?></td>
                        <td class="fw-bold text-success">Q <?= number_format($v['total'],2) ?></td>
                        <td><span class="text-capitalize"><?= htmlspecialchars($v['tipo_pago']) ?></span></td>
                        <td><span class="badge-<?= $v['estado'] ?>"><?= ucfirst($v['estado']) ?></span></td>
                        <td>
                            <a href="modules/ventas/ver.php?folio=<?= urlencode($v['folio']) ?>" 
                               class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (empty($ultimasVentas)): ?>
                    <tr><td colspan="7" class="text-center text-muted py-4">No hay ventas registradas</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
const APP_URL = '<?= APP_URL ?>';
// Sales Chart
new Chart(document.getElementById('salesChart'), {
    type: 'bar',
    data: {
        labels: <?= json_encode($chartLabels) ?>,
        datasets: [{
            label: 'Ventas ($)',
            data: <?= json_encode(array_map('floatval', $chartData)) ?>,
            backgroundColor: 'rgba(37,99,235,0.15)',
            borderColor: 'rgba(37,99,235,0.8)',
            borderWidth: 2,
            borderRadius: 6,
            fill: true
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
            y: {
                beginAtZero: true,
                ticks: {
                    callback: v => 'Q ' + v.toLocaleString('es-MX')
                }
            }
        }
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
