require 'win32ole'
  
def setup
  @excel = WIN32OLE::new('excel.Application')
  @excel.Visible = true
  if !Interactive then
    workbook = @excel.Workbooks.Open(Dir.pwd.chomp('/') + '/input.xls')
  else
    workbook = @excel.Workbooks.Add
    workbook.Worksheets(2).delete while workbook.Worksheets.Count > 1
    worksheet = workbook.Worksheets(1)
    
    worksheet.Name = "OT Input"
    
    worksheet.Range("A1:E2").Value = [['Line for comments...','','','',''],['Input','Output','Opt','','Remarks']]
    
    worksheet.Range("A2:B2").Font.Bold = "True"
    worksheet.Range("E2").Font.Italic = "True"
  end
  
  @workbook = @excel.Workbooks(1)
  @inputSheet = @workbook.Worksheets(1)
end