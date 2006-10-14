# constants for use in the CT
W='W' unless W=='W'
E='e' unless E=='e'
L='L' unless L=='L'

#  vt_from_file(filename)
#   Input - The name of the file containing the VT, delimited by commas or whitespace.
#      The desired optimum should be above other candidates, and the candidate sets should be separated by empty lines
#   Output - The CSV file converted to a 2-dimensional array
def vt_from_file(filename)
  return File.read(filename).split(/\s/).map{|x|x.split(',')}
end

# ct_from_vt(data)
#   Input - an array of condidates' scores on constraints, as described in file_to_vt
#   Output - the CT, in the standard form
# Example: vt_to_ct(File.read(filename).split(/\s/).map{|x|x.split(',')})
def ct_from_vt(data)
  ct = []
  until data.empty? do
    line0 = data.shift
    until (line = data.shift).first.nil? do
      ct << (0...line.size).map{ |i| {-1 => L, 0 => E, 1 => W}[line[i]<=>line0[i]] }
      break if data.empty?
    end
  end
  return ct
end

# rcd(ct)
#   Input - CT array in same for as returned by vt_to_ct
#   Output - the strata in that array
def rcd(ct)
  ct=ct.clone
  strata = []
  num_rules = ct.first.size
  remain = (0...num_rules).to_a
  
  while true do
    stratum = remain.clone
    for row in ct
      stratum.each do |x|
        stratum.delete(x) if row[x] == L
      end
    end
    
    break if stratum.empty?
    
    remain -= stratum
    strata << stratum
    
    # for each row...
    ct.each_index do |i|
      # ...with the stratum cols selected
      w_e = ct[i].values_at(*stratum)
      if w_e.index(W)
        ct[i]=nil
      else
        stratum.each{ |j| ct[i][j] = L }
      end
    end
    ct.compact!
  end
  return nil if remain.first
  return strata
end

def rcd_file(file)
  str = rcd(ct_from_vt(vt_from_file(file)))
  puts str ? str.map{|x|x.join('|')} : 'No solution'
end

rcd_file('ot-tools/polish.csv')