class FieldErrorBuilder
  attr_accessor :fields, :nested

  def initialize
    self.fields = {}
    self.nested = {}
  end

  def add_message(field, message)
    if field.to_s.include?('.')
      path = field.to_s.split('.')
      name, index = get_name_and_index(path.first)

      nested[name] ||= []
      nested[name][index] ||= FieldErrorBuilder.new
      nested[name][index].add_message(path[1..-1].join('.'), message)
    else
      fields[field] ||= []
      fields[field] << message unless fields[field].include?(message)
    end
  end

  def set_nested(field, builders)
    nested[field] = builders
  end

  def move_errors_in_nested(nested_path, from_field, to_field)
    return move_errors(from_field, to_field) if nested_path.blank?

    nested_path = Array(nested_path)
    nested_field = nested_path.first
    return if nested[nested_field].blank?
    nested[nested_field].each do |nested_builder|
      next if nested_builder.nil?
      nested_builder.move_errors_in_nested(nested_path[1..-1], from_field, to_field)
    end
  end

  def move_errors(from_field, to_field)
    return if fields[from_field].blank?
    fields[from_field].each do |message|
      add_message(to_field, message)
    end
    fields.delete(from_field)
  end

  def remove_fields_not_in_input(request)
    request ||= NullRequest

    fields.each do |field, messages|
      if !request.has_key?(field)
        fields.delete(field)
      end
    end

    nested.each do |field, builders|
      nested_requests = Array(request[field])
      builders.each_with_index do |nested_builder, i|
        nested_builder.remove_fields_not_in_input(nested_requests[i])
      end
    end
  end

  def remove_fields(removees)
    removees.each do |field, value|
      if value.is_a?(Hash)
        Array(nested[field]).each do |builder|
          next if builder.blank?
          builder.remove_fields(value)
        end
      else
        fields.delete(field)
      end
    end
  end

  def to_h
    {
      fields: fields.map { |name, messages|
        {
          field: name,
          message: messages.compact.join(', ')
        }
      },
      nested: nested.map { |name, builders|
        {
          property: name,
          items: builders.map { |b| b&.to_h }
        }
      }
    }
  end

  def inspect
    "#<#{self.class.name}##{object_id}>"
  end

  def get_name_and_index(item)
    if item =~ /^(\w+)(\[(\d+)\])?$/
      [$1, $3.to_i]
    else
      item
    end
  end
end
