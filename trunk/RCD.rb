require 'CSV.rb'

# constants for use in the CT
W='W'
E='e'
L='L'

# print_mat(matrix[,delim])
# Input - Matrix is a 2-dimensional array. Delim is an optional delimiter
# Output - Prints the matrix to the screen, with the elements of the rows separated by delim.
#   If delim is nil or omitted, prints each row as an array
def print_mat(matrix, delim=nil)
  puts matrix.map{|x| delim ? x.join(delim) : x.inspect}
end

# copy_mat(mat)
#   Input - An array of arrays
#   Output - A matrix containing copies of the elements of mat
def copy_mat(mat)
  mat.map{|r|r.map{|x|x.clone}}
end

# parse_file(filename)
#   Input - The name of the file containing the comma-delimited vt.
#     The desired optimum should be above other candidates in a set, and the candidate sets should
#     be separated by empty lines
#   Output - [header,lbls,vt]
#     Header is the first row of the file
#     Lbls is the candidate numbers, words, and candidate sets in a matrix
#     Vt is the violation tableau
#     The desired optimum is moved to the top of each candidate set
def parse_file(filename)
  matrix = File.read(filename).split("\r").map{|x|x.split(',')}
  header = matrix.shift
  header[1...1]=['Number']
  matrix << []
  lbls = []
  vt = []
  set='1'
  until matrix.empty? do
    inp = []
    dat = []
    cand = 'a'
    while (row=matrix.shift) != [] do
      inp << row[0..0]
      dat << [set+'.'+cand]+row[1..-1]
      cand = cand.succ
    end
    dat.sort!{|x,y| y[2] <=> x[2]}
    until inp.empty? do
      row_dat = dat.shift
      lbls << inp.shift+row_dat[0..2]
      vt << row_dat[3..-1]
    end
    lbls << row
    vt << []
    set = set.succ
  end
  [header,lbls,vt]
end

# ct_from_vt(vt)
#   Input - an array of condidates' scores on constraints, as described in vt_from_file
#   Output - the CT, in the standard form
def ct_from_vt(vt)
  vt=vt.clone
  ct = []
  until vt.empty? do
    line0 = vt.shift
    while (line = vt.shift).first do
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

# sort_output(lbls,vt,ct,strata)
#   Input - The row labels, VT, CT, and strata
#   Output - The row labes, VT, and CT sorted for filtration
def sort_output(header,lbls,vt,ct,strata)
  cols = strata.flatten
  lbls=lbls.clone
  vt = vt.map{|x|x.values_at(*cols)}
  ct = ct.map{|x|x.values_at(*cols)}
  header[4..-1]=header[4..-1].values_at(*cols)
  com = []
  vt = [[nil]]+vt
  for i in 0...vt.size do
    unless vt[i].first
      vt[i]=nil
      ct[i...i]=[[],nil]
    end
  end
  lbls.delete_if{|x|x[0].nil?}
  vt.compact!; ct.compact!; lbls.compact!
  for i in 0...vt.size
    lbls[i][1..-1] , vt[i][0...0] = nil , lbls[i][1..-1]
  end
  rows=[]
  until vt.empty? do
    com = []
    begin
      com << [vt.shift, ct.shift]
    end while ct[0][0]
    com.sort!{|a,b|a[0][3..-1]<=>b[0][3..-1]}
    rows += com
  end
  res = [[],[],[]]
  begin
    row = rows.shift
    res[0] << lbls.shift+row[0][0..2]
    res[1] << row[0][3..-1]
    res[2] << row[1]
  end until rows.empty?
  [header]+res
end

# main()
# Reads the input from input.csv
# Writes the sorted CT to CT_View.csv
# Writes the sorted VT to VT_View.csv
# Writes the stratum sizes to the first row of Strata.csv
def main
  header,lbls,vt = *parse_file('input.csv')
  ct = ct_from_vt(copy_mat(vt))
  strata = rcd(copy_mat(ct))
  header,lbls,vt,ct = *sort_output(header,lbls,vt,ct,strata)
  
  vt_view = [header] + (0...lbls.size).map{|i| lbls[i]+vt[i]}
  ct_view = [header] + (0...lbls.size).map{|i| lbls[i]+ct[i]}
  
  CSV.open('VT_View.csv', 'w') do |writer|
    vt_view.each{|row| writer << row}
  end
  CSV.open('CT_View.csv', 'w') do |writer|
    ct_view.each{|row| writer << row}
  end
  CSV.open('Strata.csv', 'w') do |writer|
    writer << strata.map{|x|x.size}
  end
  
end