<?php require_once __DIR__ . '/../lib/util.php'; ?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Nueva venta</title>
  <link rel="stylesheet" href="assets/styles.css">
  <style>
    .qty { width: 64px; }
    .toolbar { display:flex; gap:12px; align-items:center; margin-bottom:12px; }
    .toolbar .grow { flex:1 }
    .muted { color:#6b7280; font-size:12px }
    .right { text-align:right }
  </style>
</head>
<body>
<div class="container">
  <div class="card">
    <h2>Nueva venta</h2>

    <!-- FORM PRINCIPAL: envía cliente + carrito a sale/confirm -->
    <form method="post" action="index.php?r=sale/confirm" id="sale-form">
      <div class="toolbar">
        <div>
          <label>Cliente</label>
          <select name="dniCliente" id="cliente">
            <?php foreach ($clientes as $c): ?>
              <option value="<?=h($c['dni'])?>"><?=h($c['nombre'])?> (<?=h($c['dni'])?>)</option>
            <?php endforeach; ?>
          </select>
        </div>
        <div class="grow"></div>
        <div>
          <button type="submit" class="btn primary" id="confirm-btn" disabled>Realizar venta</button>
          <a class="btn" href="index.php?r=home">← Volver</a>
        </div>
      </div>

      <!-- Input oculto: aquí va el carrito en JSON -->
      <input type="hidden" name="items" id="items-input">

      <h3>Productos</h3>
      <table id="prod">
        <tr>
          <th>ID</th><th>Nombre</th><th class="right">Precio</th><th class="right">Stock</th><th class="right">Cant</th><th>Agregar</th>
        </tr>
        <?php foreach ($productos as $p): ?>
          <tr data-id="<?=h($p['idproducto'])?>" data-precio="<?=h($p['precio'])?>" data-nombre="<?=h($p['nombre'])?>" data-stock="<?=h($p['stock'])?>">
            <td><?=h($p['idproducto'])?></td>
            <td><?=h($p['nombre'])?></td>
            <td class="right"><?=number_format($p['precio'], 2)?></td>
            <td class="right"><?=h($p['stock'])?></td>
            <td class="right">
              <input class="qty" type="number" min="1" max="<?=max(0,(int)$p['stock'])?>" value="1">
            </td>
            <td><button class="btn add">Agregar</button></td>
          </tr>
        <?php endforeach; ?>
      </table>

      <h3 style="margin-top:16px;">Carrito</h3>
      <table>
        <thead>
          <tr><th>ID</th><th>Nombre</th><th class="right">Cantidad</th><th class="right">P.Unit</th><th class="right">Subtotal</th><th></th></tr>
        </thead>
        <tbody id="cart"></tbody>
      </table>

      <p class="right" style="margin-top:8px;">
        <span class="muted">Total:</span>
        <strong>S/ <span id="total">0.00</span></strong>
      </p>
    </form>
  </div>
</div>

<script>
/* --- estado del carrito --- */
const cart = []; // {idproducto, nombre, cantidad, precio, max}

/* --- helpers DOM --- */
const $ = s => document.querySelector(s);
const $$ = s => document.querySelectorAll(s);
const tbody = $('#cart');
const totalSpan = $('#total');
const itemsInput = $('#items-input');
const confirmBtn = $('#confirm-btn');

/* --- render del carrito y total --- */
function renderCart(){
  tbody.innerHTML = '';
  let tot = 0;

  cart.forEach((it, idx) => {
    const sub = it.cantidad * it.precio;
    tot += sub;

    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${it.idproducto}</td>
      <td>${escapeHtml(it.nombre)}</td>
      <td class="right">
        <input type="number" class="qty" min="1" max="${it.max}" value="${it.cantidad}" data-idx="${idx}">
      </td>
      <td class="right">${it.precio.toFixed(2)}</td>
      <td class="right">${sub.toFixed(2)}</td>
      <td class="right"><button class="btn del" data-idx="${idx}">Quitar</button></td>
    `;
    tbody.appendChild(tr);
  });

  totalSpan.textContent = tot.toFixed(2);
  itemsInput.value = JSON.stringify(cart);
  confirmBtn.disabled = cart.length === 0;

  // listeners para cantidad y quitar
  $$('#cart .qty').forEach(inp => {
    inp.addEventListener('change', e => {
      const idx = parseInt(e.target.dataset.idx, 10);
      const max = cart[idx].max;
      let val = parseInt(e.target.value, 10) || 1;
      val = Math.max(1, Math.min(max, val));
      cart[idx].cantidad = val;
      renderCart();
    });
  });
  $$('#cart .del').forEach(btn => {
    btn.addEventListener('click', e => {
      e.preventDefault();
      const idx = parseInt(e.target.dataset.idx, 10);
      cart.splice(idx, 1);
      renderCart();
    });
  });
}

/* --- agregar producto desde la grilla --- */
$$('#prod .add').forEach(btn => {
  btn.addEventListener('click', e => {
    e.preventDefault();
    const tr = e.target.closest('tr');
    const id = parseInt(tr.dataset.id, 10);
    const nombre = tr.dataset.nombre;
    const precio = parseFloat(tr.dataset.precio);
    const max = parseInt(tr.dataset.stock, 10);
    const qtyInput = tr.querySelector('input.qty');
    let cant = parseInt(qtyInput.value, 10) || 1;
    cant = Math.max(1, Math.min(max, cant));

    if (max <= 0) {
      alert('Sin stock disponible');
      return;
    }

    const found = cart.find(x => x.idproducto === id);
    if (found) {
      found.cantidad = Math.min(found.cantidad + cant, max);
    } else {
      cart.push({ idproducto: id, nombre, cantidad: cant, precio, max });
    }
    renderCart();
  });
});

/* --- util: escape para seguridad (paranoia extra) --- */
function escapeHtml(s){
  return (s+'').replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
}

/* --- init --- */
renderCart();
</script>
</body>
</html>
