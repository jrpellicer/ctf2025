<?php
require 'db.php';

$competiciones = $pdo->query("SELECT * FROM competiciones")->fetchAll();

if ($_POST) {
    $codigo_hex = strtoupper($_POST['codigo_hex']);
    $comp_id    = $_POST['competicion'];

    // Validar hex 8 chars
    if (!preg_match('/^[0-9A-F]{8}$/', $codigo_hex)) {
        die("Código hexadecimal inválido");
    }

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
        die("Reto no válido");
    }

    // Incrementar puntos del equipo
    $stmt = $pdo->prepare(
        "UPDATE equipos
         SET puntos = puntos + ?
         WHERE codigo_hex = ? AND competicion_id = ?"
    );
    $stmt->execute([$puntos, $equipo, $comp_id]);

    if ($stmt->rowCount() === 0) {
        die("Equipo no encontrado");
    }

    echo "OK: $puntos puntos añadidos al equipo $equipo";

}
?>

<form method="post">
    Código hex (8): <input name="codigo_hex" required><br>

    Competición:
    <select name="competicion">
        <?php foreach ($competiciones as $c): ?>
            <option value="<?= $c['id'] ?>">
                <?= htmlspecialchars($c['nombre']) ?>
            </option>
        <?php endforeach ?>
    </select><br>

    <button>Completar Fase</button>
</form>