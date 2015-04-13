module Milkrice
  # analyze all ruby files in a folder and find there usage
  class Analyzer
    attr_reader :invokations

    BLACKLIST = %i(lambda new inspect to_i to_a [])
    FILE = '.code_analyzed.json'

    def initialize
      @namespace = []
      @method = nil
      @invokations = {}
    end

    def run
      Dir['app/**/*.rb'].each do |file|
        print '.'
        parse_file(file)
      end
    end

    # save analyze hash as a file
    def save
      IO.write(FILE, JSON.pretty_generate(@invokations))
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

    def add_invokation(from, to)
      @invokations[to] ||= []
      @invokations[to] << from
    end

    def get_const(ast)
      fail "#{ast} is not a const" unless ast.type == :const
      ast.children.last.to_s
    end

    def parse_method(ast)
      return unless ast.respond_to?(:type) && ast.respond_to?(:children)
      if ast.type == :send
        unless BLACKLIST.include?(ast.children[1].to_sym)
          add_invokation({ scope: current_scope,
                           method: @method,
                           file: @filename,
                           line: ast.loc.line }, ast.children[1])
        end
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
      elsif ast.type == :send && ast.children[1] == :scope
        @method = ast.children[2].children.last
        ast.children.each { |c| parse_method c }
      else
        ast.children.each { |c| parse c }
      end
    end
  end
end
