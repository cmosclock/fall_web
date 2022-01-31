def tick args
  args.state.score ||= 0
  args.state.game_state ||= :initial


  gravity = 1
  max_accel_x = (20 * ((args.state.score + 6) * 2.1)).clamp(-1000, 1000)
  max_accel_y = (20 * ((args.state.score + 6) * 0.1)).clamp(-1000, 30)
  sprite_height = scored_sprite_height args.state.score
  sprite_width = scored_sprite_width args.state.score

  spawn_y = args.grid.h / 2 - sprite_height / 2
  spawn_x = args.grid.w / 2 - sprite_width / 2
  args.state.sprite_y ||= spawn_y
  args.state.sprite_x ||= spawn_x

  # cap velocity y
  args.state.velocity_y ||= 0
  if args.state.game_state != :initial
    args.state.velocity_y -= gravity
  end
  args.state.velocity_y = args.state.velocity_y.clamp(-1 * max_accel_y, max_accel_y)
  args.state.sprite_y += args.state.velocity_y

  # cap velocity x
  args.state.velocity_x ||= 0
  args.state.velocity_x = args.state.velocity_x.clamp(-1 * max_accel_x, max_accel_x)
  args.state.sprite_x += args.state.velocity_x

  # bound check
  if !args.state.sprite_y.between?(args.grid.bottom, args.grid.top - sprite_height + 200)
    args.state.sprite_y = args.state.sprite_y.clamp(args.grid.bottom, args.grid.top - sprite_height + 200)
    args.state.velocity_y = (args.state.velocity_y / 2) * -1
    args.state.velocity_x /= 2
    args.state.game_state = :lost
  end
  if !args.state.sprite_x.between?(args.grid.left, args.grid.right - sprite_width)
    args.state.sprite_x = args.state.sprite_x.clamp(args.grid.left, args.grid.right - sprite_width)
    args.state.velocity_x = (args.state.velocity_x / 2) * -1
    args.state.game_state = :lost
  end

  # debug hold
  # if args.inputs.mouse.button_left
  #   args.state.sprite_y = args.inputs.mouse.y - sprite_height / 2
  # end
  sprite_rect = [args.state.sprite_x, args.state.sprite_y, sprite_width, sprite_height]
  args.state.rotate ||= 0
  args.state.rotate += 0.1
  rotation = args.state.game_state == :lost ? 180 : (args.state.game_state == :running ? Math.sin(args.state.rotate) * 10 : 0)
  animal_color = args.state.game_state == :lost ? [99, 99, 99] : [255, 255, 255]
  text = args.state.game_state == :running ? "[ #{args.state.score} ]" : (args.state.game_state == :lost ? "High Score: #{args.state.score}" : 'Click Anywhere to Start')
  if args.inputs.mouse.click
    if args.state.game_state == :initial
      args.state.game_state = :running
      args.state.score = 0
    end
    if args.state.game_state == :running
      if args.inputs.mouse.inside_rect? sprite_rect
        # fix up coord with new scale
        args.state.score += 1
        args.state.sprite_x += sprite_width / 2 - scored_sprite_width(args.state.score) / 2
        args.state.sprite_y += sprite_height / 2 - scored_sprite_height(args.state.score) / 2
        args.state.velocity_y += 100
        args.state.velocity_x += ((args.state.sprite_x + scored_sprite_width(args.state.score) / 2) - args.inputs.mouse.x) * (0.03 * args.state.score)
      end
    end
    if args.state.game_state == :lost && args.state.sprite_y == args.grid.bottom
      args.state.game_state = :initial
      args.state.sprite_y = args.grid.h / 2 - scored_sprite_height(0) / 2
      args.state.sprite_x = args.grid.w / 2 - scored_sprite_width(0) / 2
      args.state.velocity_y = 0
      args.state.velocity_x = 0
      args.state.score = 0
      args.state.score = 0
    end
  end
  
  args.outputs.background_color = [29, 31, 33]
  args.outputs.primitives << [640, 600, text, 30, 1, [255, 255, 255]].label
  args.outputs.primitives << [sprite_rect, 'sprites/animal.png', rotation, 255, animal_color].sprite
end

def scored_sprite_height score
  604 / 2 * (1 / (score * 0.05 + 1))
end

def scored_sprite_width score
  866 / 2 * (1 / (score * 0.05 + 1))
end

$gtk.reset