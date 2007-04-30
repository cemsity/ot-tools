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
  def s.clone
    self
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
# example - 'Ab34' -> ['Ab','34']
def split_cand(cand)
  n = cand=~/\d/
  [cand[0...n],cand[n+1..-1]]
end

def ltr(n)
  return '' if (n=n.to_i)==0
  ltr(n/26) + (''<<(96+(n%26)))
end

def range(r1,c1,r2,c2)
  @excel.activeSheet.Range("#{ltr(c1)}#{r1}:#{ltr(c2)}#{r2}")
end

def cell(r,c)
  @excel.activeSheet.cells(r,c)
end

class Collector
#  ver = $VERBOSE
#  $VERBOSE = nil
  for mth in instance_methods
    undef_method mth
  end
#  $VERBOSE = ver
  def initialize(obs, mat)
    @flat = !mat
    @objects = mat ? obs : [obs]
    @mth=:map
  end
  def method_missing(*args, &blk)
    res=@objects.map do
      |row|
        row.send(@mth) do
        |obj|
        obj.send(*args, &blk)
      end
    end[@flat ? 0 : (0..-1)]
    @mth = :map
    res
  end
  def r
    @mth=:map!
    self
  end
end

module Enumerable
  # anEnum.every
  #  If you can use this properly, you get a cookie
  def every(n=0)
    Collector.new(self, n>1)
  end
end

class Object
  def copy_mat
    self#clone rescue self
  end
end

class Array
  include Comparable
  def copy_mat
    map{|r| r.copy_mat}
  end
  def sum
    empty = 0 if first.is_a?(Numeric)
    empty = [] if first.is_a?(Array)
    inject(empty){|x,y| x+y}
  end
end