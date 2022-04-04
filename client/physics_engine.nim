import boxy

proc process_velocity*(position, velocity: Vec2, speed: float): Vec2 =
  var new_vec = velocity
  new_vec.x = new_vec.x * speed
  new_vec.y = new_vec.y * speed

  return position + new_vec