
# makes a "deep" copy of an array of arrays
class Array
  def copy_mat
    map{ |r| r.map{|x|x.clone} }
  end
  
  def rest
    self[1..-1]
  end
  
  def delete_indices(*where)
    where.sort.reverse.map {
      |x|
      delete_at x
    }.reverse
  end
  
  def del_cols(*cols)
    map {
      |row|
      row.delete_indices(*cols)
    }
  end

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
# Output - Prints the matrix to the screen, with the elements of the rows separated by delim.
#   If delim is nil or omitted, prints each row as an array
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