<?php
require 'db.php';

$competiciones = $pdo->query("SELECT * FROM competiciones")->fetchAll();

if ($_POST) {
    $codigo_hex = strtoupper($_POST['codigo_hex']);
    $nombre     = $_POST['nombre'];
    $comp_id    = $_POST['competicion'];

    // Validar hex 6 chars
    if (!preg_match('/^[0-9A-F]{6}$/', $codigo_hex)) {
        die("Código hexadecimal inválido");
    }

    $stmt = $pdo->prepare(
        "INSERT INTO equipos (codigo_hex, nombre, competicion_id)
         VALUES (?, ?, ?)"
    );
    $stmt->execute([$codigo_hex, $nombre, $comp_id]);

    echo "Equipo creado";
}
?>

<form method="post">
    Código hex (6): <input name="codigo_hex" required><br>
    Nombre equipo: <input name="nombre" required><br>

    Competición:
    <select name="competicion">
        <?php foreach ($competiciones as $c): ?>
            <option value="<?= $c['id'] ?>">
                <?= htmlspecialchars($c['nombre']) ?>
            </option>
        <?php endforeach ?>
    </select><br>

    <button>Crear equipo</button>
</form>