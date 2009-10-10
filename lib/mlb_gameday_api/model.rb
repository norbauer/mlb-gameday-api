class MLBAPI::Model < MLBAPI::Base

  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
    # stringify xml node values
    stringify_xml_node_values(@attributes)
  end

  # override #id being an alias for #object_id
  def id
    @attributes['id']
  end

private

  def self.hash_attr_reader(*syms)
    syms.each do |sym|
      sym = sym.to_s
      define_method(sym) do |*args|
        raise ArgumentError, "wrong number of arguments (#{args.size} for 0)" unless args.size == 0
        @attributes[sym]
      end
    end
  end

  def self.hash_attr_writer(*syms)
    syms.each do |sym|
      method = sym.to_s[-1] == ?= ? sym.to_s : "#{sym}="
      attribute = method[0...-1]
      define_method(method) do |*args|
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1)" unless args.size == 1
        @attributes[attribute] = args.first
      end
    end
  end

  def self.hash_attr_accessor(*syms)
    hash_attr_reader(*syms)
    hash_attr_writer(*syms)
  end

  # turn { 'b' => '0' } into { 'balls' => 0 } by calling remap_hash(hsh, { 'b' => 'balls' })
  def remap_hash(lame_hash, mapping)
    mapping.inject(Hash.new) { |hsh, (k, v)| hsh[v] = lame_hash[k]; hsh }
  end

  def stringify_xml_node_values(hsh)
    hsh.each_pair { |k, v| hsh[k] = v.content if v.is_a?(Nokogiri::XML::Node) }
  end

end
