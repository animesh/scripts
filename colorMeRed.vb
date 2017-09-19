Sub colorMeRed()
'
' colorMeRed Macro
' color cell red
'
' Keyboard Shortcut: Ctrl+Shift+R
'
Dim lastRow As Long
Dim sheetName As String

    sheetName = "Sheet1"            'Insert your sheet name here
    lastRow = Sheets(sheetName).Range("A" & Rows.Count).End(xlUp).Row

    For lRow = 2 To lastRow         'Loop through all rows

        'If Sheets(sheetName).Cells(lRow, "A") = Sheets(sheetName).Cells(lRow, "B") Then
        If Sheets(sheetName).Cells(lRow, "A") Like "HMUTYH*" Then
            Sheets(sheetName).Cells(lRow, "A").Interior.ColorIndex = 3  'Set Color to RED
            Sheets(sheetName).Cells(lRow, "K").Value = Sheets(sheetName).Cells(lRow + 1, "H").Value + Sheets(sheetName).Cells(lRow + 1, "H").Value 'Set Value to Sim
        End If

    Next lRow

End Sub

'courtesy https://stackoverflow.com/a/27346256 
