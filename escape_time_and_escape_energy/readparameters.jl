using ArgParse

function parse_commandline()
  s = ArgParseSettings()

  @add_arg_table s begin
    "t_initial"
    help = "a positional argument"
    required = true

    "t_max"
    help = "a positional argument"
    required = true

    "radiusdisk"
    help = "a positional argument"
    required = true

    "massdisk"
    help = "a positional argument"
    required = true

    "velocitydisk"
    help = "a positional argument"
    required = true

    "Lx1"
    help = "a positional argument"
    required = true

    "Ly1"
    help = "a positional argument"
    required = true

    "windowsize"
    help = "a positional argument"
    required = true

    "massparticle"
    help = "a positional argument"
    required = true

    "size_x"
    help = "a positional argument"
    required = true

    "size_y"
    help = "a positional argument"
    required = true


    "velocityparticle"
    help = "a positional argument"
    required = true

    "vnewdisk"
    help = "a positional argument"
    required = true

    "radius"
    help = "a positional argument"
    required = true

    "nofrealizations"
    help = "a positional argument"
    required = true


  end

  return parse_args(s)
end

k = open()

parsed_args = parse_commandline()
println("Parsed args:")
for (arg,val) in parsed_args
  println("  $arg  =>  $val")
end


