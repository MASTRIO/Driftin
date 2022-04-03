import netty, std/strutils, std/random

# Create server
var
  ip = "127.0.0.1"
  port = 1999

  server = newReactor(ip, port)

echo "Server online at ", ip, ":", port

var used_client_ids = @[0]

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
    var message_data = msg.data.split("||")

    if message_data[1] == "new_player":
      var choosing_client_id = true
      var test_client_id = 0
      while choosing_client_id:
        randomize()
        test_client_id = rand(1..100000)
        if not test_client_id in used_client_ids:
          choosing_client_id = false
          used_client_ids.add(test_client_id)
      server.send(msg.conn, "set_client_id||" & intToStr(test_client_id))

    # Yeet that data straight to every connected client
    # TODO: replace this with a much less hackable system
    for connection in server.connections:
      server.send(connection, msg.data)