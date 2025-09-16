<?php require_once __DIR__ . '/../lib/util.php'; ?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Comprobante de Venta #<?=h($v['idventa'])?></title>
  <style>
    body { font-family: DejaVu Sans, Arial, sans-serif; font-size:12px; color:#111; }
    h1 { font-size:18px; margin:0 0 8px; }
    .meta { margin:6px 0 12px; }
    table { width:100%; border-collapse:collapse; }
    th, td { border:1px solid #333; padding:6px; }
    th { background:#f0f0f0; }
    .right { text-align:right; }
    .tot { font-weight:bold; background:#f9f9f9; }
  </style>
</head>
<body>
  <h1>Comprobante de Venta #<?=h($v['idventa'])?></h1>
  <div class="meta">
    Fecha: <?=h($v['fecha'])?><br>
    Cliente: <?=h($v['cliente'] ?: 'Público General')?><br>
    Vendedor: <?=h($v['vendedor'])?>
  </div>

  <table>
    <tr>
      <th>Producto</th>
      <th class="right">Cant</th>
      <th class="right">P.Unit</th>
      <th class="right">Subtotal</th>
    </tr>
    <?php foreach($items as $it): ?>
      <tr>
        <td><?=h($it['nombre'])?></td>
        <td class="right"><?=h($it['cantidad'])?></td>
        <td class="right"><?=number_format($it['precio_unitario'], 2)?></td>
        <td class="right"><?=number_format($it['subtotal'], 2)?></td>
      </tr>
    <?php endforeach; ?>
    <tr class="tot">
      <td colspan="3" class="right">Total</td>
      <td class="right"><?=number_format($v['total'], 2)?></td>
    </tr>
  </table>
</body>
</html>
