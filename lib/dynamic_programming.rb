require 'byebug'
# Dynamic Programming practice
# NB: you can, if you want, define helper functions to create the necessary caches as instance variables in the constructor.
# You may find it helpful to delegate the dynamic programming work itself to a helper method so that you can
# then clean out the caches you use.  You can also change the inputs to include a cache that you pass from call to call.

class DPProblems
  def initialize
    @cache = {}
    @str_cache = Hash.new { |h, k| h[k] = {} }
  end

  # Takes in a positive integer n and returns the nth Fibonacci number
  # Should run in O(n) time
  def fibonacci(n)
    @cache[1] = 1
    @cache[2] = 1
    return @cache[n] if @cache[n]

    @cache[n] = fibonacci(n - 1) + fibonacci(n - 2)
  end

  # Make Change: write a function that takes in an amount and a set of coins.  Return the minimum number of coins
  # needed to make change for the given amount.  You may assume you have an unlimited supply of each type of coin.
  # If it's not possible to make change for a given amount, return nil.  You may assume that the coin array is sorted
  # and in ascending order.
  def make_change(amt, coins)
    return Float::INFINITY if amt < 0
    @cache[0] = 0

    return @cache[amt] if @cache[amt]
    minimum = Float::INFINITY

    coins.each do |coin|
      attempt = make_change(amt - coin, coins) + 1
      minimum = attempt unless minimum.is_a?(Integer)
      minimum = attempt if attempt < minimum
    end

    @cache[amt] = minimum
  end

  # Knapsack Problem: write a function that takes in an array of weights, an array of values, and a weight capacity
  # and returns the maximum value possible given the weight constraint.  For example: if weights = [1, 2, 3],
  # values = [10, 4, 8], and capacity = 3, your function should return 10 + 4 = 14, as the best possible set of items
  # to include are items 0 and 1, whose values are 10 and 4 respectively.  Duplicates are not allowed -- that is, you
  # can only include a particular item once.
  def knapsack(weights, values, capacity)
    return 0 if capacity.zero? || weights.length.zero?
    table = knapsack_helper(weights, values, capacity)
    table[capacity][weights.length - 1]
  end

  def knapsack_helper(weights, values, capacity)
    table = []

    (0..capacity).each do |cap|
      table[cap] = []

      (0...weights.length).each do |weight|
        if cap.zero?
          table[cap][weight] = 0
        elsif weight.zero?
          table[cap][weight] = values[0]
          table[cap][weight] = 0 if weights[0] > cap
        else
          option1 = table[cap][weight - 1]
          if weights[weight] > cap
            option2 = 0
          else
            option2 = table[cap - weights[weight]][weight - 1] + values[weight]
          end
          table[cap][weight] = [option1, option2].max
        end
      end
    end

    table
  end

  # Stair Climber: a frog climbs a set of stairs.  It can jump 1 step, 2 steps, or 3 steps at a time.
  # Write a function that returns all the possible ways the frog can get from the bottom step to step n.
  # For example, with 3 steps, your function should return [[1, 1, 1], [1, 2], [2, 1], [3]].
  # NB: this is similar to, but not the same as, make_change.  Try implementing this using the opposite
  # DP technique that you used in make_change -- bottom up if you used top down and vice versa.
  def stair_climb(n)
    @cache = [
      [[]],
      [[1]],
      [[1, 1], [2]]
    ]

    return @cache[n] if n < 3

    (3..n).each do |i|
      new_climbs = []

      (1..3).each do |dist|
        previous = @cache[i - dist]
        previous.each do |climbs|
          new_climb = [dist]
          climbs.each { |climb| new_climb << climb }
          new_climbs << new_climb
        end
      end
      @cache << new_climbs
    end

    @cache.last
  end

  # String Distance: given two strings, str1 and str2, calculate the minimum number of operations to change str1 into
  # str2.  Allowed operations are deleting a character ("abc" -> "ac", e.g.), inserting a character ("abc" -> "abac", e.g.),
  # and changing a single character into another ("abc" -> "abz", e.g.).
  def str_distance(str1, str2)
    return str2.length unless str1
    return str1.length unless str2
    return @str_cache[str1][str2] if @str_cache[str1][str2]

    if str1 == str2
      dist = 0
    elsif str1[0] == str2[0]
      dist = str_distance(str1[1..-1], str2[1..-1])
    else
      move_both = 1 + str_distance(str1[1..-1], str2[1..-1])
      move_left = 1 + str_distance(str1[1..-1], str2)
      move_right = 1 + str_distance(str1, str2[1..-1])
      dist = [move_both, move_left, move_right].min
    end

    @str_cache[str1][str2] = dist
  end

  # Maze Traversal: write a function that takes in a maze (represented as a 2D matrix) and a starting
  # position (represented as a 2-dimensional array) and returns the minimum number of steps needed to reach the edge of the maze (including the start).
  # Empty spots in the maze are represented with ' ', walls with 'x'. For example, if the maze input is:
  #            [['x', 'x', 'x', 'x'],
  #             ['x', ' ', ' ', 'x'],
  #             ['x', 'x', ' ', 'x']]
  # and the start is [1, 1], then the shortest escape route is [[1, 1], [1, 2], [2, 2]] and thus your function should return 3.
  def maze_escape(maze, start)
    return @str_cache[start[0]][start[1]] if @str_cache[start[0]][start[1]]
    starts_at_zero = start[0].zero? || start[1].zero?
    starts_near_end = start[0] == maze.length - 1 || start[1] == maze[0].length - 1

    if starts_at_zero || starts_near_end
      @str_cache[start[0]][start[1]] = 1
      return 1
    end
  end
end