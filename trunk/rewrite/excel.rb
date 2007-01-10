require 'win32ole'
  
def setup
  excel = WIN32OLE::new('excel.Application')
  
  workbook = excel.Workbooks.Add
  
  workbook.Worksheets(2).delete
  workbook.Worksheets(2).delete
  
  worksheet = workbook.Worksheets(1)
  
  worksheet.Name = "OT Input"
  
  worksheet.Range("A1:E2").Value = [['Line for comments...','','','',''],['Input','Output','Opt','','Remarks']]
  
  worksheet.Range("A2:B2").Font.Bold = "True"
  worksheet.Range("E2").Font.Italic = "True"
  
  excel.Visible = true
  
  excel
end