# Simple HTTP Server for Lightning Learning
     $listener = New-Object System.Net.HttpListener
     $listener.Prefixes.Add("http://*:8080/")
     $listener.Start()
     Write-Host "Server started. Access at http://localhost:8080/"
     Write-Host "Press Ctrl+C to stop the server."

     try {
         while ($listener.IsListening) {
             $context = $listener.GetContext()
             $request = $context.Request
             $response = $context.Response
             $url = $request.Url.LocalPath
             $rootPath = "C:\Users\jones\OneDrive\Desktop\lightning-learning"
             $filePath = Join-Path $rootPath ($url -replace "/", "\")

             # Serve index.html for root path
             if ($url -eq "/" -or $url -eq "") {
                 $filePath = Join-Path $rootPath "index.html"
             }

             # Set content types
             $contentType = "text/html"
             if ($filePath.EndsWith(".css")) { $contentType = "text/css" }
             elseif ($filePath.EndsWith(".js")) { $contentType = "application/javascript" }
             elseif ($filePath.EndsWith(".png")) { $contentType = "image/png" }

             # Serve file or 404
             if (Test-Path $filePath) {
                 $content = Get-Content $filePath -Raw -Encoding Byte
                 $response.ContentType = $contentType
                 $response.ContentLength64 = $content.Length
                 $response.OutputStream.Write($content, 0, $content.Length)
             } else {
                 $filePath = Join-Path $rootPath "404.html"
                 if (Test-Path $filePath) {
                     $content = Get-Content $filePath -Raw -Encoding Byte
                     $response.ContentType = "text/html"
                     $response.StatusCode = 404
                     $response.ContentLength64 = $content.Length
                     $response.OutputStream.Write($content, 0, $content.Length)
                 } else {
                     $response.StatusCode = 404
                     $message = "File not found"
                     $content = [System.Text.Encoding]::UTF8.GetBytes($message)
                     $response.ContentLength64 = $content.Length
                     $response.OutputStream.Write($content, 0, $content.Length)
                 }
             }
             $response.Close()
         }
     } finally {
         $listener.Stop()
         Write-Host "Server stopped."
     }