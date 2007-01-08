# driver.rb - this will be the command-line interface for the RCD algorithms
# Usage: "ruby driver.rb <input file> <output directory>"

require 'RCD'
require 'Util'
require 'OT_general'
require 'CSV'
require 'FRed'
input_file =  ARGV[0] ? ARGV[0] : 'Input/input.csv'
output_folder = ARGV[1] ? ARGV[1] : 'Output'

def rcd_main(input_file,output_folder)
  Out_fold[0..-1] = output_folder
  vt_table, header, Top_comm[0..-1] = *get_input(input_file)
  vt_table_formatted, header_formatted = *format_input(vt_table, header)

  output((sheet3=header_formatted + vt_table_formatted), "Input-Formatted", 3)

  sheet4, block_sizes = ct_standard(sheet3.copy_mat)
  output(sheet4, "CT", 4)

  E[0...1] = ''

  output(sheet4, "CT no E", 5)

  strata,remain = *rcd(sheet4.every[4..-1])
  puts '-'*10+"Strata"+'-'*10
  p strata

  sheet6 = sort_by_strata(sheet4,strata+[remain])
  output(sheet6, "RCD View", 6)

  success, sheet7, sheet8 = fred(sheet6, strata)
  output(sheet7, "Most Informative Basis", 7)
  output(sheet8, "Skeletal Basis", 8)
  output(filtration(sheet3, block_sizes, strata+[remain]), "Filtration-View", 9)
  output_data(strata, remain)
end


rcd_main input_file,output_folder