require 'optparse'

# @options = {}

# OptionParser.new do |opts|
#   opts.on('-e', '--equations', 'Show sample equation for each valid total') do
#     @options[:equations] = true
#   end
# end.parse!

def map_by_unary_operators(arr)
  arr.map { |x| [x, "#{x}!"] }
     .flatten
end

# p map_by_unary_operators(ARGV.map(&:to_i))
p map_by_unary_operators(ARGV)
