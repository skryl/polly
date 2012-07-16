class Polly::Sexpr
  include Polly::Common
  include Enumerable

  # instance accessors
  attr_reader :op, :args, :sexpr, :env
  attr_accessor :name, :env, :dirty
  protected :sexpr, :env=, :name=, :dirty=

  # class accessors
  meta_eval { protected :new }

  def self.build(val, env = nil, name = nil)
    val = \
      case val
      when Sexpr 
        val
      when Symbol 
        env_val = env && env[val]
        env_val.is_a?(Sexpr) ? env_val : Array(val)
      when Array
        if val.size > 1
          val.cdr.map do |arg| 
            arg.is_a?(Sexpr) ? arg : Sexpr.build(arg, env, name) 
          end.unshift(val.car)
        else
          Sexpr.build(val.first, env, name)
        end
      when NilClass
        UNDEFINED
      else Array(val)
      end

    val.is_a?(Sexpr) ? Sexpr.update(val, env, name) : Sexpr.new(val, env, name)
  end

  # If an sexpr directly references another named sexpr then the named sexpr
  # should be wrapped in a self call, which is a noop, in order to avoid
  # having two references to the same sexpr.
  #
  def self.update(sexpr, env, name)
    if name && sexpr.name && name != sexpr.name
      Sexpr.build([:self, sexpr])
    else
      sexpr.send(:name=, name) unless sexpr.name
      sexpr.send(:env=, env) unless sexpr.env
      sexpr
    end
  end

  def initialize(sexpr, env, name)
    @sexpr = sexpr
    @op = @sexpr[0]
    @args = @sexpr.cdr
    @name = name
    @env = env || Env.new
  end

  # use cached values unless some part of expression tree is dirty
  #
  def value(env = @env)
    @value = \
      (clean? && @value) || 
      (self.defined? ? (atomic? ? @sexpr.first : self.send(:eval)) : nil)
    @dirty = false
    @value
  end

  # force a recalc of all sub-expressions
  #
  def value!(env = @env) 
    each { |a| a.dirty = true }
    value(env)
  end

  def replace(val)
    @dirty = true
    @sexpr = self.class.build(val, @env).sexpr
  end

  def atomic?
    @sexpr.size == 1
  end

  def defined?; !undefined? end
  def undefined?; any? { |s| s.sexpr == UNDEFINED } end
  def undefined_variables; select { |s| s.atomic? && s.undefined? && s.name }.map(&:name) end

  def clean?; !dirty? end
  def dirty?; any? { |s| s.dirty } end
  def dirty_variables; select { |s| s.atomic? && s.dirty? && s.name }.map(&:name) end

  def ==(val)
    case val
    when Sexpr, Array
      val == @sexpr
    else
      val == self.value
    end
  end

  def each(&block)
    return to_enum unless block_given?

    yield self
    args.each { |s| s.each(&block) }
  end

# magix

  # convert any method call to an s-expression
  #
  def method_missing(method, *args, &block)
    Sexpr.build([method, self, *args], @env)
  end

# printing and conversion
  
  def print(opts = {}); puts to_s(opts) end
  def inspect(opts = {}); @sexpr.inspect end
  def to_s(opts = {}); print(_to_ary(opts)) end
  def to_ary(opts = {}); _to_ary(opts) end

protected

  def _to_ary(opts = {})
    if atomic?
      Array(value)
    else
      args.map do |a| 
        if a.atomic? || (!opts[:expand] && a.name)
          Array(opts[:numeric] ? a.value : (a.name || a.value))
        else 
          a._to_ary(opts)
        end
      end.unshift(op)
    end
  end

  def print(sexpr)
    op, args = sexpr.car, sexpr.cdr

    if args.empty?
      op.inspect
    elsif BINARY_OPS.include?(op)
      "(#{print(args[0])} #{op} #{print(args[1])})" 
    else
      "#{op}(#{args.map {|a| print(a)}.join(', ')})" 
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
      else
        arg_values[0].send(op, *arg_values.cdr)
      end

    puts " -> #{op}(#{arg_values.join(', ')}) = #{result}" if Calculation.verbose
    result
  end

  def arg_values
    args.map { |a| a.value }
  end

end
