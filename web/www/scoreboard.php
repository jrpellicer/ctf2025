<?php
require 'db.php';

$competiciones = $pdo->query("SELECT * FROM competiciones")->fetchAll();
$equipos = [];

if (isset($_GET['comp'])) {
    $stmt = $pdo->prepare(
        "SELECT nombre, codigo_hex, puntos
         FROM equipos
         WHERE competicion_id = ?
         ORDER BY puntos DESC, nombre ASC"
    );
    $stmt->execute([$_GET['comp']]);
    $equipos = $stmt->fetchAll();
}
?>

<form method="get">
    Competición:
    <select name="comp">
        <?php foreach ($competiciones as $c): ?>
            <option value="<?= $c['id'] ?>">
                <?= htmlspecialchars($c['nombre']) ?>
            </option>
        <?php endforeach ?>
    </select>
    <button>Ver clasificación</button>
</form>

<?php if ($equipos): ?>
    <h2>Clasificación</h2>
    <table border="1">
        <tr>
            <th>#</th>
            <th>Equipo</th>
            <th>Código</th>
            <th>Puntos</th>
        </tr>
        <?php foreach ($equipos as $i => $e): ?>
        <tr>
            <td><?= $i+1 ?></td>
            <td><?= htmlspecialchars($e['nombre']) ?></td>
            <td><?= $e['codigo_hex'] ?></td>
            <td><?= $e['puntos'] ?></td>
        </tr>
        <?php endforeach ?>
    </table>
<?php endif ?>