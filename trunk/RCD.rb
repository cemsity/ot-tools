require 'util'

# rcd(ct)
#   Input - CT array
#   Output - the strata in an array, and the unrepresentable rows in an array
def do_rcd(table)
  comments = table.shift
  header = table.shift
  strata = []
  remain = (0..header.size-1).to_a
  
  loop do
    stratum = remain.clone
    
    # get rid of all columns which have L's
    for row in table
    	stratum.dup.each do |x|					 # stratum.each would skip on deletions
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
        stratum.each{ |j| table[i][j] = L } #Not standard: prevents algorithm from looking at these columns anymore
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
    ordered_row += strata.flatten.map{ |x| row[x+4] } ### reorder columns: sort within stratum by number of Ws in column in proper block
    ordered_cols << ordered_row
  }

  header = ordered_cols.shift
  ordered_rows = []
  
  (0...strata.flatten.size).each do |col|
    ordered_cols.clone.each do |row|
      if row[col+4] == W
        ordered_rows << ordered_cols.delete(row) ### use sort
      end
    end
  end
  
  [comments, header] + ordered_rows + ordered_cols
end
