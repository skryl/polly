class Polly::Sexpr
  include Polly::Common

  # instance accessors
  attr_reader :env, :name, :sexpr, :dirty
  protected :sexpr, :dirty

  # class accessors
  meta_eval { attr_accessor :verbose, :symbolic}
  meta_eval { protected :new }

  def self.build(val, env, opts = {})
    return val if val.is_a?(Sexpr)

    val = \
      case val
      when Array
        val.map!.with_index do |arg, i| 
          (arg.is_a?(Sexpr) || i == 0) ? arg : Sexpr.build(arg, env)
        end
      when *ATOMIC_TYPES
        Array(val)
      when NilClass
        UNDEFINED
      end

    Sexpr.new(val, env, opts)
  end

  def initialize(sexpr, env, opts = {})
    @name = opts[:name]
    @env = env
    @sexpr = sexpr
  end

  def op
    @sexpr[0]
  end

  def args
    @sexpr.cdr
  end

  def replace(val)
    @dirty = true
    @sexpr = self.class.build(val, self.env).sexpr
  end

  def value(cache = true)
    @dirty = false
    atomic? ? @sexpr.first : (self.defined? && self.send(:eval) || nil)
  end

  def atomic?
    @sexpr.size == 1 && valid_type?(@sexpr.first)
  end

  def defined?; !undefined? end
  def undefined?; deep_any? { |s| s.sexpr == UNDEFINED } end
  def undefined_variables; deep_select { |s| s.undefined? } end

  def clean?; !dirty? end
  def dirty?; deep_any? { |s| s.dirty } end
  def dirty_variables; deep_select { |s| s.dirty } end

  def method_missing(method, *args, &block)
    if args.all? { |a| valid_expr?(a) }
      if BINARY_OPS.include?(method)
        Sexpr.build([method, self, *args], env)
      elsif UNARY_OPS.include?(method) || args.empty?
        Sexpr.build([method, self], env)
      end
    else
     super
    end
  end

# printing
  
  def print; puts to_s end

  def to_s
    if atomic?
      (Sexpr.symbolic ? (name || value) : value).inspect
    elsif BINARY_OPS.include?(op)
      "(#{@sexpr[1].to_s} #{sexpr[0]} #{sexpr[2].to_s})" 
    elsif UNARY_OPS.include?(op)
      "#{op}(#{@sexpr[1].to_s})" 
    else
      "#{op}(#{@sexpr.cdr.map { |a| a.to_s }.join(', ')})" 
    end
  end

  def to_ary
    sexpr
  end

  def inspect
    @sexpr.inspect
  end

protected

  def deep_any?(&block)
    raise "no block given" unless block_given?
    
    if atomic?
      yield self
    else
      sexpr.cdr.any? { |s| s.deep_any?(&block) }
    end
  end

  def deep_select(&block)
    raise "no block given" unless block_given?

    if atomic? && yield(self)
      @name ? [@name] : ["anon"]
    else
      sexpr.cdr.inject([]) { |a, s| a << s.deep_select(&block)}.flatten
    end
  end


private

  # Wizard hats on ;)

  def eval
    atomic? ? value : apply
  end

  def apply
    result = \
      if @env[op].respond_to?(:call)
        @env[op].call(*arg_values) 
      elsif BINARY_OPS.include?(op)
        arg_values[0].send(op, arg_values[1])
      elsif UNARY_OPS.include?(op) || arg_values.size == 1
        arg_values[0].send(op)
      end

    puts " -> #{op}(#{arg_values.join(', ')}) = #{result}" if Sexpr.verbose
    result
  end

  def arg_values
    @arg_values = (clean? && @arg_values) || args.map { |a| a.value }
  end

end
