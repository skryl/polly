class Polly::Calculation
  include Polly::Common

  attr_reader :env

  def initialize(&block)
    @env = Context.new
    Math.singleton_methods.each do |m|
      @env[m.to_sym] = lambda { |*args| Math.send(m, *args) }
    end

    if block_given?
      @env.instance_eval &block
    end
  end

  def clean_env
    Context[@env.select { |name, expr| expr.is_a?(Sexpr) }]
  end

  def atomic_variables
    @env.select { |name, expr| expr.is_a?(Sexpr) && expr.atomic? }
  end

  def defined_variables
    @env.select { |name, expr| expr.is_a?(Sexpr) && expr.atomic? && expr.defined? }
  end

  def undefined_variables
    @env.select { |name, expr| expr.is_a?(Sexpr) && expr.atomic? && !expr.defined? }
  end

  def method_missing(method, *args, &block)
    method.match(/^(\w+)=?$/)
    method_name = $1.to_sym
    
    if @env.keys.include?(method_name)
      method == method_name ?  @env[method_name] : @env.var(method_name, args[0])
    else super
    end
  end

  def print; puts to_s end
  def to_s; clean_env.to_s end
  def inspect; env.inspect end
  def pretty_inspect; env.pretty_inspect end

end
