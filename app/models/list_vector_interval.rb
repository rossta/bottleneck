require "matrix"

# List is an array of Lists
class ListVectorInterval < ListInterval
  alias_method :lists, :list

  def counts
    @counts ||= begin
      require "matrix"
      lists.map { |l| Vector[*l.interval_counts(dates)] }.inject(&:+)
    end
  end

  def to_json
    {
      name: representative.role.titleize,
      data: data,
      position: representative.position
    }
  end

  def representative
    lists.last
  end

end
