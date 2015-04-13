#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__)) + '/../lib')

require 'milkrice'

cli = Milkrice::CLI.new
cli.run
