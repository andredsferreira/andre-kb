# curl Command

| Command                                                                                       | Description                                                                                                                  |
| --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| curl -o filepath https://example.com                                                          | Saves the output of the URL to a specified filepath. Or downloads the file to the specified filepath if it's a file URL.     |
| curl -O http://speedtest.tele2.net/1MB.zip                                                    | Downloads a file from the URL to the current dir, the URL must be a valid file on the server, for example a .zip archive.    |
| curl -L https://example.com                                                                   | The -L option allows the follow of redirects if the link redirects to other pages.                                           |
| curl -Lo filepath https://example.com                                                         | Downloads a file from the URL to a specific filepath, following redirects.                                                   |
| curl -d "key1=a&key2=b" https://example.com                                                   | Sends a POST request composed of a body with data inside the string "". The -d option implicitly changes the method to POST. |
| curl -x METHOD https://example.com                                                            | Sends a specific METHOD (POST, GET, PATCH, etc) in the request.                                                              |
| curl -xv METHOD https://example.com                                                           | Adds the verbose flag including more detailed info of the request.                                                           |
| curl -d '{"key1":"a","key2":"b"}' -H "Content-Type: application/json" https://example.com/api | Send a POST request with JSON body |
