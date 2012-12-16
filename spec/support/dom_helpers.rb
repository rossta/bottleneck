module DomHelpers
  def dom_id(object)
    "#{object.class.name.underscore}_#{object.id}"
  end
end
