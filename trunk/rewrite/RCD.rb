require 'util'

# ct_standard(input)
#  Input - the formatted user input
#  Output - the ct in standard form
def ct_standard(input)
  # cut off comments, header
  comments = input.shift[0..-3]
  header = input.shift

  # Label the headers appropriately, chop off remarks
  header[0..3] = ['ERC#','Input','Winner','Loser']
  header[-2..-1] = []
  
  res = []
  sizes = []
  until input.empty? do
    block = []

    # populate column 2 correctly
    i=0
    begin
      block << input.shift
      block[-1][1] = block[0][1]
      i += 1
    end until input.first[1] rescue nil
    sizes << i  
    
    # save winning line as win_line, and delete it from block
    block.delete( win_line = block.select{ |x| x[3] }.first )

    # change Cand# to ERC
    block.each do |cand|
      n = (cand[0] =~ /[a-zA-Z]/) # position of first letter
      cand[0][n...n] = split_cand(win_line[0])[1]
    end

    # populate the rest of the block correctly
    block.each do |cand|
      # move losers over into fourth col
      cand[3] = cand[2]
      
      # place winners into third col
      cand[2] = win_line[2]
      
      # populate the CT
      for i in 4..cand.size-3
        cand[i] = [E,L,W][ win_line[i] <=> cand[i] ]
      end
    end
    res += block
  end

  [[comments, header, *(res.every[0..-3])], sizes]
end

# rcd(ct)
#   Input - CT array
#   Output - the strata in an array, and the unrepresentable rows in an array
def do_rcd(table)
  comments = table.shift
  header = table.shift
  strata = []
  remain = (0..header.size-1).to_a
  cols = remain.clone

  loop do
    stratum = remain.clone
    
    # get rid of all columns which have L's
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
      if w_e.include?(W)
        table[i] = nil
      else
        stratum.each{ |j| table[i][j] = L }
      end
    end
    table.compact!
  end

  return [strata<<remain,remain.empty?]
end

# sort_by_strata(table, strata)
#  takes a table such as in sheet 5 and a strata ordering
#  returns sorted tables, such as in sheet 6
def sort_by_strata(table, strata)
  comments = table.shift
  ordered_cols = []
  
  # order the columns by strata and put in ordered_cols
  table.each { |row|
    ordered_row = row[0..3]
    ordered_row += strata.flatten.map{ |x| row[x+4] }
    ordered_cols << ordered_row
  }

  header = ordered_cols.shift
  ordered_rows = []
  
  (0...strata.flatten.size).each do |col|
    ordered_cols.clone.each do |row|
      if row[col+4] == W
        ordered_rows << ordered_cols.delete(row)
      end
    end
  end
  
  [comments, header] + ordered_rows + ordered_cols
end

# filtration(input, blocks, strata)
#  input - the Input-Formatted sheet
#  blocks - the number of candidates for each choice
#  strata - the ordering of the columns
#  returns the Filtration-View sheet
def filtration(input, blocks, strata)
  strata=strata.flatten
  cols = (0...input[0].size).to_a
  cols[4..-3] = strata.every+4
  input.every.r.values_at(*cols)
  res = [input.shift, input.shift]
  blocks.each do
    |size|
    cands = (1...size).to_a
    block = ([0]*size).map{|x| input.shift.every.to_s}
    in_word = block[0][1]
    block[0][1] = ''
    block.sort!{|a,b| a[4..-1] <=> b[4..-1]}
    block[0][1] = in_word
    col = 4
    while cands[0]
      cands.select{|c| block[c][col] != block[0][col]}.each do
        |del|
        block[cands.delete(del)][col] += ' !'
      end
      col += 1
    end
    res += block
  end
  res
end