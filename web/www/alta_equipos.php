<?php
require 'db.php';

$competiciones = $pdo->query("SELECT * FROM competiciones")->fetchAll();

$mensaje = null;

if ($_POST) {
    $codigo_hex = strtoupper($_POST['codigo_hex']);
    $nombre     = $_POST['nombre'];
    $comp_id    = $_POST['competicion'];

    // Validar hex 6 chars
    if (!preg_match('/^[0-9A-F]{6}$/', $codigo_hex)) {
        $mensaje = "❌ Código hexadecimal inválido";
    } else {
        $stmt = $pdo->prepare(
            "INSERT INTO equipos (codigo_hex, nombre, competicion_id)
             VALUES (?, ?, ?)"
        );
        $stmt->execute([$codigo_hex, $nombre, $comp_id]);

        $mensaje = "✅ Equipo creado correctamente";
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Alta de equipos</title>
    <link rel="stylesheet" href="css/estilos.css">
</head>
<body>
    <?php include 'menu.php'; ?>
    <div class="container small">
        <h1>Alta de equipos</h1>

        <?php if ($mensaje): ?>
            <div class="alert">
                <?= htmlspecialchars($mensaje) ?>
            </div>
        <?php endif; ?>

        <form method="post" class="form-panel">
            <label>
                Código hexadecimal
                <input name="codigo_hex" maxlength="6" placeholder="Ej: FA33DD" required>
            </label>

            <label>
                Nombre del equipo
                <input name="nombre" required>
            </label>

            <label>
                Competición
                <select name="competicion">
                    <?php foreach ($competiciones as $c): ?>
                        <option value="<?= $c['id'] ?>">
                            <?= htmlspecialchars($c['nombre']) ?>
                        </option>
                    <?php endforeach ?>
                </select>
            </label>

            <button type="submit">Crear equipo</button>
        </form>
    </div>
</body>
</html>
