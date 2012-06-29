class Polly::Sexpr
  include Polly::Common

  # instance accessors
  attr_reader :env, :name, :op, :args, :sexpr, :dirty
  protected :sexpr, :dirty

  # class accessors
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
    @sexpr = sexpr
    @op = sexpr[0]
    @args = sexpr.cdr
    @name = opts[:name]
    @env = env
  end

  def value
    @dirty = false
    atomic? ? @sexpr.first : (self.defined? && self.send(:eval) || nil)
  end

  def replace(val)
    @dirty = true
    @sexpr = self.class.build(val, self.env).sexpr
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

  def clear_cache!
    @dirty = true
  end

# magix

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

# printing and conversion
  
  def print; puts to_s end
  def inspect; @sexpr.inspect end
  def to_ary; sexpr end

  def to_s
    if atomic?
      (Calculation.symbolic ? (name || value) : value).inspect
    elsif BINARY_OPS.include?(op)
      "(#{@sexpr[1].to_s} #{sexpr[0]} #{sexpr[2].to_s})" 
    elsif UNARY_OPS.include?(op)
      "#{op}(#{@sexpr[1].to_s})" 
    else
      "#{op}(#{@sexpr.cdr.map { |a| a.to_s }.join(', ')})" 
    end
  end

protected

  def deep_any?(&block)
    raise "no block given" unless block_given?
    
    if yield(self)
      true
    else
      sexpr.cdr.any? { |s| s.deep_any?(&block) }
    end
  end

  def deep_select(&block)
    raise "no block given" unless block_given?

    if yield(self)
      @name ? [@name] : []
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

    puts " -> #{op}(#{arg_values.join(', ')}) = #{result}" if Calculation.verbose
    result
  end

  # use cached values unless some part of expression tree is dirty
  #
  def arg_values
    @arg_values = (clean? && @arg_values) || args.map { |a| a.value }
  end

end
