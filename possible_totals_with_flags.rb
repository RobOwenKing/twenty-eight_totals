# frozen_string_literal: true

require 'benchmark'
require 'optparse'

@options = {}

OptionParser.new do |opts|
  opts.on('-e', '--equations', 'Show sample equation for each valid total') do
    @options[:equations] = true
  end
  opts.on('-c', '--count', 'Show count of valid solutions') do
    @options[:count] = true
  end
  opts.on('-t', '--time', 'Show how long it took') do
    @options[:time] = true
  end
end.parse!

# Returns a new array with elements of arr1 not in arr2
# Compare: [1, 2, 2] - [1, 2] #=> []
#          subtract([1, 2, 2], [1, 2]) #=> [2]
def subtract(arr1, arr2)
  arr1_dup = arr1.dup
  arr2.each { |x| arr1_dup.slice!(arr1_dup.index(x)) if arr1_dup.include?(x) }
  arr1_dup
end

FACTORIALS = {
  0.0 => 1,
  4.0 => 24,
  5.0 => 120,
  6.0 => 720,
  7.0 => 5_040,
  8.0 => 40_320,
  9.0 => 362_880,
  10.0 => 3_628_800,
  11.0 => 39_916_800,
  12.0 => 479_001_600,
  13.0 => 6_227_020_800,
  14.0 => 87_178_291_200,
  15.0 => 1_307_674_368_000,
  16.0 => 20_922_789_888_000
}.freeze

def find_factorials_hash(key, value)
  return { 3 => value, 6 => "#{value}!", 720 => "#{value}!!" } if key == 3

  { key => value, FACTORIALS[key.to_f] => "#{value}!" } if FACTORIALS[key.to_f]
end

FACTORIALS_KEYS = [0, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16].freeze

##
# @param []
#
def map_by_unary_operators(hsh)
  returnable = hsh

  hsh.each_pair do |key, value|
    returnable = find_factorials_hash(key, value).merge(returnable) if FACTORIALS_KEYS.include?(key)
  end

  returnable
end

def compose_by_binary_operators(key1, val1, key2, val2)
  key1 = key1.to_f
  key2 = key2.to_f

  returnable = {
    key1 + key2 => "(#{val1}+#{val2})",
    key1 - key2 => "(#{val1}-#{val2})",
    key2 - key1 => "(#{val2}-#{val1})",
    key1 * key2 => "(#{val1}*#{val2})"
  }

  returnable["#{key1}#{key2}".to_i] = "#{val1}#{val2}" if "#{key1}#{key2}".to_i == "#{val1}#{val2}"
  returnable["#{key2}#{key1}".to_i] = "#{val2}#{val1}" if "#{key2}#{key1}".to_i == "#{val2}#{val1}"

  #returnable[key1**key2] = "(#{val1}**#{val2})" if key2 >= 0.2 && key2 <= 5 && key1 <= 50
  #returnable[key2**key1] = "(#{val2}**#{val1})" if key1 >= 0.2 && key1 <= 5 && key2 <= 50

  returnable[key1.fdiv(key2)] = "(#{val1}/#{val2})" if key2 != 0
  returnable[key2.fdiv(key1)] = "(#{val2}/#{val1})" if key1 != 0

  returnable
end

def iterate(arr)
  return find_possible_totals(arr) if arr.length > 1

  hsh = { arr[0] => arr[0] }
  map_by_unary_operators(hsh)
end

def find_possible_totals(arr)
  breakdowns = []
  (1..arr.length / 2).each { |i| breakdowns << arr.combination(i).to_a }
  breakdowns = breakdowns.flatten(1)

  returnable = {}
  breakdowns.each do |bkd|
    break if arr.length == ARGV.length && (1..28).all? { |i| !returnable[i.to_f].nil? }

    hsh1 = iterate(bkd)
    hsh2 = iterate(subtract(arr, bkd))

    hsh1.each_pair do |key1, val1|
      hsh2.each_pair { |key2, val2| returnable = compose_by_binary_operators(key1, val1, key2, val2).merge(returnable) }
    end
  end

  map_by_unary_operators(returnable)
end

def print_equations(possible_totals)
  (1..28).each do |i|
    if possible_totals[i]
      p "#{i}: #{possible_totals[i]}"
    else
      p "#{i} not possible"
    end
  end
end

def parse_possible_totals(arr)
  time = Benchmark.measure do
    possible_totals = find_possible_totals(arr)

    possible_totals.select! { |key| key.positive? && key <= 28 && key == key.to_i }
                   .transform_keys!(&:to_i)

    p "#{possible_totals.length} valid solutions" if @options[:count]
    p possible_totals.keys.sort
    print_equations(possible_totals) if @options[:equations]
  end

  p "Time elapsed: #{time.real}s" if @options[:time]
end

parse_possible_totals(ARGV.map(&:to_i))
