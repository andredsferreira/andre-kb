from socket import *

server_port = 12000

server_sock = socket(AF_INET,SOCK_STREAM)
server_sock.bind(("",server_port))

# Server keeps listening on the connection sock
server_sock.listen(1)

print("The server is ready to receive")

# Server processes specific request by creating a connection sock
while True:
  conn_sock, addr = server_sock.accept()
  print(f"Connection sock established: {conn_sock}")
  print(f"Received from: {addr}")

  sentence = conn_sock.recv(1024).decode()
  capitalized_setence = sentence.upper()
  conn_sock.send(capitalized_setence.encode())

  conn_sock.close()