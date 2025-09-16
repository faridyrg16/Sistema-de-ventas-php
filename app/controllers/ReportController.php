<?php
// app/controllers/ReportController.php
require_once __DIR__ . '/../lib/session.php';
require_once __DIR__ . '/../lib/auth.php';
require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/util.php';
require_once __DIR__ . '/../lib/pdf.php'; // render_pdf()

/**
 * Muestra la venta en pantalla (vista HTML)
 */
function report_index(){
    require_login();

    $pdo = DB::pdo();

    // Traer últimas 50 ventas
    $ventas = $pdo->query(
        "SELECT v.idventa, v.fecha, v.total, c.nombre AS cliente
         FROM venta v
         LEFT JOIN cliente c ON c.dni = v.dniCliente
         ORDER BY v.fecha DESC
         LIMIT 50"
    )->fetchAll();

    // Traer top productos (si existe la vista)
    try {
        $top = $pdo->query("SELECT * FROM vw_top_productos LIMIT 10")->fetchAll();
    } catch (Throwable $e) {
        // fallback: calcular top productos directo
        $top = $pdo->query(
            "SELECT p.idproducto, p.nombre,
                    SUM(d.cantidad) AS total_cantidad,
                    SUM(d.subtotal) AS total_ventas
             FROM detalle_venta d
             LEFT JOIN producto p ON p.idproducto = d.idproducto
             GROUP BY p.idproducto, p.nombre
             ORDER BY total_cantidad DESC
             LIMIT 10"
        )->fetchAll();
    }

    include __DIR__ . '/../views/report_index.php';
}

function report_last(){
    require_login();

    $pdo = DB::pdo();
    $vid = (int)($_GET['vid'] ?? 0);

    $venta = $pdo->prepare(
        "SELECT v.idventa, v.fecha, v.total,
                c.nombre AS cliente, ve.nombre AS vendedor
         FROM venta v
         LEFT JOIN cliente  c  ON c.dni        = v.dniCliente
         LEFT JOIN vendedor ve ON ve.idVendedor = v.idVendedor
         WHERE v.idventa = ?"
    );
    $venta->execute([$vid]);
    $v = $venta->fetch();

    if (!$v) {
        http_response_code(404);
        echo 'Venta no encontrada';
        return;
    }

    $det = $pdo->prepare(
        "SELECT d.cantidad, d.precio_unitario, d.subtotal, p.nombre
         FROM detalle_venta d
         LEFT JOIN producto p ON p.idproducto = d.idproducto
         WHERE d.idventa = ?"
    );
    $det->execute([$vid]);
    $items = $det->fetchAll();

    include __DIR__ . '/../views/report_last.php';
}

/**
 * Genera PDF de la venta (Dompdf). Requiere dompdf instalado.
 */
function report_pdf(){
    require_login();

    $pdo = DB::pdo();
    $vid = (int)($_GET['vid'] ?? 0);

    $venta = $pdo->prepare(
        "SELECT v.idventa, v.fecha, v.total,
                c.nombre AS cliente, ve.nombre AS vendedor
         FROM venta v
         LEFT JOIN cliente  c  ON c.dni        = v.dniCliente
         LEFT JOIN vendedor ve ON ve.idVendedor = v.idVendedor
         WHERE v.idventa = ?"
    );
    $venta->execute([$vid]);
    $v = $venta->fetch();

    if (!$v) {
        http_response_code(404);
        echo 'Venta no encontrada';
        return;
    }

    $det = $pdo->prepare(
        "SELECT d.cantidad, d.precio_unitario, d.subtotal, p.nombre
         FROM detalle_venta d
         LEFT JOIN producto p ON p.idproducto = d.idproducto
         WHERE d.idventa = ?"
    );
    $det->execute([$vid]);
    $items = $det->fetchAll();

    // Render de la plantilla PDF a string y envío como PDF
    ob_start();
    include __DIR__ . '/../views/report_last_pdf.php';
    $html = ob_get_clean();

    render_pdf($html, 'venta_'.$vid.'.pdf', false); // false = mostrar en navegador
    // Nota: render_pdf() hace exit; no necesitas más abajo
}
// Fin de ReportController.php