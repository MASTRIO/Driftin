import boxy, opengl, windy, netty, flatty, vmath, std/strutils, std/strformat

type
  Player = object
    position, velocity: Vec2
  
  Packet = object
    id: int
    packet_type: string
    packet_data: string

# create client and connect to the server
var
  ip = "127.0.0.1"
  port = 1999

  client = newReactor()
  c2s = client.connect(ip, port)

let client_id = 1
var this_player: Player = Player(
  position: Vec2(),
  velocity: Vec2()
)
this_player.position.x = 100
this_player.position.y = 100

let window_size = ivec2(600, 300)
let window = newWindow("nim client test", window_size)
makeContextCurrent(window)

loadExtensions()

let bxy = newBoxy()

bxy.addImage("player", readImage("assets/sprites/why_he_green_tho.png"))

var frame: int

proc displayLoop() =
  # Start frame
  bxy.beginFrame(window_size)

  # Update client
  client.tick()

  # Update player position on all clients
  client.send(c2s, Packet(id: client_id, packet_type: "player_position", packet_data: fmt"{this_player.position.x},{this_player.position.y}").toFlatty())

  # Loop though server messages
  for msg in client.messages:
    var message_data: Packet = msg.data.fromFlatty(Packet)

    if message_data.packet_type == "player_position":
      var network_pos = Vec2()
      var split_data = message_data.packet_data.split(",")
      network_pos.x = parseFloat(split_data[0])
      network_pos.y = parseFloat(split_data[1])

      bxy.drawImage("player", network_pos, angle = frame.float / 100)

  # End frame
  bxy.endFrame()
  window.swapBuffers()
  inc frame

while not window.closeRequested:
  displayLoop()
  pollEvents()