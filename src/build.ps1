# Builds the deployable page from src/doremi_src.html.
#   index.html        — standalone page served by GitHub Pages (repo root)
#   dist/doremi.html  — same page without the document skeleton, for publishing as a Claude artifact
# The piano samples in src/samples are embedded as base64 so the page needs no other files.
$src  = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $src
$utf8 = New-Object Text.UTF8Encoding($false)
$page = [IO.File]::ReadAllText("$src\doremi_src.html", [Text.Encoding]::UTF8)

$parts = foreach($n in 'C4','Ds4','Fs4','A4','C5','Ds5','Fs5','A5','C6'){
  $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$src\samples\$n.mp3"))
  "`"$n`":`"$b64`""
}
$json = '{' + ($parts -join ',') + '};'
$marker = '{};/*@@PIANO_SAMPLES@@*/'
if(-not $page.Contains($marker)){ throw 'sample marker not found' }
$built = $page.Replace($marker, $json)

New-Item -ItemType Directory -Force "$root\dist" | Out-Null
[IO.File]::WriteAllText("$root\dist\doremi.html", $built, $utf8)

$i = $built.IndexOf('</style>') + '</style>'.Length
$head = $built.Substring(0, $i)
$body = $built.Substring($i).TrimStart()
$out = "<!DOCTYPE html>`n<html lang=`"ko`">`n<head>`n<meta charset=`"utf-8`">`n<meta name=`"viewport`" content=`"width=device-width, initial-scale=1, viewport-fit=cover`">`n" + $head + "`n<style>html,body{margin:0}[hidden]{display:none!important}img{max-width:100%}</style>`n</head>`n<body>`n" + $body + "`n</body>`n</html>`n"
[IO.File]::WriteAllText("$root\index.html", $out, $utf8)

Get-Item "$root\index.html", "$root\dist\doremi.html" | Select-Object Name, Length
