class Polly::Context < BasicObject
  include ::Polly::Common
  include ::Kernel

  def initialize(env)
    @env = env
    @env.clean.each { |name, expr| var_reader name.to_sym }
  end

  def evaluate(proc)
    instance_eval(&proc) if proc
  end

  def var(name, val = nil, opts = {})
    if @env[name]  
      @env[name].replace(val) 
    else
      @env[name] = Sexpr.build(val, @env, name)
    end

    var_reader name
  end

  def Sexpr(val)
    Polly::Sexpr.build(val, @env)
  end

  alias_method :const, :var
  alias_method :eq, :var

# magix

  # convert method calls on self to s-expressions
  # 
  def method_missing(method, *args, &block)
    Sexpr.build([method, *args], @env)
  end

  def self.const_missing(name)
    ::Object.const_get(name)
  end

private

  def var_reader(name)
    define_singleton_method(name) { @env[name] }
  end

end
