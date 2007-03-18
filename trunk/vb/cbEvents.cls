VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cbEvents"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public WithEvents cbBtn As CommandBarButton
Attribute cbBtn.VB_VarHelpID = -1

Private Sub cbBtn_Click(ByVal Ctrl As Office.CommandBarButton, CancelDefault As Boolean)
    'supress errors
    On Error Resume Next
    
    MsgBox "Hello World!"
     
    'cancel Excel looking for the sub specified in the OnAction property
    CancelDefault = True
End Sub
