VERSION 5.00
Begin {AC0714F6-3D04-11D1-AE7D-00A0C90F26F4} Connect 
   ClientHeight    =   9945
   ClientLeft      =   1740
   ClientTop       =   1545
   ClientWidth     =   6585
   _ExtentX        =   11615
   _ExtentY        =   17542
   _Version        =   393216
   Description     =   "RCD and FRED"
   DisplayName     =   "OT Tools"
   AppName         =   "Microsoft Excel"
   AppVer          =   "Microsoft Excel 11.0"
   LoadName        =   "Startup"
   LoadBehavior    =   3
   RegLocation     =   "HKEY_CURRENT_USER\Software\Microsoft\Office\Excel"
End
Attribute VB_Name = "Connect"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Dim ButtonEvent As cbEvents
Dim ButtonEvents As Collection

Public xlApp As Excel.Application
Attribute xlApp.VB_VarHelpID = -1

'------------------------------------------------------
'this method adds the Add-In to VB
'------------------------------------------------------
Private Sub AddinInstance_OnConnection(ByVal Application As Object, ByVal ConnectMode As AddInDesignerObjects.ext_ConnectMode, ByVal AddInInst As Object, custom() As Variant)
    
    Set xlApp = Application
    
    CreateToolbarButtons
    
End Sub

'------------------------------------------------------
'this method removes the Add-In from VB
'------------------------------------------------------
Private Sub AddinInstance_OnDisconnection(ByVal RemoveMode As AddInDesignerObjects.ext_DisconnectMode, custom() As Variant)

    Set xlApp = Nothing

    RemoveToolbarButtons

End Sub

Public Sub CreateToolbarButtons()
     
     'to make sure the buttons we are about to add aren't added twice
     'try to remove them first
    RemoveToolbarButtons
     
     'declare some variables
    Dim cbBar As Office.CommandBar
    Dim btNew As Office.CommandBarButton
     
     'create a new collection
    Set ButtonEvents = New Collection
     
     'find the worksheet menu bar in excel (this is the one
     'with the file, edit, view etc. commands)
    Set cbBar = xlApp.CommandBars.Add("OT Tools", msoBarTop)
    
     'add a new button to the OT Tools menu
    Set btNew = cbBar.Controls.Add(msoControlButton, , , , True)
    
    With btNew
        .OnAction = "exec"
         'set a unique tag to make our custom controls easy
         'to find later to delete
        .Tag = "ott"
         'set the tooltip text
        .ToolTipText = "RCD and FRED"
         'set the caption that appears in the menu
        .Caption = "OT Tools"
        
        .FaceId = 3038
    End With
     
     'get a new instance of our cbevents class
    Set ButtonEvent = New cbEvents
    
     'now assign the button we created to it
    Set ButtonEvent.cbBtn = btNew
    ButtonEvents.Add ButtonEvent
     
End Sub

Public Sub RemoveToolbarButtons()
     
    Dim cbBar As CommandBar
     
     'supress errors - this is important here as they may not have been created
     'yet or may have been alreday deleted
    On Error Resume Next
    
     'need to remove the command bar (toolbar)
    Set cbBar = xlApp.CommandBars("OT Tools")
    
    cbBar.FindControl().Delete
    cbBar.Delete
    
     'remove event handlers from memory
    Set ButtonEvents = Nothing
    Set ButtonEvent = Nothing
End Sub
