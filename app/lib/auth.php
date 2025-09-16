<?php
// app/lib/auth.php
declare(strict_types=1);

require_once __DIR__ . '/session.php'; // aquí se abre la sesión, una sola vez
require_once __DIR__ . '/db.php';

function current_user(): ?array {
    return $_SESSION['user'] ?? null;
}

function is_logged_in(): bool {
    return !empty($_SESSION['user']);
}

function is_admin(): bool {
    return (current_user()['rol'] ?? '') === 'ADMIN';
}

function require_login(): void {
    if (!is_logged_in()) {
        header('Location: index.php?r=auth/login&msg=login_required');
        exit;
    }
}

function login(string $usuario, string $password): bool {
    $pdo = DB::pdo();

    $st = $pdo->prepare(
        'SELECT idVendedor, nombre, usuario, contrasena_hash, rol
         FROM vendedor
         WHERE usuario = ?'
    );
    $st->execute([$usuario]);
    $u = $st->fetch();

    if (!$u) return false;

    $hash = (string)($u['contrasena_hash'] ?? '');
    $ok = false;

    // Bcrypt
    if ($hash !== '' && preg_match('/^\$2[ayb]\$/', $hash)) {
        $ok = password_verify($password, $hash);
    }
    // Fallback SHA-256 (hex legado)
    if (!$ok && $hash !== '' && preg_match('/^[0-9a-f]{64}$/i', $hash)) {
        $ok = hash_equals(strtolower($hash), hash('sha256', $password));
    }
    if (!$ok) return false;

    // Marca asistencia
    $as = $pdo->prepare("
        INSERT INTO asistencia (idVendedor, login_ts)
        VALUES (?, NOW())
        ON DUPLICATE KEY UPDATE login_ts = VALUES(login_ts)
    ");
    $as->execute([$u['idVendedor']]);

    // Guarda usuario en sesión
    $_SESSION['user'] = [
        'id'      => (int)$u['idVendedor'],
        'nombre'  => (string)$u['nombre'],
        'usuario' => (string)$u['usuario'],
        'rol'     => (string)$u['rol'],
    ];

    // Anti fixation
    if (session_status() === PHP_SESSION_ACTIVE) {
        session_regenerate_id(true);
    }

    return true;
}

function logout(): void {
    $_SESSION = [];
    if (session_status() === PHP_SESSION_ACTIVE) {
        if (ini_get('session.use_cookies')) {
            $p = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $p['path'], $p['domain'], $p['secure'], $p['httponly']);
        }
        session_destroy();
    }
}

function redirect_to(string $r): void {
    header('Location: index.php?r=' . $r);
    exit;
}
