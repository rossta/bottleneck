  DateCount = Struct.new(:date, :count) do
    def x; date.to_time.to_i; end
    def y; (count || 0).to_i; end
    def data; { x: x, y: y }; end
  end
