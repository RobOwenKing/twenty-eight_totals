# Original Javascript isCandidateValid() function

# const isCandidateValid = (arr, candidate, rng) => {
#   if (arr.reduce(reducer, 0) + candidate < arr.length + 2) { return false; } // Total can't be too small (too difficult to make larger numbers then)
#
#   const numberOfMatches = countMatchesInArray(arr, candidate);
#   if (candidate === 1 && numberOfMatches >= 1) { return false; } // 1 can only appear once
#   if (numberOfMatches >= 2) { return false; } // No number can appear more than twice
#   if (numberOfMatches === 1 && arr.some(e => countMatchesInArray(arr, e) > 1)) {
#     // You can have at most one repeated digit i.e. [a, a, b, c] = valid; [a, a, b, b] != valid
#     return false;
#   }
#   if (numberOfMatches === 1 && rng.call() < 0.25) { return false; }
#
#   return true;
# };

def valid_candidate?(arr, candidate)
  return false if arr.sum < arr.length + 2

  matches = arr.count(candidate)
  return false if candidate == 1 && !matches.nil?
  return false if matches >= 2
  return false if matches == 1 && arr.any? { |e| arr.count(e) > 1 }

  true
end

possible_numbers = [[]]

