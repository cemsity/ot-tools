# constants for use in the CT
W="W"; E="e"; L="L"

def file_to_vt(filename)
  return File.read(filename).split(/\s/).map{|x|x.split(',')}
end

# vt_to_ct(data)
#   Input - an array of condidates' scores on constraints,
#   Output - the CT, in the form
# Example: vt_to_ct(File.read(filename).split(/\s/).map{|x|x.split(',')})
def vt_to_ct(data)
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
  strata = []
  num_rules = ct.first.size
  remain = (0...num_rules).to_a
  
  while true do
    stratum = (0...num_rules).to_a
    for row in ct
      stratum.each do |x|
        stratum.delete(x) if row[x] == L
      end
    end
    
    unless ct.empty?
      remain -= stratum
      strata << stratum
    else
      strata << remain
      remain -= stratum
    end
    
    break if remain.empty?
    
    #ct.each_index{|x| print "#{x}: #{ct[x]}\n"}
    ct_del = []
    
    # for each row...
    ct.each_index do |i|
      # ...with the stratum cols selected
      w_e = ct[i].values_at(*stratum)
      #print "#{i}: #{w_e}\n"
      # delete lines with W's
      if w_e.index(W)
        ct_del << i
      else
        stratum.each{ |j| ct[i][j] = L }
      end
    end
    ct_del.reverse.each{|i| ct.delete_at(i)}
    #ct.each_index{|x| print "#{x}: #{ct[x]}\n"}
  end
  return nil unless remain.first.nil? || ct.empty?
  return strata
end

# recursive_rcd()
#   Identical to above, but recursive
def recursive_rcd(ct,constraints=(0...ct.first.size).to_a)
  #debug#ct.each_index{|x| print "#{x}: #{ct[x]}\n"};puts "-";puts constraints;puts "---"

  return [constraints] if ct.empty?
  
  stratum = Array.new(constraints)
  remain = []
  
  for row in ct
    remain << constraints[row.index(L)] rescue nil
  end
  remain.uniq!
  
  return nil if stratum.empty?
  
  stratum -= remain.uniq
  ct_remain = []
  
  for row in ct
    if row.values_at(*stratum.map{|x| constraints.index(x)}).index(W).nil?
      ct_remain << row.values_at(*remain.map{|x| constraints.index(x)}) 
    end
  end
 
#  ct_remain.each_index{|x| print "#{x}: #{ct_remain[x]}\n"};puts "\n---"
  return [stratum] + recursive_rcd(ct_remain,remain) rescue nil
end

def rcd_file(file)
  recursive_rcd(vt_to_ct(file_to_vt(file)))
end

p rcd_file(ARGV.first)