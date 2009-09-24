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

  # Automatically sets up readers/writers, but only if they exist in @attributes.
  # The assumption here is that @attributes always has the same keys for each class, which *should* be true.
  def method_missing(sym, *args, &block)
    if args.empty? && block.nil? && ![?=, ?!, ??].include?(sym.to_s[-1]) && @attributes.has_key?(sym.to_s)
      create_attr_reader(sym)
      send(sym)
    elsif args.size == 1 && block.nil? && sym.to_s[-1] == ?= && @attributes.has_key?(sym.to_s)
      create_attr_writer(sym)
      send(sym, *args)
    else
      super
    end
  end

  def create_attr_reader(sym)
    self.class.class_eval do
      define_method(sym) do |*args|
        raise ArgumentError, "wrong number of arguments (#{args.size} for 0)" unless args.size == 0
        @attributes[sym.to_s]
      end
    end
  end

  def create_attr_writer(sym)
    sym = "#{sym}=" unless sym.to_s[-1] == ?=
    self.class.class_eval do
      define_method(sym) do |*args|
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1)" unless args.size == 1
        @attributes[sym.to_s[0...-1]] = args.first
      end
    end
  end

  # turn { 'b' => '0' } into { 'balls' => 0 } by calling remap_hash(hsh, { 'b' => 'balls' })
  def remap_hash(lame_hash, mapping)
    mapping.inject(Hash.new) { |hsh, (k, v)| hsh[v] = lame_hash[k]; hsh }
  end

  def stringify_xml_node_values(hsh)
    hsh.each_pair { |k, v| hsh[k] = v.content if v.is_a?(Nokogiri::XML::Node) }
  end

end
