
(0..31).to_a.each do |tick|
  (0..3).to_a.each do |frac|
    key = (tick/32.0).round(8)
    if frac == 0
      frac = ''
      mini = 0
    end
    if frac == 1
      frac = '2'
      mini = (1/32.0 * 0.25)
    end
    if frac == 2
      frac = '5'
      mini = (1/32.0 * 0.5)
    end
    if frac == 3
      frac = '7'
      mini = (1/32.0 * 0.75)
    end
    key = (key + mini).to_s
    tick_str = (tick < 10) ? '0' + tick.to_s : tick.to_s
    puts "#{key} => \'#{tick_str}#{frac}\',"
  end
end
