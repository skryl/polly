class BasicObject

  # this shit is meta
  def metaclass; class << self; self; end; end
  def meta_eval &blk; metaclass.instance_eval &blk; end

  # Adds methods to a metaclass
  def meta_def( name, &blk )
    meta_eval { define_method name, &blk }
  end

  # Defines an instance method within a class
  def class_def( name, &blk )
    class_eval { define_method name, &blk }
  end

end

class Object

  def to_sexpr
    Polly::Sexpr.build(self)
  end

end
