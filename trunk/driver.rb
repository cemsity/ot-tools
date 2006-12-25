# driver.rb - this will be the command-line interface for the RCD algorithms
# Usage: "ruby driver.rb <input file> <output directory>"

require 'RCD'
require 'Util'
require 'OT_general'
require 'CSV'
require 'FRed'
input_file = ARGV[0] ? ARGV[0] : 'winput.csv'
output_folder = ARGV[1] ? ARGV[1] : 'Output'

def rcd_main(input_file,output_folder)
  vt_table, header, top_comment = *get_input(input_file)
  vt_table_formatted, header_formatted = *format_input(vt_table, header)
  
  sheet3 = header_formatted + vt_table_formatted

  puts '-'*10+"Sheet 3"+'-'*10
  sheet3.each { |r| p r }
  
  CSV.open(output_folder+'/Sheet3.csv', 'w') do |writer|
    sheet3.each{|row| writer << row.map{|x| x.gsub("<comma />", ",")}}
  end

  sheet4 = ct_standard(header_formatted.copy_mat + vt_table_formatted.copy_mat)

  puts '-'*10+"Sheet 4"+'-'*10
  sheet4.each { |r| p r }
  
  CSV.open(output_folder+'/Sheet4.csv', 'w') do |writer|
    sheet4.each{|row| writer << row}
  end

  E[0...1] = ''

  puts '-'*10+"Sheet 5"+'-'*10
  sheet4.each { |r| p r }
  
  CSV.open(output_folder+'/Sheet5.csv', 'w') do |writer|
    sheet4.each{|row| writer << row}
  end
  
  E[0...1] = 'e'
  puts '-'*10+"Strata"+'-'*10  
  strata,remain = *rcd(sheet4.copy_mat.map{ |x| x[4..-1] })
  raise('No solution found') if remain[0]
  p strata

  puts '-'*10+"Sheet 6"+'-'*10
  sheet6 = sort_by_strata(sheet4.copy_mat,strata)
  sheet6.each { |r| p r }
  
  CSV.open(output_folder+'/Sheet6.csv', 'w') do |writer|
    sheet6.each{|row| writer << row}
  end
  $s6 = sheet6
    
  #frf, lbl = *fred(sheet6)
  #print_mat frf
end

rcd_main input_file,output_folder
