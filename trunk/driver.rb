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

  puts '-'*10+"Sheet 3: Input-Formatted"+'-'*10
  print_mat(sheet3,"\t")
  
  CSV.open(output_folder+'/Sheet3.csv', 'w') do |writer|
    sheet3.each{|row| writer << row}
  end

  sheet4 = ct_standard(header_formatted.copy_mat + vt_table_formatted.copy_mat)

  puts '-'*10+"Sheet 4: CT"+'-'*10
  print_mat(sheet4,"\t")
  
  CSV.open(output_folder+'/Sheet4.csv', 'w') do |writer|
    sheet4.each{|row| writer << row}
  end

  E[0...1] = ''

  puts '-'*10+"Sheet 5: CT no Es"+'-'*10
  print_mat(sheet4,"\t")
  
  CSV.open(output_folder+'/Sheet5.csv', 'w') do |writer|
    sheet4.each{|row| writer << row}
  end
  
  puts '-'*10+"Strata"+'-'*10  
  strata,remain = *rcd(sheet4.copy_mat.map{ |x| x[4..-1] })
  raise('No solution found') if remain[0]
  p strata

  puts '-'*10+"Sheet 6: RCD view"+'-'*10
  sheet6 = sort_by_strata(sheet4.copy_mat,strata)
  print_mat(sheet6,"\t")
  
  CSV.open(output_folder+'/Sheet6.csv', 'w') do |writer|
    sheet6.each{|row| writer << row}
  end

  success, lbl, mib, skb = fred(sheet6.copy_mat)
  Comps[0..-1] = [W,L,E]
  mib = mib.zip(lbl.map{|row| 'A'+row.map{|num| sheet6[0][num+4][0..0]}.join}).sort.map{|row| [row[-1]]+row[0]}
  skb = skb.zip(lbl.map{|row| 'A'+row.map{|num| sheet6[0][num+4][0..0]}.join}).sort.map{|row| [row[-1]]+row[0]}

  puts '-'*10+"Sheet 7: Most Informative Basis"+'-'*10
  sheet7 = [['Fus']+sheet6[0][4..-1]] + mib
  print_mat(sheet7,"\t")
  
  CSV.open(output_folder+'/Sheet7.csv', 'w') do |writer|
    sheet7.each{|row| writer << row}
  end
  
  puts '-'*10+"Sheet 8: Skeletal Basis"+'-'*10
  sheet8 = [['Fus']+sheet6[0][4..-1]] + skb
  print_mat(sheet8,"\t")
  
  CSV.open(output_folder+'/Sheet8.csv', 'w') do |writer|
    sheet8.each{|row| writer << row}
  end
end

rcd_main input_file,output_folder