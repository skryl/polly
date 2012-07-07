class BasicObject

  # this shit is meta
  def metaclass; class << self; self; end; end
  def meta_eval &blk; metaclass.instance_eval &blk; end

end

class Object

  def to_sexpr
    Polly::Sexpr.build(self)
  end

end
