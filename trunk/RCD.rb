# constants for use in the CT
W='W'
E='e'
L='L'

# vt_from_file(filename)
#   Input - The name of the file containing the comma-delimited vt.
#     The desired optimum should be above other candidates in a set, and the candidate sets should
#     be separated by empty lines
#   Output - The file converted to a 2-dimensional array
def vt_from_file(filename)
  matrix = File.read(filename).split("\r").map{|x|x.split(',')}
  matrix.shift
  matrix << []
  res = [[],[]]
  until matrix.empty? do
    inp = []
    dat = []
    while (row=matrix.shift) != [] do
      inp << row[0]
      dat << row[1..-1]
    end
    dat.sort!{|x,y| y[1] <=> x[1]}
    until inp.empty? do
      row_dat = dat.shift
      res[0] << [inp.shift]+row_dat[0..1]
      res[1] << row_dat[2..-1]
    end
    res[0] << row
    res[1] << ['']
  end
  res
end

# ct_from_vt(vt)
#   Input - an array of condidates' scores on constraints, as described in vt_from_file
#   Output - the CT, in the standard form
# Example: ct_from_vt(vt_from_file(input.csv))
def ct_from_vt(vt)
  vt=vt.clone
  ct = []
  until vt.empty? do
    line0 = vt.shift
    until (line = vt.shift).first=='' do
      ct << (0...line.size).map{ |i| {-1 => L, 0 => E, 1 => W}[line[i]<=>line0[i]] }
      break if vt.empty?
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
  
  loop do
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

# rcd_file(filename)
#   Input - the name of the file containing the comma, space, or tab-delimited vt
#   Output - the strata in an array. Each stratum is an array containing the indices of the rules in that stratum
def rcd_file(filename)
  lbls,vt = *vt_from_file(filename)
  ct = ct_from_vt(vt)
  str = rcd(ct)
  sorted = sort_output(lbls,vt,ct,str)
  sorted.each{|i| puts i,'--------------------------'}
  #puts str ? str.map{|x|x.join('|')} : 'No solution'
end

def sort_output(lbls,vt,ct,strata)
  cols = strata.flatten
  lbls=lbls.clone
  vt = vt.map{|x|x.values_at(*cols)}
  ct = ct.map{|x|x.values_at(*cols)}
  com = []
  for i in 0...vt.size do
    if vt[i]==[]
      vt[i]=nil
      ct[i...i]=[[],nil]
      lbls[i]=nil
    end
  end
  vt.compact!; ct.compact!; lbls.compact!
  com = (0...vt.size).map{|i|[lbls[i],vt[i],ct[i]]}
  com.sort!{|a,b| a[1]<=>b[1]}
  
  res = [[],[],[]]
  begin
    row = com.shift
    (0..3).each{|i| res[i] << row[i]}
  end until com.empty?
  com
end
  
vt_from_file('../input.csv')