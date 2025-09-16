<?php require_once __DIR__ . '/../lib/util.php'; ?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Stock</title>
  <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
<div class="container"><div class="card">
  <h2>Stock de productos</h2>
  <table>
    <tr><th>ID</th><th>Nombre</th><th class="right">Precio</th><th class="right">Stock</th></tr>
    <?php foreach($rows as $r): ?>
      <tr>
        <td><?=h($r['idproducto'])?></td>
        <td><?=h($r['nombre'])?></td>
        <td class="right"><?=number_format($r['precio'],2)?></td>
        <td class="right"><?=h($r['stock'])?></td>
      </tr>
    <?php endforeach; ?>
  </table>
  <p style="margin-top:10px"><a class="btn" href="index.php?r=almacen/index">← Volver</a></p>
</div></div>
</body>
</html>
