from socket import *
import os

server_port = 8080  
server_socket = socket(AF_INET, SOCK_STREAM)
server_socket.bind(("", server_port))
server_socket.listen(1)

print(f"Listening on port {server_port}...")

while True:
    conn_socket, addr = server_socket.accept()
    print(f"Connection from: {addr}")

    try:
        request = conn_socket.recv(1024).decode()
        print(f"Request:\n{request}")

        if not request:
            conn_socket.close()
            continue

        request_line = request.splitlines()[0]  
        method, path, _ = request_line.split()

        if method != "GET":
            response = "HTTP/1.1 405 Method Not Allowed\r\n\r\nMethod Not Allowed"
            conn_socket.send(response.encode())
            conn_socket.close()
            continue

        # Remove leading slash
        filename = path.lstrip("/")

        if os.path.exists(filename) and os.path.isfile(filename):
            # Use reading in bytes mode, HTTP deals with raw bytes
            # since you might be serving images, videos, html, etc,
            # and not just text
            with open(filename, "rb") as f:
                content = f.read()
            header = "HTTP/1.1 200 OK\r\n"
            header += f"Content-Length: {len(content)}\r\n"
            header += "Content-Type: text/plain\r\n"
            header += "\r\n"
            conn_socket.send(header.encode() + content)
        else:
            response = "HTTP/1.1 404 Not Found\r\n\r\n404 Not Found"
            conn_socket.send(response.encode())

    except Exception as e:
        print(f"Error: {e}")
        response = "HTTP/1.1 500 Internal Server Error\r\n\r\nInternal Server Error"
        conn_socket.send(response.encode())

    conn_socket.close()
    