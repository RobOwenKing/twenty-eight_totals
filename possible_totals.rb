# frozen_string_literal: true

# Returns a new array with elements of arr1 not in arr2
# Compare: [1, 2, 2] - [1, 2] #=> []
#          subtract([1, 2, 2], [1, 2]) #=> [2]
def subtract(arr1, arr2)
  arr1_dup = arr1.dup
  arr2.each { |x| arr1_dup.slice!(arr1_dup.index(x)) if arr1_dup.include?(x) }
  arr1_dup
end

FACTORIALS = {
  '0': [0, 1],
  '3': [3, 6, 720],
  '4': [4, 24],
  '5': [5, 120],
  '6': [6, 720],
  '7': [7, 5_040],
  '8': [8, 40_320],
  '9': [9, 362_880],
  '10': [10, 3_628_800],
  '11': [11, 39_916_800],
  '12': [12, 479_001_600],
  '13': [13, 6_227_020_800],
  '14': [14, 87_178_291_200],
  '15': [15, 1_307_674_368_000],
  '16': [16, 20_922_789_888_000]
}.freeze

def push_factorials(num)
  sym = num.to_s.to_sym
  return FACTORIALS[sym] if FACTORIALS[sym]

  [num]
end

##
# @param []
#
def map_by_unary_operators(arr)
  arr.map { |num| push_factorials(num) }.flatten
end

def compose_by_binary_operators(num1, num2)
  returnable = [
    num1 + num2, num1 - num2, num2 - num1, num1 * num2,
    "#{num1}#{num2}".to_i, "#{num2}#{num1}".to_i
  ]
  returnable << num1**num2 if num2 >= 0.2 && num2 <= 5 && num1 <= 50
  returnable << num2**num1 if num1 >= 0.2 && num1 <= 5 && num2 <= 50
  returnable << num1.fdiv(num2) if num2 != 0
  returnable << num2.fdiv(num1) if num1 != 0
end

def iterate(arr)
  arr.length > 1 ? find_possible_totals(arr) : arr
end

def find_possible_totals(arr)
  breakdowns = []
  (1..arr.length / 2).each { |i| breakdowns << arr.combination(i).to_a }
  breakdowns = breakdowns.flatten(1)

  returnable = []
  breakdowns.each do |bkd|
    arr1 = iterate(bkd)
    arr2 = iterate(subtract(arr, bkd))

    arr1.each do |num1|
      arr2.each { |num2| returnable << compose_by_binary_operators(num1, num2) }
    end
  end

  returnable = returnable.flatten.select { |x| !x.nil? && x.real? }
  map_by_unary_operators(returnable).uniq.sort
end

def parse_possible_totals(arr)
  possible_totals = find_possible_totals(arr)

  possible_totals.filter { |x| x.positive? && x <= 28 && x == x.to_i }
                 .map(&:to_i).uniq
end

# p parse_possible_totals([9, 9, 10, 11])
