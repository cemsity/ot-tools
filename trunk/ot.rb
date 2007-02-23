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

# format_input(table)
#  Input - table
#  Output - [table, header]
#  Deletes blank lines and add candidate numbers
def format_input(table)
  formatted_table = []
  comment = table.shift.push(nil)
  header = table.shift
  
  # add numbers to constraints in header
  for i in (1..(header.size-5)) do
    header[i+2] = "#{i}:#{header[i+2]}"
  end

  # add column for candidate numbers in header
  header.unshift('Cand#')
    
  # number the candidates by word and candidates
  word_number = '1'
  until table.empty? do
    candidate_letter = 'a'
    row = table.shift
    # populate formatted_table with numbered rows
    until row[1] == nil or table.empty? do ###
      formatted_table << [word_number + candidate_letter] + row
      row = table.shift
      candidate_letter.succ!
    end
    formatted_table << [word_number + candidate_letter] + row if table.empty?
    
    word_number.succ!
  end

  [comment, header, *formatted_table]
end

# filtration(input, blocks, strata)
#  input - the Input-Formatted sheet
#  blocks - the number of candidates for each choice
#  strata - the ordering of the columns
#  returns the Filtration-View sheet
def filtration(input, blocks, strata, numConstraints)
  width = strata.size+5
  strata=strata.dup
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
    while cands[0] && (col<= width)
      cands.select{|c| block[c][col] != block[0][col]}.each do
        |del|
        block[cands.delete(del)][col] += ' !'
      end
      col += 1
    end
    row=0
    while(block[row][4..-3]==block[0][4..-3])
      block[row][3]+='wins'
      row +=1
    end
    res += block
  end
  res
end