require 'util'

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
    until row[1] == nil or table.empty? do
      formatted_table << [word_number + candidate_letter] + row
      row = table.shift
      candidate_letter.succ!
    end
    formatted_table << [word_number + candidate_letter] + row if table.empty?
    
    word_number.succ!
  end

  [comment, header, *formatted_table]
end