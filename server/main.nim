import netty

# Create server
var
  ip = "127.0.0.1"
  port = 1999

  server = newReactor(ip, port)

# Server update loop
while true:
  # Update server
  server.tick()

  # Loop though any messages the server has received from clients
  for msg in server.messages:
    # print message data
    echo "GOT MESSAGE: ", msg.data
    # echo message back to the client
    server.send(msg.conn, "you said:" & msg.data)