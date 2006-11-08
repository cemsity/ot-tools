E='e'
W='W'
L='L'

# makes a "deep" copy of an array of arrays
class Array
  def copy_mat
    map{ |r| r.map{|x|x.clone} }
  end
  
  def rest
    self[1..-1]
  end
end

class NilClass
  def clone
    nil
  end
end

# input - a string of non-digits, followed by digits
# output - an array of the non-digits followed by the digits
# example - 'Ab32' -> ['Ab','32']
def split_cand(cand)
  n = cand=~/\d/
  [cand[0...n],cand[n+1..-1]]
end
