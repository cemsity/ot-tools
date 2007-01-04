E='e'
W='W'
L='L'
# Comparison of E, W, and L will follow Comps[0] < Comps[1] < Comps[2]
Comps = [W,E,L]

[E,W,L].each do
  |s|
  def s.<=>(x)
    Comps.index(self) <=> Comps.index(x)
  end
end

# print_mat(matrix[,delim])
#  Input - Matrix is a 2-dimensional array. Delim is an optional delimiter
#  Output - Prints the matrix to the screen, with the elements of the rows separated by delim
#  If delim is nil or omitted, prints each row as an array
def print_mat(matrix, delim=nil)
  puts matrix.map{|x| delim ? x.join(delim) : x.inspect}
end


# input - a string of non-digits, followed by digits
# output - an array of the non-digits followed by the digits
# example - 'Ab32' -> ['Ab','32']
def split_cand(cand)
  n = cand=~/\d/
  [cand[0...n],cand[n+1..-1]]
end


Out_fold = ""
Top_comm = []
# output(table, capt, [num])
#  writes table to the screen, labeled with capt
#  writes out table (as a spreadsheet) to "Sheet#{num}.csv" if num is provided
def output(table, capt, num=nil)
  puts '-'*10 + (num ? "Sheet #{num}: " : '') + capt + '-'*10
  print_mat table, "\t"
  return unless num
  sheet = num.instance_of?(String) ? num : "/Sheet#{num}"
  CSV.open(Out_fold+sheet+".csv", 'w') do |writer|
    (Top_comm+table).each{|row| writer << row}
  end
end

class Collector
  for mth in instance_methods
    undef_method mth
  end
  def initialize(obs)
    @objects=obs
    @danger=false
  end
  def method_missing(*args, &blk)
    mth = @danger ? :map! : :map
    @danger=false
    @objects.send(mth) do
      |obj|
      obj.send(*args, &blk)
    end
  end
  def r
    @danger=true
    self
  end
end

module Enumerable
  # anEnum.every
  #  If you can use this properly, you get a cookie
  def every
    Collector.new(self)
  end
end