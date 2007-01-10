require 'RCD'
require 'ot'
require 'excel'

puts "\nOT-tools version 1.0"
puts "-"*20

@workbook = setup.Workbooks(1)
@inputSheet = @workbook.Worksheets(1)

# Validates @inputSheet, returns [numConstraints, numLines] in said worksheet
def validate
  print "Counting constraints, lines... "
  
  col = 3
  while @inputSheet.Cells(2,col).Value != 'Remarks'
    col += 1
    break if @inputSheet.Range(@inputSheet.Cells(2, col), @inputSheet.Cells(2, col+10)).Text == "" ###
  end

  row = 3
  while @inputSheet.Range(@inputSheet.Cells(row, 2), @inputSheet.Cells(row+10, 2)).Text != ""
    row += 1
  end
  
  [col-5, row-3]
end

# runs RCD algorithm
def rcd
  # Sheet 2 #
    # Validate input
    numConstraints, numLines = validate
    @formattedSheet = @workbook.Worksheets.Add nil, @inputSheet
    @formattedSheet.Name = "Input Formatted"
    
    # format input
    formatted_input = format_input(@inputSheet.Range(@inputSheet.Cells(1,1), @inputSheet.Cells(numLines+2, numConstraints+5)).Value)
    
    height = formatted_input.length
    width = formatted_input.every.length.max
    
    # output data
    @formattedSheet.Range(@formattedSheet.Cells(1,1), @formattedSheet.Cells(height, width)).Value = formatted_input
    
    # format sheet
    @formattedSheet.Range(@formattedSheet.Cells(2,1), @formattedSheet.Cells(height, width-2)).Borders.Weight = 2            # thin-line grid
    @formattedSheet.Range(@formattedSheet.Cells(2,4), @formattedSheet.Cells(height, width-2)).HorizontalAlignment = -4108   # center text
    @formattedSheet.Range(@formattedSheet.Cells(1,1), @formattedSheet.Cells(1, width-2)).Borders(9).Weight = 3              # top hard line
    @formattedSheet.Range(@formattedSheet.Cells(2,1), @formattedSheet.Cells(2, width-2)).Borders(9).LineStyle = -4119       # top double line
    @formattedSheet.Range(@formattedSheet.Cells(2,4), @formattedSheet.Cells(height, 4)).Borders(10).LineStyle = -4119       # vertical double line
    @formattedSheet.Columns("D:D").EntireColumn.AutoFit
    @formattedSheet.Columns(width).EntireColumn.AutoFit
    
    for row in (3..height) do
      @formattedSheet.Cells(row,1).Text + @formattedSheet.Cells(row+1,1).Text =~ /(^[0-9]+)[a-z]+([0-9]+)/
      @formattedSheet.Range(@formattedSheet.Cells(row,1), @formattedSheet.Cells(row, width-2)).Borders(9).Weight = 3 if $1 != $2
    end
    
  # Sheet 3 #
    # make sheet
    @ctSheet = @workbook.Worksheets.Add nil, @formattedSheet
    @ctSheet.Name = "CT Standard"
    
    # calculate data
    ct_data = ct_standard(formatted_input)
    height = ct_data.length
    width = ct_data.first.length
    
    # output data
    @ctSheet.Range(@ctSheet.Cells(1,1), @ctSheet.Cells(height, width)).Value = ct_data
    
    #format sheet
    @ctSheet.Range(@ctSheet.Cells(2,1), @ctSheet.Cells(height, width)).Borders.Weight = 2             # thin-line grid
    @ctSheet.Range(@ctSheet.Cells(2,5), @ctSheet.Cells(height, width)).HorizontalAlignment = -4108    # center text
    @ctSheet.Range(@ctSheet.Cells(1,1), @ctSheet.Cells(1, width)).Borders(9).Weight = 3               # top hard line
    @ctSheet.Range(@ctSheet.Cells(2,1), @ctSheet.Cells(2, width)).Borders(9).LineStyle = -4119        # top double line
    @ctSheet.Range(@ctSheet.Cells(2,4), @ctSheet.Cells(height, 4)).Borders(10).LineStyle = -4119      # vertical double line
    
    # strong horizontal lines
    for row in (3..height) do
      @ctSheet.Cells(row,1).Text + @ctSheet.Cells(row+1,1).Text =~ /(^[0-9]+)[a-z]+([0-9]+)/        
      @ctSheet.Range(@ctSheet.Cells(row,1), @ctSheet.Cells(row, width)).Borders(9).Weight = 3 if $1 != $2
    end
    
    @ctSheet.Range(@ctSheet.Cells(1,1), @ctSheet.Cells(height,width)).each { |cell| cell.Font.Bold = "True" if ['W','L'].index(cell.Text) }
  
  # Sheet 4 #
    E[0...1] = ''
    @ctSheet2 = @workbook.Worksheets.Add nil, @ctSheet
    @ctSheet2.Name = "CT no e's"
    
    # output data
    @ctSheet2.Range(@ctSheet2.Cells(1,1), @ctSheet2.Cells(height, width)).Value = ct_data
    # format sheet
    @ctSheet2.Range(@ctSheet2.Cells(2,1), @ctSheet2.Cells(height, width)).Borders.Weight = 2             # thin-line grid
    @ctSheet2.Range(@ctSheet2.Cells(2,5), @ctSheet2.Cells(height, width)).HorizontalAlignment = -4108    # center text
    @ctSheet2.Range(@ctSheet2.Cells(1,1), @ctSheet2.Cells(1, width)).Borders(9).Weight = 3               # top hard line
    @ctSheet2.Range(@ctSheet2.Cells(2,1), @ctSheet2.Cells(2, width)).Borders(9).LineStyle = -4119        # top double line
    @ctSheet2.Range(@ctSheet2.Cells(2,4), @ctSheet2.Cells(height, 4)).Borders(10).LineStyle = -4119      # vertical double line
    
    # strong horizontal lines
    for row in (3..height) do
      @ctSheet2.Cells(row,1).Text + @ctSheet2.Cells(row+1,1).Text =~ /(^[0-9]+)[a-z]+([0-9]+)/         
      @ctSheet2.Range(@ctSheet2.Cells(row,1), @ctSheet2.Cells(row, width)).Borders(9).Weight = 3 if $1 != $2
    end
    
    # highlight W's and L's
    @ctSheet2.Range(@ctSheet2.Cells(2,5), @ctSheet2.Cells(height,width)).each { |cell| cell.Font.Bold = "True" if ['W','L'].index(cell.Text) }   
  
  # Sheet 5 #
    # make sheets
    @rcdSheet = @workbook.Worksheets.Add nil, @ctSheet2
    @rcdSheet.Name = "RCD View"
    
    # calculate data
    strata, remain = *do_rcd(ct_data.clone.every[4..-1])
    p ct_data
    sorted_strata = sort_by_strata(ct_data,strata)
    
    height = sorted_strata.length
    width = sorted_strata.first.length
    
    # output data
    @rcdSheet.Range(@rcdSheet.Cells(1,1), @rcdSheet.Cells(height, width)).Value = sorted_strata
    
    # format sheet
    @rcdSheet.Range(@rcdSheet.Cells(2,1), @rcdSheet.Cells(height, width)).Borders.Weight = 2             # thin-line grid
    @rcdSheet.Range(@rcdSheet.Cells(2,5), @rcdSheet.Cells(height, width)).HorizontalAlignment = -4108    # center text
    @rcdSheet.Range(@rcdSheet.Cells(1,1), @rcdSheet.Cells(1, width)).Borders(9).Weight = 3               # top hard line
    @rcdSheet.Range(@rcdSheet.Cells(2,1), @rcdSheet.Cells(2, width)).Borders(9).LineStyle = -4119        # top double line
    @rcdSheet.Range(@rcdSheet.Cells(2,4), @rcdSheet.Cells(height, 4)).Borders(10).LineStyle = -4119      # vertical double line
    
    # highlight W's and L's
    @rcdSheet.Range(@rcdSheet.Cells(2,5), @rcdSheet.Cells(height,width)).each { |cell| cell.Font.Bold = "True" if ['W','L'].index(cell.Text) }  
    
    # draw vertical lines
    for n in (0...strata.every.length.length).map{ |m| strata.every.length[0..m].sum }
      @rcdSheet.Range(@rcdSheet.Cells(2,n+4), @rcdSheet.Cells(height, n+4)).Borders(10).Weight = 3        # vertical hard lines
    end
    
    p strata
end

# runs FRED algorithm
def fred
end

begin
  print "> "
  command = gets
  begin
    output = eval(command)
    print '=> '
    p output
  rescue
    puts $!
  end
end until command == "exit"
