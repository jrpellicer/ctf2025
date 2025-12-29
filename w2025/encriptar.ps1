# Encriptar
$equipo="FA33DD"
$competicion="22"
$fase = "{0:X8}" -f ((($v=[Convert]::ToUInt32("$equipo$competicion",16)) -shl 11 -bor ($v -shr 21)) -band 0xFFFFFFFF)

# Desencriptar
$original = "{0:X8}" -f ((($v=[Convert]::ToUInt32($fase,16)) -shr 11 -bor ($v -shl 21)) -band 0xFFFFFFFF)
$equipo = $original.Substring(0,6)
$competicion = $original.Substring(6,2)
