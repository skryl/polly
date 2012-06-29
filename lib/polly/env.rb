class Polly::Env < Hash
  include Polly::Common

  def initialize
    Math.singleton_methods.each do |m|
      self[m.to_sym] = lambda { |*args| Math.send(m, *args) }
    end
  end

  def set_var(name, val = nil, opts = {})
    if self[name]  
      self[name].replace(val) 
    else
      self[name] = Sexpr.build(val, self, name: name)
    end
  end

  def clean
    Context[self.select { |name, expr| expr.is_a?(Sexpr) }]
  end

  def atomic_variables
    clean.select { |name, expr| expr.atomic? }
  end

  def defined_variables
    clean.select { |name, expr| expr.atomic? && expr.defined? }
  end

  def undefined_variables
    clean.select { |name, expr| expr.atomic? && !expr.defined? }
  end

# printing  and conversion

  def print; puts to_s end
  def to_s; clean.map { |(k,v)| "#{k.inspect} => #{v.to_s}" }.join("\n") end

end
