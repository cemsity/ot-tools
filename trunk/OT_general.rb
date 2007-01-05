require 'Util'

# get_input(filename)
#  Input - filename: name of file
#  Output - [table, header, top_comment]
def get_input(filename)
  # read and parse file
  table = CSV.read(filename)#.every.every.every.to_s
  table.pop until table[-1][1]
  table.every.pop until table.every[-1].any?
  table = table.every(2).r.to_s
  
  top_comment = [table.shift]
  header = [table.shift]
  
  [table, header, top_comment]
end

# format_input(table, header)
#  Input - table, header
#  Output - [table, header]
#  Deletes blank lines and add candidate numbers
def format_input(table, header)
  formatted_table = []
  
  # add numbers to constraints in header
  for i in (1..(header[0].length-5)) do
    header[0][i+2] = "#{i}:#{header[0][i+2]}"
  end

  # add column for candidate numbers in header
  header[0].unshift('Cand#')
    
  # number the candidates by word and candidates
  word_number = '1'
  until table.empty? do
    candidate_letter = 'a'
    row = table.shift
    # populate formatted_table with numbered rows
    until row[1] == "" or table.empty? do
      formatted_table << [word_number + candidate_letter] + row
      row = table.shift
      candidate_letter.succ!
    end
    formatted_table << [word_number + candidate_letter] + row if table.empty?

    word_number.succ!
  end

  [formatted_table, header]
end