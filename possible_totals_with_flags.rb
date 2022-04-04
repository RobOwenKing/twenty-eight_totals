# frozen_string_literal: true

require 'benchmark'
require 'optparse'

@options = {}

OptionParser.new do |opts|
  opts.on('-c', '--count', 'Show count of valid solutions') do
    @options[:count] = true
  end
  opts.on('-e', '--equations', 'Show sample equation for each valid total') do
    @options[:equations] = true
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

# All the factorials we're going to bother with considering
# Note! This does not include 3, being the only digit d where d!! is within range
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

# Returns a hash including the original key, value pair (keys are digits, values are equations)
# Plus any pairs after factorialing the original pair that we should consider
def find_factorials_hash(key, value)
  return { 3 => value, 6 => "#{value}!", 720 => "#{value}!!" } if key == 3

  { key => value, FACTORIALS[key.to_f] => "#{value}!" } if FACTORIALS[key.to_f]
end

# Array of all the digits for which we will consider the factorial
FACTORIALS_KEYS = [0, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16].freeze

# Returns the original input hash (keys are digits, values are equations)
# Plus any new key-value pairs after unary operations
# Currenly the only unary operator is factorial
def map_by_unary_operators(hsh)
  returnable = hsh

  hsh.each_pair do |key, value|
    returnable = find_factorials_hash(key, value).merge(returnable) if FACTORIALS_KEYS.include?(key)
  end

  returnable
end

# Takes in two key-value pairs (keys are digits, values are equations)
# Returns a hash of key-value pairs of all valid combinations in the game of the inputs
# eg: compose_by_binary_operators(1, '1', 2, '2') #=> { 3: '(1+2)', -1: '(1-2)', 1: '(2-1)'... }
def compose_by_binary_operators(key1, val1, key2, val2)
  key1 = key1.to_f
  key2 = key2.to_f

  returnable = {
    key1 + key2 => "(#{val1}+#{val2})",
    key1 - key2 => "(#{val1}-#{val2})",
    key2 - key1 => "(#{val2}-#{val1})",
    key1 * key2 => "(#{val1}*#{val2})"
  }

  returnable["#{key1.to_i}#{key2.to_i}".to_i] = "#{val1}#{val2}" if "#{key1.to_i}#{key2.to_i}" == "#{val1}#{val2}"
  returnable["#{key2.to_i}#{key1.to_i}".to_i] = "#{val2}#{val1}" if "#{key2.to_i}#{key1.to_i}" == "#{val2}#{val1}"

  exp1 = key1**key2
  returnable[exp1] = "(#{val1}**#{val2})" if !exp1.instance_of?(Complex) && exp1 >= 0.001 && exp1 <= 10_000
  exp2 = key2**key1
  returnable[exp2] = "(#{val2}**#{val1})" if !exp2.instance_of?(Complex) && exp2 >= 0.001 && exp2 <= 10_000

  returnable[key1 / key2] = "(#{val1}/#{val2})" if key2 != 0
  returnable[key2 / key1] = "(#{val2}/#{val1})" if key1 != 0

  returnable
end

# Returns a hash (keys are digits, values are equations)
def iterate(arr)
  return find_possible_totals(arr) if arr.length > 1

  # If we're down to one digit, start going back up the recursive tree with a hash
  hsh = { arr[0] => arr[0] }
  map_by_unary_operators(hsh)
end

# Returns a hash (keys are digits, values are equations)
# All totals that can be made with the digits in the given array
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

def print_count(possible_totals)
  p "#{possible_totals.length} valid solutions"
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

def print_time(time)
  p "Time elapsed: #{time.real}s"
end

# Call #find_possible_totals with given array
# Return only key-value pairs for relevant totals (integers 0..28)
def find_valid_totals(arr)
  possible_totals = find_possible_totals(arr)

  possible_totals.select! { |key| key.positive? && key <= 28 && key == key.to_i }
                 .transform_keys!(&:to_i)
end

# Call #find_valid_totals with given array
# Print results to console
def present_possible_totals(arr)
  time = Benchmark.measure do
    valid_totals = find_valid_totals(arr)

    print_count(valid_totals) if @options[:count]
    p valid_totals.keys.sort
    print_equations(valid_totals) if @options[:equations]
  end

  print_time(time) if @options[:time]
end

present_possible_totals(ARGV.map(&:to_i))
