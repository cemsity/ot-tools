	### autofit word/pronunciation columns (before putting in comments)

require 'rcd'
require 'fred'
require 'ot'
require 'excel'
Interactive = false
Command_line = true

# Validates @inputSheet, returns [numConstraints, numLines] in said worksheet
def get_dims
  col = 3
  while cell(2,col).Value != 'Remarks'
    col += 1
    break if range(2, col,2, col+10).Text == ""
  end

  row = 3
  while range(row, 2, row+10, 2).Text != ""
    row += 1
  end
  [col-5, row-3]
end

# runs RCD algorithm
def rcd
  #@excel.activeSheet = @inputSheet
  E[0..-1]='e'

  # Validate input
  numConstraints, numLines = get_dims
  return nil if not numConstraints or not numLines
  input = range(1,1,numLines+2, numConstraints+5).Value
    
  sheet_format_input(input)
  sheet_ct_standard
  sheet_rcd_view
  sheet_filtration(numConstraints)
end

def sheet_format_input(input)
  # Sheet 2 #  
    # format input
    @formatted_input = format_input(input)
    height = @formatted_input.size
    width = @formatted_input[1].size
    
    # add sheet
    @formattedSheet = @workbook.Worksheets.Add nil, @inputSheet
    @formattedSheet.Name = "Input Formatted"
    
    
    # output data
    range(1,1,height, width).Value = @formatted_input
    
    # format sheet
    range(2,1,height, width-2).Borders.Weight = 2            # thin-line grid
    range(2,4,height, width-2).HorizontalAlignment = -4108   # center text
    range(1,1,1, width-2).Borders(9).Weight = 3              # top hard line
    range(2,1,2, width-2).Borders(9).LineStyle = -4119       # top double line
    range(2,4,height, 4).Borders(10).LineStyle = -4119       # vertical double line
    @formattedSheet.Columns(4).EntireColumn.AutoFit
    @formattedSheet.Columns(width).EntireColumn.AutoFit
    
    # strong horizontal lines
    @ct_data, @block_sizes = ct_standard(@formatted_input.copy_mat)
    row=2
    for add in @block_sizes do
      range((row+=add),1,row, width-2).Borders(9).Weight = 3
    end
end

def sheet_ct_standard
  # Sheet 3 #
    # make sheet
    @ctSheet = @workbook.Worksheets.Add nil, @formattedSheet
    @ctSheet.Name = "CT Standard"
    
    # calculate data
    height = @ct_data.size
    width = @ct_data[1].size
    
    format_ct = proc do
      # output data
      range(1,1,height, width).Value = @ct_data
      
      #format sheet
      range(2,1,height, width).Borders.Weight = 2             # thin-line grid
      range(2,5,height, width).HorizontalAlignment = -4108    # center text
      range(1,1,1, width).Borders(9).Weight = 3               # top hard line
      range(2,1, 2, width).Borders(9).LineStyle = -4119        # top double line
      range(2,4,height, 4).Borders(10).LineStyle = -4119      # vertical double line
      
      # strong horizontal lines
      row = 2
      for add in @block_sizes[0..-2] do
        range((row+=add-1),1,row, width).Borders(9).Weight = 3
      end
      
      range(1,1, height,width).each { |cur_cell| cur_cell.Font.Bold = "True" if [W,L].include?(cur_cell.Text) }
    end
    format_ct[]

  # Sheet 4 # CT without e's
    E[0...1] = ''
    @ctSheet2 = @workbook.Worksheets.Add nil, @ctSheet
    @ctSheet2.Name = "CT no e's"
    
    # output data
    range(1,1,height, width).Value = @ct_data
    format_ct[]
end

def sheet_rcd_view
  # Sheet 5 #
    # make sheets
    @rcdSheet = @workbook.Worksheets.Add nil, @ctSheet2
    @rcdSheet.Name = "RCD View"
    
    # calculate data
    @strata, $success = do_rcd(@ct_data.every[4..-1])
    strata_len = [0]
    @strata.each{|x| strata_len << strata_len[-1]+x.size}
    
    @sorted_strata = sort_by_strata(@ct_data.copy_mat,@strata)
    
    height = @sorted_strata.size
    width = @sorted_strata[1].size
    
    # output data
    range(1,1, height, width).Value = @sorted_strata
    
    # format sheet
    range(2,1,height, width).Borders.Weight = 2                   # thin-line grid
    range(2,5,height, width).HorizontalAlignment = -4108          # center text
    range(1,1,1, width).Borders(9).Weight = 3                     # top hard line
    range(2,1,2, width).Borders(9).LineStyle = -4119              # top double line
    range(2,4,height, 4).Borders(10).LineStyle = -4119            # vertical double line
    
    # highlight W's and L's
    range(2,5,height,width).each { |cur_cell| cur_cell.Font.Bold = "True" if [W,L].include?(cur_cell.Text) }  
    
    # draw strong vertical lines
    for n in strata_len
      range(2,n+4,height, n+4).Borders(10).Weight = 3             # vertical hard lines
    end
    
    # draw strong horizontal lines
    curStratum = 0
    layers = []
    for n in (3..height+1)
      if range(n,5+strata_len[curStratum],n, 4+strata_len[curStratum+1]).Text == ""
        range(n-1,1,n-1, width).Borders(9).Weight = 3             # horizontal hard lines
        layers << n
        curStratum += 1
      end
    end

    # Check failure
    unless $success then
      range(layers[-1]-1,1,layers[-2],1).Interior.ColorIndex = 3
      cell(layers[-1],1).Value = "FAIL!"
      cell(layers[-1],1).Font.Bold = true
    end
end

def sheet_filtration(numConstraints)
    # filtration
    # make sheet
    @filtrSheet = @workbook.Worksheets.Add nil, @rcdSheet
    @filtrSheet.Name = "Filtration View"
    
    # calculate data
    filtr_data = filtration(@formatted_input.every.r.map{|x|x.instance_of?(Float) ? x.to_i : x}, @block_sizes, @strata.flatten, numConstraints).every(2).r.to_s
    height = filtr_data.size
    width = filtr_data[1].size - 2
    
    # output data
    range(1,1,height, width+2).Value=filtr_data
    
    # format sheet
    range(2,1,height, width).Borders.Weight = 2                   # thin-line grid
    range(2,1,height, 1).borders(10).lineStyle = -4119            # double line after Cand#
    range(2,4,height, 4).borders(10).lineStyle = -4119            # double line after Opt
    range(2,1,height, width).horizontalAlignment = -4108          # center data
    range(1,2,4,2).horizontalAlignment = -4131                    # left-align headings
    range(3,2,height, 2).horizontalAlignment = -4131              # left-align input
    range(3,3,height, 3).horizontalAlignment = -4152              # right-align outputs
    row = 3
    ([0]+@block_sizes[0..-2]).each do |blk|
      cel = cell((row+=blk),3)
      cel.font.bold = true
      cel.horizontalAlignment = -4131
      range(row,1,row,width).borders(8).lineStyle = -4119
    end
end

# runs FRED algorithm
def fred
  #@excel.activeSheet = @inputSheet
  E[0..-1]=''
  
  #strata, success = do_rcd(@ct_data.every[4..-1])
  #@sorted_strata = sort_by_strata(@ct_data,@strata)
  
  # compute FRed
  success, inform_basis, skeletal_basis, verbose = do_fred(@sorted_strata, @strata)
  
  # output informative basis
  @informBasis = @workbook.Worksheets.Add nil, @inputSheet
  @informBasis.Name = "MIB"
  range(1,1,inform_basis.size, inform_basis[1].size).Value = inform_basis
  
  # format sheet
  range(2,1,inform_basis.size, inform_basis[1].size).Borders.Weight = 2          # grid
  range(1,1,1, inform_basis[1].size).Borders(9).Weight = 3                       # heavy top line
  range(2,1,2, inform_basis[1].size).Borders(9).LineStyle = -4119                # double top line

  range(3,2,inform_basis.size+1,inform_basis[1].size).each do |cur_cell|
    cur_cell.Font.Bold = true if [W,L].include?(cur_cell.Text)
  end
  
  # output skeletal basis
  @skeletBasis = @workbook.Worksheets.Add nil, @informBasis
  @skeletBasis.Name = "Skeletal Basis"
  range(1,1,skeletal_basis.size, inform_basis[1].size).Value = skeletal_basis
  
  # format sheet
  range(2,1,skeletal_basis.size , skeletal_basis[1].size).Borders.Weight = 2       # grid
  range(1,1,1, skeletal_basis[1].size).Borders(9).Weight = 3                       # heavy top line
  range(2,1,2, skeletal_basis[1].size).Borders(9).LineStyle = -4119                # double top line
  
  range(3,2,inform_basis.size+1,inform_basis[1].size).each do |cur_cell|
    cur_cell.Font.Bold = "True" if [W,L].include?(cur_cell.Text)
  end
  
  # Verbose
  height = verbose.size
  width = verbose[1].size-1
  @verboseSheet = @workbook.Worksheets.Add nil,@skeletBasis
  @verboseSheet.Name = 'FRed Verbose'
  range(1,1,verbose.size,verbose[1].size).value=verbose
  for row in 2...height
    next unless test = verbose[row-1][0][0]
    range(row,1,row,width).borders.weight = 2
    cell(row,1).font.bold = true if test == 65
    range(row,2,row,width+1).Font.Bold = true if test == 102
    test2 = verbose[row-1][-1][0]
    cell(row,width+1).interior.colorIndex = 4 if test2==75
    range(row,2,row,width+1).interior.colorIndex = 15 if test2 == 69
  end
end

# clears all worksheets but input
def clear(sheets=nil)
  @excel.DisplayAlerts = "False"
  if sheets
    @workbook.worksheets.each do |worksheet|
      worksheet.delete if sheets.include?(worksheet.Name)
    end
  else
    del=false
    @workbook.worksheets.each do |worksheet|
      worksheet.delete if del
      del = true
    end
  end
  @excel.DisplayAlerts = "True"
end

def main
  setup
  if Interactive then
    puts  "Enter the data in Excel, then hit enter."
    gets
  end
  rcd
  fred #if $success
end

main