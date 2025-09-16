<?php require_once __DIR__ . '/../lib/util.php'; ?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Venta</title>
  <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
<div class="container">
  <div class="card">
    <div class="header">
      <h2>Venta #<?=h($v['idventa']??'')?></h2>
      <div class="mono"><?=h($v['fecha'])?></div>
    </div>

    <p class="mono">
      Cliente: <?=h($v['cliente'] ?: 'Público General')?> — 
      Vendedor: <?=h($v['vendedor'])?>
    </p>

    <table>
      <tr><th>Producto</th><th>Cantidad</th><th>P.Unit</th><th>Subtotal</th></tr>
      <?php foreach($items as $it): ?>
        <tr>
          <td><?=h($it['nombre'])?></td>
          <td><?=h($it['cantidad'])?></td>
          <td><?=h($it['precio_unitario'])?></td>
          <td><?=h($it['subtotal'])?></td>
        </tr>
      <?php endforeach; ?>
      <tr>
        <td colspan="3" style="text-align:right;"><strong>Total</strong></td>
        <td><strong><?=h($v['total'])?></strong></td>
      </tr>
    </table>

    <p style="margin-top:12px;">
      <a class="btn primary" href="index.php?r=report/pdf&vid=<?=h($v['idventa'])?>">Descargar PDF</a>
      <a class="btn" href="index.php?r=report/index">← Volver</a>
      <button class="btn" onclick="window.print()">Imprimir / Guardar PDF</button>
    </p>
  </div>
</div>
</body>
</html>
