class Polly::Context
  include Polly::Common

  def initialize(env)
    @env = env
  end

  def name(n)
    @name = n
  end

  def version(v)
    @version = v
  end

  def var(name, val = nil, opts = {})
    @env.set_var(name, val, opts)
    var_reader name
  end

  alias_method :const, :var
  alias_method :eq, :var

# magix

  def method_missing(method, *args, &block)
    if args.all? { |a| valid_expr?(a) }
      Sexpr.build([method, *args], @env)
    else
     super
    end
  end

private

  def var_reader(name)
    instance_variable_set("@#{name}", @env[name])
    meta_eval { attr_reader name }
  end

end
