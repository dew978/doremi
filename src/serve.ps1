# Minimal static server for local testing: serves the built index.html at http://localhost:8765/
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8765/')
$listener.Start()
while($listener.IsListening){
  $ctx = $listener.GetContext()
  $res = $ctx.Response
  if($ctx.Request.Url.AbsolutePath -eq '/'){
    $bytes = [IO.File]::ReadAllBytes("$root\index.html")
    $res.ContentType = 'text/html; charset=utf-8'
  } else {
    $bytes = [Text.Encoding]::UTF8.GetBytes('not found'); $res.StatusCode = 404
  }
  $res.ContentLength64 = $bytes.Length
  $res.OutputStream.Write($bytes, 0, $bytes.Length)
  $res.Close()
}
