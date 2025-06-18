$listener = New-Object System.Net.HttpListener
$url = "http://localhost:8080/"
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Server started. Listening on ${url}"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $html = "<html><body><h1>Hello from PowerShell!</h1></body></html>"
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.Close()
}

$listener.Stop()
$listener.Close()