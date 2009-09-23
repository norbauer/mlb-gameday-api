class MLBAPI::Model < MLBAPI::Base

  def initialize(attributes = {})
    @attributes = attributes
  end

private

  # roughly, this sets up an openstruct-like model
  def method_missing(sym, *args, &block)
    if args.empty? && block.nil? && sym !~ /[\!\?\=]$/ && @attributes.has_key?(sym.to_s)
      create_attr_reader(sym)
      send(sym)
    elsif args.size == 1 && block.nil? && sym =~ /\=$/
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
    self.class.class_eval do
      define_method(sym) do |*args|
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1)" unless args.size == 1
        @attributes[sym.to_s] = args.first
      end
    end
  end

end
