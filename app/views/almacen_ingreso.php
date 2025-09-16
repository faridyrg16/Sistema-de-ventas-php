<?php require_once __DIR__ . '/../lib/util.php'; ?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Ingresos</title>
  <link rel="stylesheet" href="assets/styles.css">
  <style>.right{text-align:right}.qty{width:70px}</style>
</head>
<body>
<div class="container"><div class="card">
  <h2>Ingresos a Almacén</h2>

  <input id="q" class="qty" style="width:240px" placeholder="Buscar producto...">
  <table id="t">
    <tr><th>ID</th><th>Nombre</th><th class="right">Stock</th><th class="right">Ingresar</th><th></th></tr>
    <?php foreach($rows as $r): ?>
      <tr data-nombre="<?=h(mb_strtolower($r['nombre']))?>">
        <td><?=h($r['idproducto'])?></td>
        <td><?=h($r['nombre'])?></td>
        <td class="right"><?=h($r['stock'])?></td>
        <td class="right">
          <form method="post" action="index.php?r=almacen/ingreso_save" style="display:inline">
            <input type="hidden" name="idproducto" value="<?=h($r['idproducto'])?>">
            <input class="qty" type="number" name="cantidad" min="1" value="1">
            <button class="btn">Ingresar</button>
          </form>
        </td>
        <td></td>
      </tr>
    <?php endforeach; ?>
  </table>

  <p style="margin-top:10px"><a class="btn" href="index.php?r=almacen/index">← Volver</a></p>
</div></div>

<script>
const q = document.getElementById('q');
const rows = Array.from(document.querySelectorAll('#t tr')).slice(1);
q.addEventListener('input', () => {
  const s = q.value.trim().toLowerCase();
  rows.forEach(tr => {
    const n = tr.dataset.nombre || '';
    tr.style.display = n.includes(s) ? '' : 'none';
  });
});
</script>
</body>
</html>
