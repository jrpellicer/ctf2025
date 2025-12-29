<?php
require 'db.php';

$mensaje = null;
$ok = false;

if ($_POST) {
    $codigo       = trim($_POST['codigo']);
    $nombre       = trim($_POST['nombre']);
    $fecha_inicio = $_POST['fecha_inicio'];
    $fecha_fin    = $_POST['fecha_fin'] ?: null;

    if (!$codigo || !$nombre || !$fecha_inicio) {
        $mensaje = "❌ Todos los campos obligatorios deben completarse";
    } elseif ($fecha_fin && $fecha_fin <= $fecha_inicio) {
        $mensaje = "❌ La fecha de fin debe ser posterior a la de inicio";
    } else {
        $stmt = $pdo->prepare(
            "INSERT INTO competiciones
             (codigo, nombre, fecha_inicio, fecha_fin, activa)
             VALUES (?, ?, ?, ?, 0)"
        );
        $stmt->execute([$codigo, $nombre, $fecha_inicio, $fecha_fin]);

        $mensaje = "✅ Competición creada correctamente";
        $ok = true;
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Alta de competición</title>
    <link rel="stylesheet" href="css/estilos.css">
</head>
<body>
    <div class="container small">
        <h1>Alta de competición</h1>

        <?php if ($mensaje): ?>
            <div class="alert <?= $ok ? 'success' : 'error' ?>">
                <?= htmlspecialchars($mensaje) ?>
            </div>
        <?php endif; ?>

        <form method="post" class="form-panel">
            <label>
                Código de competición
                <input name="codigo" required>
            </label>

            <label>
                Nombre de la competición
                <input name="nombre" required>
            </label>

            <label>
                Fecha y hora de inicio
                <input type="datetime-local" name="fecha_inicio" required>
            </label>

            <label>
                Fecha y hora de fin
                <input type="datetime-local" name="fecha_fin">
            </label>

            <button type="submit">Crear competición</button>
        </form>
    </div>
</body>
</html>
