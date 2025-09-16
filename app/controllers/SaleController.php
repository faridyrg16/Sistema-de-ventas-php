<?php
require_once __DIR__.'/../lib/session.php';
require_once __DIR__.'/../lib/auth.php';
require_once __DIR__.'/../lib/db.php';
require_once __DIR__.'/../lib/util.php';

function sale_new(){
    require_login();
    $pdo = DB::pdo();
    $productos = $pdo->query('SELECT idproducto, nombre, precio, stock FROM producto ORDER BY nombre')->fetchAll();
    $clientes  = $pdo->query('SELECT dni, nombre FROM cliente ORDER BY nombre')->fetchAll();
    include __DIR__ . '/../views/sale_new.php';
}

function sale_confirm(){
    require_login();

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        header('Location: index.php?r=sale/new');
        exit;
    }

    $pdo  = DB::pdo();
    $dni  = $_POST['dniCliente'] ?? '00000000';
    $items = json_decode($_POST['items'] ?? '[]', true);

    if (!$items || !is_array($items)) {
        header('Location: index.php?r=sale/new');
        exit;
    }

    $pdo->beginTransaction();
    try {
        // 1) Crear venta
        $pdo->prepare('INSERT INTO venta(dniCliente, idVendedor, total) VALUES (?,?,0)')
            ->execute([$dni, current_user()['id']]);
        $vid   = (int)$pdo->lastInsertId();
        $total = 0.0;

        // 2) Insertar detalle y descontar stock (validando)
        foreach ($items as $it) {
            $pid   = (int)($it['idproducto'] ?? 0);
            $cant  = (int)($it['cantidad']   ?? 0);
            $punit = (float)($it['precio']   ?? 0);

            if ($pid <= 0 || $cant <= 0 || $punit < 0) {
                throw new Exception('Ítem inválido');
            }

            $stk = $pdo->prepare('SELECT stock FROM producto WHERE idproducto = ?');
            $stk->execute([$pid]);
            $disp = (int)$stk->fetchColumn();

            if ($disp < $cant) {
                throw new Exception('Stock insuficiente para producto '.$pid);
            }

            $sub = round($cant * $punit, 2);
            $total += $sub;

            $pdo->prepare('INSERT INTO detalle_venta(idventa, idproducto, cantidad, precio_unitario, subtotal)
                           VALUES (?,?,?,?,?)')
                ->execute([$vid, $pid, $cant, $punit, $sub]);

            $pdo->prepare('UPDATE producto SET stock = stock - ? WHERE idproducto = ?')
                ->execute([$cant, $pid]);
        }

        // 3) Actualizar total
        $pdo->prepare('UPDATE venta SET total = ? WHERE idventa = ?')->execute([$total, $vid]);

        $pdo->commit();

    } catch (Throwable $e) {
        $pdo->rollBack();
        http_response_code(400);
        echo 'Error en venta: ' . h($e->getMessage());
        return;
    }

    // === Elige el destino final ===
    $ABRIR_PDF_DIRECTO = true; // true => abre PDF; false => muestra la vista HTML

    if ($ABRIR_PDF_DIRECTO) {
        header('Location: index.php?r=report/pdf&vid=' . $vid);
    } else {
        header('Location: index.php?r=report/last&vid=' . $vid);
    }
    exit;
}
