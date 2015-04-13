module Milkrice
  # analyze all ruby files in a folder and find there usage
  class Analyzer
    attr_reader :invocations

    BLACKLIST = %i(lambda new inspect to_i to_a [] []= * | ! != !~ % & + -@ / <
                   << <= <=> == === =~ > >= - __callee__ __send__ initialize)

    CALLBACKS = %i(after_create after_destroy after_save after_validation
                   before_create before_destroy before_save before_validation)

    FILE = '.code_analyzed.json'

    def initialize
      @namespace = []
      @method = nil
      @invocations = {}
    end

    def run
      Dir['app/**/*.rb'].each do |file|
        print '.'
        parse_file(file)
      end
    end

    # save analyze hash as a file
    def save
      IO.write(FILE, JSON.pretty_generate(@invocations))
    end

    private

    def parse_file(filename)
      @filename = filename
      file_content = IO.read(filename)
      ast = Parser::CurrentRuby.parse(file_content)
      parse(ast)
      @filename = nil
    end

    def current_scope
      "#{@namespace.join('::')}.#{@method}"
    end

    def add_invocation(from, to)
      @invocations[to] ||= []
      @invocations[to] << from
    end

    def get_const(ast)
      fail "#{ast} is not a const" unless ast.type == :const
      ast.children.last.to_s
    end

    def parse_method(ast)
      return unless ast.respond_to?(:type) && ast.respond_to?(:children)
      if ast.type == :send
        unless BLACKLIST.include?(ast.children[1].to_sym)
          add_invocation({ scope: current_scope,
                           method: @method,
                           file: @filename,
                           line: ast.loc.line }, ast.children[1])
        end
      elsif ast.type == :sym
        add_invocation({ scope: current_scope,
                         method: nil,
                         file: @filename,
                         line: ast.loc.line }, ast.children[0])
      end
      ast.children.each { |c| parse_method c }
    end

    def parse(ast)
      return unless ast.respond_to?(:type) && ast.respond_to?(:children)
      if %i(module class).include?(ast.type)
        @namespace.push(get_const(ast.children.first))
        ast.children.each { |c| parse c }
        @namespace.pop
      elsif ast.type == :begin
        ast.children.each { |c| parse c }
      elsif ast.type == :def
        @method = ast.children.first
        ast.children.each { |c| parse_method c }
      elsif ast.type == :defs
        @method = ast.children[1]
        ast.children.each { |c| parse_method c }
      elsif ast.type == :send &&
        (CALLBACKS + %i(scope validate)).include?(ast.children[1])
        if ast.children[2]
          @method = ast.children[2].children.last
          ast.children.each { |c| parse_method c }
        end
      else
        ast.children.each { |c| parse c }
      end
    rescue
      raise "Error while parsing #{@filename}:#{ast.loc.line}"
    end
  end
end
