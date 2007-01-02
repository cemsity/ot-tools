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