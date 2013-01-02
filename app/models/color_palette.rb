class ColorPalette

  COLORS = %w[ #4572a7 #aa4643 #89a54e #80699b #3d96ae #db843d ].reverse

  def colors
    COLORS
  end

  def next
    colors.unshift(colors.pop).shift
  end
end
