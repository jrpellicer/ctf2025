<?php
require 'db.php';

$competiciones = $pdo->query("SELECT * FROM competiciones")->fetchAll();

$mensaje = null;
$ok = false;

if ($_POST) {
    $codigo_hex = strtoupper($_POST['codigo_hex']);
    $comp_id    = $_POST['competicion'];

    // Validar hex 8 chars
    if (!preg_match('/^[0-9A-F]{8}$/', $codigo_hex)) {
        $mensaje = "❌ Código hexadecimal inválido";
    } else {
        $v = hexdec($codigo_hex);

        // rotación derecha 11 bits (32 bits)
        $original = (($v >> 11) | ($v << 21)) & 0xFFFFFFFF;

        // formateo a 8 hex
        $originalHex = strtoupper(str_pad(dechex($original), 8, '0', STR_PAD_LEFT));

        // separación
        $equipo = substr($originalHex, 0, 6);
        $reto   = substr($originalHex, 6, 2);

        $stmt = $pdo->prepare(
            "SELECT puntos FROM retos WHERE codigo_hex = ?"
        );
        $stmt->execute([$reto]);

        $puntos = $stmt->fetchColumn();
        if ($puntos === false) {
            $mensaje = "❌ Reto no válido";
        } else {
            // Verificar si el equipo ya ha completado este reto en esta competición
            $stmt = $pdo->prepare(
                "SELECT COUNT(*) FROM completados WHERE equipo_hex = ? AND reto_hex = ? AND competicion_id = ?"
            );
            $stmt->execute([$equipo, $reto, $comp_id]);
            $yaCompletado = $stmt->fetchColumn() > 0;

            if ($yaCompletado) {
                $mensaje = "❌ Este reto ya ha sido validado por este equipo";
            } else {
                // Obtener fecha_inicio de la competición
                $stmt = $pdo->prepare(
                    "SELECT fecha_inicio FROM competiciones WHERE id = ?"
                );
                $stmt->execute([$comp_id]);
                $tz = new DateTimeZone('Europe/Madrid');
                $fechaInicio = new DateTime($stmt->fetchColumn(), $tz);

                $ahora = new DateTime();
                $ahora       = new DateTime('now', $tz);
                //$segundos = $ahora->getTimestamp() - $fechaInicio->getTimestamp();
                $segundos = max(0, $ahora->getTimestamp() - $fechaInicio->getTimestamp());


                // Incrementar puntos del equipo
                $stmt = $pdo->prepare(
                    "UPDATE equipos
                     SET
                        puntos = puntos + ?,
                        tiempo = ?
                     WHERE codigo_hex = ? AND competicion_id = ?"
                );
                $stmt->execute([$puntos, $segundos, $equipo, $comp_id]);

                if ($stmt->rowCount() === 0) {
                    $mensaje = "❌ Equipo no encontrado";
                } else {
                    // Registrar el reto completado
                    $stmt = $pdo->prepare(
                        "INSERT INTO completados (equipo_hex, reto_hex, competicion_id, tiempo) VALUES (?, ?, ?, ?)"
                    );
                    $stmt->execute([$equipo, $reto, $comp_id, $segundos]);

                    $mensaje = "✅ $puntos puntos añadidos al equipo $equipo";
                    $ok = true;
                }
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Completar reto</title>
    <link rel="stylesheet" href="css/estilos.css">
</head>
<body>
    <?php include 'menu.php'; ?>
    <div class="container small">
        <h1>Completar reto</h1>

        <?php if ($mensaje): ?>
            <div class="alert <?= $ok ? 'success' : 'error' ?>">
                <?= htmlspecialchars($mensaje) ?>
            </div>
        <?php endif; ?>

        <form method="post" class="form-panel">
            <label>
                Código hexadecimal (8)
                <input name="codigo_hex"
                       maxlength="8"
                       placeholder="Ej: A1B2C3D4"
                       required>
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

            <button type="submit">Completar reto</button>
        </form>
    </div>
</body>
</html>
