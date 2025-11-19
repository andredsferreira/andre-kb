from socket import *

server_port = 12000

server_sock = socket(AF_INET, SOCK_DGRAM)
server_sock.bind(("", server_port))

print("The server is ready to receive")
      
while True:
  msg, client_address = server_sock.recvfrom(2048)
  print(f"Received from: {client_address}")
  
  modified_msg = msg.decode().upper()
  server_sock.sendto(modified_msg.encode(),client_address)