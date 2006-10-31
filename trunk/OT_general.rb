# Input - filename: name of file
# Output - [table, header, top_comment]   ###, side_comments]
def get_input(filename)
  # read and parse file
  table = File.read(filename).split("\r").map{|x|x.split(',')}
  top_comment = [table.shift]
  header = [table.shift]
  # side_comments = table.collect{ |x| y = x.pop; [x.pop, y] }
  # replace nil's with empty strings 
  # table.each{ |x| x.map!{ |y| y ? y : '' } }
  
  [table, header, top_comment]   ###, side_comments]
end

# Deletes blank lines and add candidate numbers
# Input - table, header
def format_input(table, header)
  formatted_table = []
  # formatted_remarks = []
  
  # deep copy arguments
  table = table.copy_mat
  header = header.copy_mat
  # top_comment = top_comment.copy_mat

  # add numbers to conditions in header
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
    until row[1].nil? or table.empty? do
      # formatted_remarks << remarks.shift
      formatted_table << [word_number + candidate_letter] + row
      row = table.shift
      candidate_letter.succ!
    end
    # remarks.shift
    word_number.succ!
  end

  [formatted_table, header]
end