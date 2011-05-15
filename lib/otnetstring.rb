require 'stringio'

module OTNetstring
  class Error < StandardError; end

  def self.parse(io)
    io = StringIO.new(io) if io.respond_to? :to_str
    length, byte = "", nil

    while byte.nil? || byte =~ /\d/
      length << byte if byte
      byte = io.read(1)
    end

    if length.size > 9
      raise Error, "#{length} is longer than 9 digits"
    elsif length !~ /\d+/
      raise Error, "Expected '#{byte}' to be a digit"
    end
    length = Integer(length)

    case byte
    when '#' then Integer io.read(length)
    when ',' then io.read(length)
    when '~' then raise Error, "nil has length of 0, #{length} given" unless length == 0
    when '!' then io.read(length) == 'true'
    when '[', '{'
      array = []
      start = io.pos
      array << parse(io) while io.pos - start < length
      raise Error, 'Nested element longer than container' if io.pos - start != length
      byte == "{" ? Hash[*array] : array
    else
      raise Error, "Unknown type '#{byte}'"
    end
  end

  def self.encode(obj, string_sep = ',')
    case obj
    when String   then "#{obj.length}#{string_sep}#{obj}"
    when Integer  then encode(obj.inspect, '#')
    when NilClass then "0~"
    when Array    then encode(obj.map { |e| encode(e) }.join, '[')
    when Hash     then encode(obj.map { |a,b| encode(a)+encode(b) }.join, '{')
    when FalseClass, TrueClass then encode(obj.inspect, '!')
    else raise Error, 'cannot encode %p' % obj
    end
  end
end
