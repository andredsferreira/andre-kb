from socket import *

server_name = "localhost"
server_port = 12000

client_sock = socket(AF_INET, SOCK_DGRAM)

msg = input("Input lowercase setence: ")

client_sock.sendto(msg.encode(),(server_name, server_port))

modified_msg, server_address = client_sock.recvfrom(2048)

print(modified_msg.decode())

client_sock.close()