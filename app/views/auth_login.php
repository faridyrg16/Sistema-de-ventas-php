<?php require_once __DIR__ . '/../lib/util.php'; ?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Login</title>
  <link rel="stylesheet" href="assets/styles.css">
  <style>
    body {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      background: #f5f5f5;
      margin: 0;
      font-family: Arial, sans-serif;
    }
    .login-card {
      background: white;
      padding: 30px;
      border-radius: 12px;
      box-shadow: 0 4px 10px rgba(0,0,0,0.15);
      width: 320px;
      text-align: center;
    }
    .login-card h2 {
      margin-bottom: 20px;
    }
    .login-card input {
      width: 100%;
      padding: 10px;
      margin: 8px 0;
      border: 1px solid #ccc;
      border-radius: 6px;
    }
    .login-card button {
      width: 100%;
      padding: 10px;
      margin: 8px 0;
      border: none;
      border-radius: 6px;
      background: #007bff;
      color: white;
      font-size: 16px;
      cursor: pointer;
    }
    .login-card button:hover {
      background: #0056b3;
    }
  </style>
</head>
<body>
  <div class="login-card">
    <h2>Ingreso al sistema</h2>
    <?php if(!empty($error)):?>
      <p class='err'><?=h($error)?></p>
    <?php endif;?>
    <form method='post'>
      <input type='hidden' name='csrf' value='<?=csrf_token()?>'>
      <label>Usuario <input name='usuario' required></label><br><br>
      <label>Contraseña <input type='password' name='password' required></label><br><br>
      <button class='btn'>Ingresar</button>
    </form>
  </div>
</body>
</html>
