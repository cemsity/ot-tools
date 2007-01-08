Attribute VB_Name = "OTtools"
Sub Setup()

Dim aSheet As Object        ' for looping through and clearing sheets
Dim allEmpty As Boolean     ' for checking if all sheets are empty
Dim cont As Boolean         ' for checking if user wants to clear everything/continue
Dim question As String      ' for asking if user wants to clear everything/continue

' initiating variables
allEmpty = True
cont = True
question = "The following sheets are not empty:" + vbCr

' find non-empty sheets, construct question if user wants to clear them
For Each aSheet In ActiveWorkbook.Sheets
    If Not isEmptySheet(aSheet) Then
        allEmpty = False
        question = question + vbCr + "    " + aSheet.name
    End If
Next aSheet

' ask if user wants to clear them
If Not allEmpty Then
    question = question + vbCr + vbCr + "I am about to delete everything in them, are you sure?"
    If MsgBox(question, vbYesNo, "Question") = vbYes Then
        cont = True
    Else: cont = False
    End If
End If

' clear the sheets, set up input sheet
If cont Then
    For Each s In Excel.Sheets
        If Excel.Sheets.Count = 1 Then
            s.Cells.Delete Shift:=xlUp
            s.name = "RCD Input"
        Else
            Application.DisplayAlerts = False
            s.Delete
            Application.DisplayAlerts = True
        End If
    Next
        
    Cells(1, 1).Value = "Line for comments..."
    Cells(1, 1).Font.Bold = True
    
    Cells(2, 1).Value = "Input"
    Cells(2, 2).Value = "Output"
    Cells(2, 3).Value = "Opt"
    Cells(2, 5).Value = "Remarks"
    
End If

End Sub

Function isEmptySheet(aSheet As Object)
    
    If IsNull(aSheet.Cells.Text) Then
        isEmptySheet = False
    Else: isEmptySheet = True
    End If
End Function

