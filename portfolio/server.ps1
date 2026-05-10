$port = 8080
$root = "e:\Web Dev\portfolio"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving HTTP on 0.0.0.0 port $port (http://localhost:$port/) ..."

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $requestUrl = $context.Request.Url.LocalPath
        if ($requestUrl -eq "/") { $requestUrl = "/index.html" }
        $filePath = Join-Path $root $requestUrl.Replace("/", "\")
        
        $response = $context.Response
        if (Test-Path $filePath -PathType Leaf) {
            $buffer = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $buffer.Length
            
            # Basic mime types
            if ($filePath.EndsWith(".html")) { $response.ContentType = "text/html; charset=utf-8" }
            elseif ($filePath.EndsWith(".css")) { $response.ContentType = "text/css; charset=utf-8" }
            elseif ($filePath.EndsWith(".js")) { $response.ContentType = "application/javascript; charset=utf-8" }
            
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
