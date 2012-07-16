class Polly::Env < Hash
  include Polly::Common

  def initialize(env = {})
    Math.singleton_methods.each do |m|
      self[m.to_sym] = lambda { |*args| Math.send(m, *args) }
    end

    env.each { |name, expr| self[name] = Sexpr.build(expr, self) }
  end

  def clean
    Env[self.select { |name, expr| expr.is_a?(Sexpr) }]
  end

  def values
    clean.inject({}) { |h, (name, expr)| h[name] = expr.value; h }
  end

  def values!
    clean.inject({}) { |h, (name, expr)| h[name] = expr.value!; h }
  end

  def atomic_variables
    clean.select { |name, expr| expr.atomic? }.keys
  end

  def defined_variables
    clean.select { |name, expr| expr.atomic? && expr.defined? }.keys
  end

  def undefined_variables
    clean.select { |name, expr| expr.atomic? && !expr.defined? }.keys
  end

# printing  and conversion

  def print(opts = {}); puts to_s(opts) end
  def to_s(opts = {}); clean.map { |(k,v)| "#{k.inspect} => #{v.to_s(opts)}" }.join("\n") end
  def to_yaml(*args); dump.to_yaml(*args) end

  def ==(env)
    env.is_a?(Hash) ? Hash[self.clean] == Hash[env.clean] : false
  end

private

  def dump
    clean.inject({}) { |h, (name, expr)| h[name] = expr.to_ary; h }
  end

end
