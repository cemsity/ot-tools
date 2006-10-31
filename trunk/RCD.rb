E='e'
W='W'
L='L'

# From formatted input to output
def ct_standard(input)
  # cut off header - column names
  header = [input.shift]

  # cut off comments (the right two collunns)
  # input.each do |x|
  #   x[-2..-1]=[]
  # end

  # Label the headers appropriately
  header[1][0..3] = ['ERC#','Input','Winner','Loser']
  
  res = []
  until input.empty? do
    block = []

    begin
      block << input.shift
      block[-1][1] = block[0][1]
    end until input[0][1]
    
    block.delete( win_line = block.select{|x|x[3]}[0] )
    block.each do |x|
      x[3] = x[2]
      x[2] = win_line[2]
      for i in 4..x.size-3
        x[i] = [E,W,L][ win_line[i] <=> x[i] ]
      end
    end
    res += block
  end
  header + res.map{ |x| x[0..-3] }
end

# rcd(ct)
#   Input - CT array in same for as returned by vt_to_ct
#   Output - the strata in that array
def rcd(table)
  header = [table.shift,table.shift]
  strata = []
  remain = (4...table[0].size-2).to_a
  cols = remain.clone
  
  loop do
    stratum = remain.clone
    for row in table
      stratum.each do |x|
        stratum.delete(x) if row[x] == L
      end
    end
    
    break if stratum.empty?
    
    remain -= stratum
    strata << stratum
    
    # for each row...
    table.each_index do |i|
      # ...with the stratum cols selected
      w_e = table[i].values_at(*stratum)
      if w_e.index(W)
        table[i]=nil
      else
        stratum.each{ |j| table[i][j] = L }
      end
    end
    ct.compact!
  end
  
  (header+table).each do |row|
    row[4...table[0].size-2] = row.values_at(*strata.flatten)
  end
  table.sort
  strata.map{|x|x.map{|y|y-4}}
  return [header+table, strata]
end