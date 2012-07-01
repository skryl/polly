class Polly::Calculation
  extend Forwardable
  include Polly::Common

  attr_reader :env, :context
  def_delegators :@env, :print, :to_s, :inspect, :pretty_inspect, :atomic_variables,
                 :defined_variables, :undefined_variables

  meta_eval { attr_accessor :verbose, :symbolic}

  def initialize(&block)
    @env = Env.new
    @context = Context.new(@env)

    if block_given?
      @context.instance_eval &block
    end
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

  def symbolic_toggle
    Calculation.symbolic = !Calculation.symbolic
  end

end
