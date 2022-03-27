import netty

# create client and connect to the server
var
  ip = "127.0.0.1"
  port = 1999

  client = newReactor()
  c2s = client.connect(ip, port)

#client.send(c2s, "hi")

# Client loop
while true:
  # Update client
  client.tick()

  # Loop though server messages
  for msg in client.messages:
    # print message data
    echo "GOT MESSAGE: ", msg.data