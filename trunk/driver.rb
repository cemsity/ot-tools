# driver.rb - this will be the command-line interface for the RCD algorithms
# Usage: "ruby driver.rb <input file> <output directory>"

require 'RCD'
require 'Util'
require 'OT_general'

ARGV[0] = 'input.csv' unless ARGV[0]
ARGV[1] = 'output' unless ARGV[1]

# rcd_main:
#   Reads the input from file named input_file.
#   Writes the sorted CT to output/CT_view.csv
#              sorted VT to output/VT_view.csv
#              mother of all tableaux to output/mother.csv
#              stratum sizes to the first row of output/strata.csv
def rcd_main(input_file,output_folder)
  vt_table, header, top_comment = *get_input(input_file)
  vt_table_formatted, header_formatted = *format_input(vt_table, header)

  p header_formatted
  vt_table_formatted.each { |r| p r }

  ct_table = ct_from_vt(vt_table.copy_mat)
  strata = rcd(copy_mat(ct_table))
  # p strata
  
  raise('No solution found') if strata == nil
  
  vt_view = [header] + (0...lbls.size).map{|i| lbls[i]+vt[i]}
  ct_view = [header] + (0...lbls.size).map{|i| lbls[i]+ct[i]}
  moth = mother(header,lbls,vt,ct)
  
  CSV.open(folder+'/VT_View.csv', 'w') do |writer|
    vt_view.each{|row| writer << row}
  end
  CSV.open(folder+'/CT_View.csv', 'w') do |writer|
    ct_view.each{|row| writer << row}
  end
  CSV.open(folder+'/Strata.csv', 'w') do |writer|
    writer << strata.map{|x|x.size}
  end
  CSV.open(folder+'/Mother.csv', 'w') do |writer|
    moth.each{|row| writer << row}
  end
end

rcd_main *ARGV[0..1]