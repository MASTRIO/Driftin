import fidget, fidget/opengl/base, netty, flatty, vmath, bumpy, std/json, std/lists, std/strutils, std/strformat

type
  Player = object
    position, velocity: Vec2
  
  Packet = object
    id: int
    packet_type: string
    packet_data: string

  NetworkedPlayerData = object
    id: int
    position: Vec2

# create client and connect to the server
var
  ip = "127.0.0.1"
  port = 1999

  client = newReactor()
  c2s = client.connect(ip, port)

let client_id = 1
let this_player: Player = Player(
  position: Vec2(),
  velocity: Vec2()
)

var network_players = initDoublyLinkedList[NetworkedPlayerData]()

#[
proc create_packet(id: int, packet_type: string, packet_data: array[10, string]): string =
  var json = %*
    [
      {
        "id": id,
        "packet_type": packet_type,
        "packet_data": packet_data
      }
    ]
  return $json
]#

# Used to draw stuff on screen
# Runs at monitor refresh rate (48-60 hz)
proc drawMain() =
  frame "main":
    box 0, 0, 620, 140
    #for i in 0 .. 4:
    #  group "block":
    #    box 20+i*120, 20, 100, 100
    #    fill "#2B9FEA"

# Client loop code
# runs every game tick (around 240 hz)
proc tickMain() =
  # Update client
  client.tick()

  # Update player position on all clients
  client.send(c2s, Packet(id: client_id, packet_type: "player_position", packet_data: fmt"{this_player.position.x},{this_player.position.y}").toFlatty())

  # Loop though server messages
  for msg in client.messages:
    var message_data: Packet = msg.data.fromFlatty(Packet)
    
    if message_data.packet_type == "player_position":
      var player_number = 0
      for networked_player in network_players:
        if networked_player.id == message_data.id:
          var setup_pos = Vec2()
          let coords = message_data.packet_data.split(",")
          setup_pos.x = parseFloat(coords[0])
          setup_pos.y = parseFloat(coords[1])
          network_players[player_number].position = setup_pos
        player_number += 1


    #[
    if message_data.packet_type == "player_position":
      var coords = message_data.packet_data.split(",")
      frame "main":
        group "block":
          box parseFloat(coords[0]), parseFloat(coords[1]), 100, 100
          fill "#2B9FEA"
    ]#

startFidget(
  draw = drawMain,
  tick = tickMain,
  w = 400,
  h = 400,
  openglVersion = (4, 1),
  msaa = msaa4x,
  mainLoopMode = RepaintSplitUpdate
)