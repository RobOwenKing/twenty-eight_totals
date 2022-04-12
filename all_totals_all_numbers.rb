require 'json'

require_relative 'generate_numbers'
require_relative 'numbers_to_totals'

def all_totals_all_numbers
  all_numbers = generate_numbers
  all_totals = (1..28).to_a
  obj = {}

  all_numbers.each do |arr|
    # To reduce file size, we'll only store impossible totals
    obj[arr] = all_totals - find_valid_totals(arr).keys.sort
    print '.'
  end

  obj
end

File.write('./all_totals_all_numbers.json', all_totals_all_numbers.to_json)
