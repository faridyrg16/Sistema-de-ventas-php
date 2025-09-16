SELECT idVendedor, contrasena_hash FROM vendedor WHERE usuario=?;
INSERT INTO asistencia(idVendedor, login_ts) VALUES (?, NOW());