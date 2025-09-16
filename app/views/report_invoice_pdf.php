<?php
require_once __DIR__ . '/../lib/util.php';
?>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Comprobante Venta #<?=h($v['idventa'])?></title>
<style>
  body { font-family: DejaVu Sans, Arial, sans-serif; font-size: 12px; }
  h1 { font-size: 18px; margin: 0 0 8px; }
  .meta, .totales { margin: 10px 0; }
  table { width: 100%; border-collapse: collapse; margin-top: 10px; }
  th, td { border: 1px solid #999; padding: 6px; }
  th { background: #eee; }
  .right { text-align: right; }
</style>
</head>
<body>
  <h1>Comprobante de Venta</h1>
  <div class="meta">
    <strong>N°:</strong> <?=h($v['idventa'])?><br>
    <strong>Fecha:</strong> <?=h($v['fecha'])?><br>
    <strong>Cliente:</strong> <?=h($v['cliente'])?><br>
    <strong>Vendedor:</strong> <?=h($v['vendedor'])?><br>
  </div>

  <table>
    <tr>
      <th>Producto</th>
      <th class="right">Cantidad</th>
      <th class="right">P. Unit</th>
      <th class="right">Subtotal</th>
    </tr>
    <?php foreach($items as $it): ?>
    <tr>
      <td><?=h($it['nombre'])?></td>
      <td class="right"><?=h($it['cantidad'])?></td>
      <td class="right"><?=number_format($it['precio_unitario'],2)?></td>
      <td class="right"><?=number_format($it['subtotal'],2)?></td>
    </tr>
    <?php endforeach; ?>
  </table>

  <div class="totales right">
    <p><strong>Total: S/ <?=number_format($v['total'],2)?></strong></p>
  </div>
</body>
</html>
