E='e'
W='W'
L='L'
Comps = [W,E,L]

[E,W,L].each do
  |s|
  def s.clone
    self
  end
  def s.<=>(x)
    Comps.index(self) <=> Comps.index(x)
  end
end

class Object
  # copy_mat
  #  returns self.clone if possible, or self otherwise.
  def copy_mat
    begin
      clone
    rescue
      self
    end
  end
end

class Array
  
  # makes a "deep" copy of an array of arrays
  def copy_mat
    map{ |r| r.copy_mat }
  end
  
  # Arr.delete_indices(i1, i2, ...)
  # removes Arr[i1],Arr[i2],... and returns them in the order they are found in Arr
  def delete_indices(*where)
    where.sort.reverse.map {
      |x|
      delete_at x
    }.reverse
  end
  
  # Arr.delete_cols(c1, c2, ...)
  # removes the c1th, c2th, ... columns of Arr and returns them in the order they are found in Arr
  def del_cols(*cols)
    map {
      |row|
      row.delete_indices(*cols)
    }
  end

  # Arr.find_all(obj)
  # returns an array of all indices i such that obj===Arr[i]
  def find_all(obj)
    (0...size).select {|x| self[x]==obj}
  end
end

class NilClass
  def clone
    nil
  end
end

# print_mat(matrix[,delim])
# Input - Matrix is a 2-dimensional array. Delim is an optional delimiter
# Output - Prints the matrix to the screen, with the elements of the rows separated by delim
# If delim is nil or omitted, prints each row as an array
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