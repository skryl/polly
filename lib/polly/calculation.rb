class Polly::Calculation
  extend Forwardable
  include Polly::Common

  attr_reader :env, :context
  def_delegators :@env, :print, :to_s, :inspect, :pretty_inspect, :atomic_variables,
                 :defined_variables, :undefined_variables, :to_yaml

  def_delegator :@env, :values, :result
  def_delegator :@env, :values!, :result!

  meta_eval { attr_accessor :verbose }

  def initialize(env = {}, &block)
    @env = Env.new(env)
    @context = Context.new(@env)
    @context.evaluate(block)
  end

  def self.from_yaml(yml)
    new(YAML::load(yml))
  end

  def evaluate(&block)
    @context.evaluate(block)
    self
  end

  def method_missing(method, *args, &block)
    method.match(/^(\w+)=?$/)
    method_name = $1.to_sym
    
    if @env.keys.include?(method_name)
      method == method_name ?  @env[method_name] : @context.var(method_name, args[0])
    else super
    end
  end
   
  def verbose_toggle
    Calculation.verbose = !Calculation.verbose
  end

end
