import boxy, opengl, windy, netty, vmath, std/strutils, std/strformat, std/random
import physics_engine

type
  Player = object
    position, velocity: Vec2
    speed: float
  
  NetworkedPlayerData = object
    id: int
    position, velocity: Vec2

# create client and connect to the server
var
  ip = "127.0.0.1"
  port = 1999

  client = newReactor()
  c2s = client.connect(ip, port)

randomize()
var client_id = rand(1..10000000)
echo "client id: ", client_id

var this_player: Player = Player(
  position: Vec2(),
  velocity: Vec2(),
  speed: 1.0
)
randomize()
this_player.position.x = rand(300.0)
randomize()
this_player.position.y = rand(200.0)

var network_players = @[NetworkedPlayerData(id: client_id, position: this_player.position, velocity: this_player.velocity)]

let window_size = ivec2(600, 300)
let window = newWindow("nim client test", window_size)
makeContextCurrent(window)

loadExtensions()

let bxy = newBoxy()

bxy.addImage("player", readImage("assets/sprites/why_he_green_tho.png"))

var frame: int

# Create packet to send to server
proc create_packet(id: int, packet_type: string, packet_data: string): string =
  return intToStr(id) & "||" & packet_type & "||" & packet_data

# Processes server connection data
proc clientProcess() =
  # Update client
  client.tick()

  # Update player position on all clients
  client.send(c2s, create_packet(client_id, "player_position", fmt"{this_player.position.x},{this_player.position.y}|{this_player.velocity.x},{this_player.velocity.y}"))

  # Loop though server messages
  for msg in client.messages:
    var message_data = msg.data.split("||")

    if message_data[1] == "player_position":
      var split_data = message_data[2].split("|")
      let split_pos = split_data[0].split(",")
      let split_vel = split_data[1].split(",")

      var player_in_list = false
      var player_counter = 0
      for net_player in network_players:
        if net_player.id == parseInt(message_data[0]):
          player_in_list = true

          var network_pos = Vec2()
          network_pos.x = parseFloat(split_pos[0])
          network_pos.y = parseFloat(split_pos[1])

          var network_vel = Vec2()
          network_vel.x = parseFloat(split_vel[0])
          network_vel.y = parseFloat(split_vel[1])

          network_players[player_counter].position = network_pos
          network_players[player_counter].velocity = network_vel

          break
        inc player_counter

      if not player_in_list:
        var network_pos = Vec2()
        network_pos.x = parseFloat(split_pos[0])
        network_pos.y = parseFloat(split_pos[1])

        var network_vel = Vec2()
        network_vel.x = parseFloat(split_vel[0])
        network_vel.y = parseFloat(split_vel[1])

        var network_player = NetworkedPlayerData(
          id: parseInt(message_data[0]),
          position: network_pos,
          velocity: network_vel
        )

        network_players.add(network_player)

  # Process client side physics
  this_player.position = process_velocity(this_player.position, this_player.velocity, this_player.speed)
  this_player.velocity = Vec2()

  # Player movement
  this_player.velocity.y += 1

# Render display
proc drawDisplay() =
  # Start frame
  bxy.beginFrame(window_size)

  # Render players
  for net_player in network_players:
    bxy.drawImage("player", net_player.position, angle = frame.float / 100)
  
  # End frame
  bxy.endFrame()
  window.swapBuffers()
  inc frame

# Procedure loop
while not window.closeRequested:
  clientProcess()
  drawDisplay()
  pollEvents()