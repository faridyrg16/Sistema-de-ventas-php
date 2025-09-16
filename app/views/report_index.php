<?php require_once __DIR__ . '/../lib/util.php'; ?>
<!doctype html><html><head><meta charset="utf-8"><title>Reportes</title>
<link rel="stylesheet" href="assets/styles.css"></head>
<body><div class="container"><div class="card">
<h2>Reportes</h2>
<?php if (!empty($ventas)): ?>
<h3>Últimas ventas</h3>
<table><tr><th>ID</th><th>Fecha</th><th>Cliente</th><th>Total</th></tr>
<?php foreach($ventas as $v): ?>
<tr>
  <td><a class="btn" href="index.php?r=report/last&vid=<?=h($v['idventa'])?>"><?=h($v['idventa'])?></a></td>
  <td><?=h($v['fecha'])?></td>
  <td><?=h($v['cliente'])?></td>
  <td><?=h($v['total'])?></td>
</tr>
<?php endforeach; ?></table>
<?php endif; ?>
<?php if (!empty($top)): ?>
<h3 style="margin-top:16px;">Top productos</h3>
<table><tr><th>ID</th><th>Producto</th><th>Cantidad</th><th>Ventas</th></tr>
<?php foreach($top as $t): ?>
<tr><td><?=h($t['idproducto'])?></td><td><?=h($t['nombre'])?></td><td><?=h($t['total_cantidad'])?></td><td><?=h($t['total_ventas'])?></td></tr>
<?php endforeach; ?></table>
<?php endif; ?>
<p><a class="btn" href="index.php?r=home">← Volver</a></p>
</div></div></body></html>