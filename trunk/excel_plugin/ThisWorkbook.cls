VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Public active As Boolean            ' run script?

Private Sub Workbook_SheetChange(ByVal Sh As Object, ByVal Target As Range)
   
    If active And Application.ActiveSheet.name = "RCD Input" And Target.row <> 1 Then
        If isValidInputSheet(Sh) Then
            Cells(1, 1).Value = "Valid"
        Else: Cells(1, 1).Value = "Invalid"
        End If
    End If
    
End Sub
