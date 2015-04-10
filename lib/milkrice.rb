require 'parser/current'
require 'yaml'
require 'json'
require 'byebug'
require 'optparse'

class Analyzer
  attr_reader :invokations

  BLACKLIST = [:lambda, :new, :inspect, :to_i, :to_a]

  #
  # init and optinally load a analye file
  #
  def initialize(load_file:nil)
    @namespace = []
    @method = nil
    @invokations = {}
    @invokations = JSON.parse(IO.read(load_file)) if load_file
  end

  #
  # save analyze hash as a file
  #
  def save(filename)
    IO.write(filename, @invokations.to_json)
  end

  #
  # parse a string (for testing)
  #
  def parse_string(str)
    ast = Parser::CurrentRuby.parse(str)
    parse(ast)
  end

  #
  # parse a file
  #
  def parse_file(filename)
    @filename = filename
    file_content = IO.read(filename)
    ast = Parser::CurrentRuby.parse(file_content)
    parse(ast)
    @filename = nil
    print '.'
  end

  #
  # check for a term
  #
  def check(term, levels: 5, ident: '  ')
    return unless @invokations[term]
    @invokations[term].each do |invokation|
      puts "#{ident}#{invokation['scope']}  (#{invokation['file']}:#{invokation['line']})"
      check(invokation['method'], levels: levels-1, ident: "#{ident}  ") if levels > 0
    end
  end


  private def current_scope
    "#{@namespace.join('::')}.#{@method}"
  end

  private def add_invokation(from, to)
    @invokations[to] ||= []
    @invokations[to] << from
  end

  private def get_const(ast)
    raise "#{ast} is not a const" unless ast.type == :const
    ast.children.last.to_s
  end

  private def parse_method(ast)
    if ast.respond_to?(:type) && ast.respond_to?(:children)
      if ast.type == :send
        unless BLACKLIST.include?(ast.children[1].to_sym)
          add_invokation({scope: current_scope, method: @method, file: @filename, line: ast.loc.line}, ast.children[1])
        end
      end
      ast.children.each {|c| parse_method c}
    end
  end

  private def parse(ast)
    if ast.respond_to?(:type) && ast.respond_to?(:children)
      if ast.type == :module
        @namespace.push(get_const(ast.children.first))
        ast.children.each {|c| parse c}
        @namespace.pop
      elsif ast.type == :class
        @namespace.push(get_const(ast.children.first))
        ast.children.each {|c| parse c}
        @namespace.pop
      elsif ast.type == :begin
        ast.children.each {|c| parse c}
      elsif ast.type == :def
        @method = ast.children.first
        ast.children.each {|c| parse_method c}
      elsif ast.type == :send && ast.children[1] == :scope
        @method = ast.children[2].children.last
        ast.children.each {|c| parse_method c}
      else
        ast.children.each {|c| parse c} if ast.respond_to? :children
      end

    end
  end
end


# test = <<END
# class Bla
#   scope :in_bounding_box, lambda { |latitude, longitude, distance_in_km| in_bounding_box_condition_new(latitude, longitude, distance_in_km) }
# end
# END

#ast = Parser::CurrentRuby.parse(test)
#puts ast.inspect


# (class
#   (const nil :Bla) nil
#   (send nil :scope
#     (sym :in_bounding_box)
#     (block
#       (send nil :lambda)
#       (args
#         (arg :latitude)
#         (arg :longitude)
#         (arg :distance_in_km))
#       (send nil :in_bounding_box_condition_new
#         (lvar :latitude)
#         (lvar :longitude)
#         (lvar :distance_in_km)))))

#
# analyzer = Analyzer.new()
# analyzer.parse_string(test)
# puts analyzer.invokations

# analyzer = Analyzer.new()
# analyzer.parse_file('/home/marcus/git/events/app/models/events/event_extensions/named_scopes.rb')
# puts analyzer.invokations




OptionParser.new do |opts|
  opts.banner = "Usage: parse.rb [options]"

  opts.on("-a", "--analyze", "analyze RAILS project") do
    analyzer = Analyzer.new()
    puts "Analyzing project"
    Dir['app/**/*.rb'].each do |file|
      analyzer.parse_file(file)
    end
    puts " done"
    analyzer.save(".code_analyzed.json")
  end

  opts.on("-c", "--check TERM", "Check term and find usages") do |f|
    puts "Checking term #{f}"
    analyzer = Analyzer.new(load_file: ".code_analyzed.json")
    analyzer.check(f)
  end
end.parse!
