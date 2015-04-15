module Mire
  # analyze all ruby files in a folder and find there usage
  class Analyzer
    attr_reader :methods

    BLACKLIST = %i(lambda new inspect to_i to_a [] []= * | ! != !~ % & + -@ / <
                   << <= <=> == === =~ > >= - __callee__ __send__ initialize
                   method_missing)

    CALLBACKS = %i(after_commit after_create after_destroy after_save
                   after_update after_validation before_commit before_create
                   before_destroy before_save before_update before_validation)

    FILE = '.mire_analysis.yml'

    def initialize
      @namespace = []
      @method = nil
      @methods = {}
      @files = Dir['app/**/*.rb']
    end

    def run
      progress_bar = ProgressBar.create(total: @files.count)
      @files.each do |file|
        parse_file(file)
        progress_bar.increment
      end
    end

    # save analyze hash as a file
    def save
      IO.write(FILE, @methods.to_yaml)
    end

    private

    def parse_file(filename)
      @filename = filename
      file_content = IO.read(filename)
      ast = Parser::CurrentRuby.parse(file_content)
      parse(ast)
      @filename = nil
    end

    def location(ast)
      {
        class: @namespace.join('::'),
        method: @method,
        file: @filename,
        line: ast.loc.line
      }
    end

    def add_method(to, definition: nil, invocation: nil)
      return if BLACKLIST.include?(to.to_sym)

      @methods[to] ||= { definitions: [], invocations: [] }
      @methods[to][:definitions] << location(definition) if definition
      @methods[to][:invocations] << location(invocation) if invocation
    end

    def get_const(ast)
      fail "#{ast} is not a constant" unless ast.type == :const
      ast.children.last.to_s
    end

    def parse_method(ast)
      return unless ast.respond_to?(:type) && ast.respond_to?(:children)
      if ast.type == :send
        add_method(ast.children[1], invocation: ast)
      elsif ast.type == :sym
        add_method(ast.children[0], invocation: ast)
      end
      ast.children.each { |c| parse_method c }
    end

    def parse(ast)
      return unless ast.respond_to?(:type) && ast.respond_to?(:children)
      if %i(module class).include?(ast.type)
        @namespace.push(get_const(ast.children.first))
        ast.children.each { |c| parse c }
        @namespace.pop
      elsif %i(def defs).include?(ast.type)
        @method = ast.children[ast.type == :defs ? 1 : 0]
        add_method(@method, definition: ast)
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
