import netty, fidget, std/json

# Create server
var
  ip = "127.0.0.1"
  port = 1999

  server = newReactor(ip, port)

echo "Server online at ", ip, ":", port

# Server update loop
while true:
  # Update server
  server.tick()

  for connection in server.newConnections:
    echo "Player ip ", connection.address, " has connected"
  for connection in server.deadConnections:
    echo "Player ip ", connection.address, " has disconnected"

  # Loop though any messages the server has received from clients
  for msg in server.messages:
    # Yeet that data straight to every connected client
    # TODO: replace this with a much less hackable system
    for connection in server.connections:
      server.send(connection, msg.data)