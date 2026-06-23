from socket import *

server_name = "localhost"
server_port = 12000

client_sock = socket(AF_INET, SOCK_STREAM)
client_sock.connect((server_name, server_port))

sentence = input("Input lowercase sentence:")
client_sock.send(sentence.encode())

modifiedSentence = client_sock.recv(1024)
print("From Server: ", modifiedSentence.decode())

client_sock.close()