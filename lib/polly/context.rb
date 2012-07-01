class Polly::Context < BasicObject
  include ::Polly::Common
  include ::Kernel

  def initialize(env)
    @env = env
  end

  def name(n)
    @name = n
  end

  def version(v)
    @version = v
  end

  def attribute(a)
    ivar = "@#{a}"
    instance_variable_defined?(ivar) && instance_variable_get(ivar)
  end

  def var(name, val = nil, opts = {})
    if @env[name]  
      @env[name].replace(val) 
    else
      @env[name] = Sexpr.build(val, name: name)
    end

    var_reader name
  end

  def Sexpr(val)
    Polly::Sexpr.build(val)
  end

  alias_method :const, :var
  alias_method :eq, :var

# magix

  # convert method calls on self to s-expressions
  # 
  def method_missing(method, *args, &block)
    if args.all? { |a| valid_expr?(a) }
      Sexpr.build([method, *args])
    else
     super
    end
  end

  def self.const_missing(name)
    ::Object.const_get(name)
  end

private

  def var_reader(name)
    instance_variable_set("@#{name}", @env[name])
    meta_eval { attr_reader name }
  end

end
