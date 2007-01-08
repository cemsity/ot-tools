Attribute VB_Name = "Module1"
Sub RCD()
Attribute RCD.VB_Description = "Macro recorded 1/6/2007 by ."
Attribute RCD.VB_ProcData.VB_Invoke_Func = " \n14"

' Check that sheet is valid input
If Application.ActiveSheet.name = "RCD Input" Then
    If Not isValidInputSheet(Application.ActiveSheet) Then
        MsgBox "Invalid input sheet formatting."
    End If
End If

' Write output to file

End Sub
Function writeRangeToFile(aRange As Range) As Boolean

End Function

Function isValidInputSheet(aSheet As Object) As Boolean
    Dim line, col, opts, constraints As Integer
    
    isValidInputSheet = True    ' flag
    line = 3                    ' counting lines
    col = 4                     ' counting columns
    constraints = 0             ' num of constraints
    
    ' count constraints
    While Cells(2, col).Value <> ""
        col = col + 1
    Wend
    
    constraints = col - 4
    
    ' second first line looking OK at end?
    If Cells(2, col + 1).Value <> "Remarks" Then
        isValidInputSheet = False
    End If

    ' for each input
    While Cells(line, 1).Value <> ""
        opts = 0
    
        ' there is at least one output
        If Cells(line, 2).Value = "" Then
            isValidInputSheet = False
        End If
        
        ' go through the rest of the outputs
        While Cells(line, 2).Value <> ""
            ' increment opt counter
            If Cells(line, 3).Value <> "" Then
                opts = opts + 1
            End If
        
            ' check if the constraints ratings are defined for each output
            For col = 4 To 3 + constraints
                If Cells(line, col).Value = "" Or (Not IsNumeric(Cells(line, col).Value)) Then
                    isValidInputSheet = False
                End If
            Next col

            line = line + 1
        
            ' check that next line's col1 - empty?
            If Cells(line, 1).Value <> "" Then
                isValidInputSheet = False
            End If
        Wend
        
        ' did we count exactly one opt?
        If opts <> 1 Then
            isValidInputSheet = False
        End If
        
        line = line + 1
        
        ' If the next line col1 is empty, are the next 100 lines empty? - then we're done
        ' otherwise something's wrong
        If Cells(line, 1).Value = "" Then
            If IsNull(Range(Str(line) + ":" + Trim(Str(line + 100))).Text) Then
                isValidInputSheet = False
            End If
        End If
    Wend
End Function

