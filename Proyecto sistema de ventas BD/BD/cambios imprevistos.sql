
USE sistema_ventas;
ALTER TABLE asistencia
  MODIFY login_ts DATETIME NOT NULL;
ALTER TABLE asistencia
  ADD COLUMN login_date DATE
    AS (DATE(login_ts)) STORED;
ALTER TABLE asistencia
  ADD UNIQUE KEY ux_asistencia_user_day (idVendedor, login_date);
