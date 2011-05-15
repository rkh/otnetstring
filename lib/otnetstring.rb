require 'stringio'

module OTNetstring
  def self.parse(io)
    io = StringIO.new(io) if io.respond_to? :to_str
    length, byte = "", "0"
    while byte =~ /\d/
      length << byte
      byte = io.read(1)
    end
    length = length.to_i
    case byte
    when '#' then Integer io.read(length)
    when ',' then io.read(length)
    when '~' then nil
    when '!' then io.read(length) == 'true'
    when '[', '{'
      array = []
      start = io.pos
      array << parse(io) while io.pos - start < length
      byte == "{" ? Hash[*array] : array
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
    else fail 'cannot encode %p' % obj
    end
  end
end
