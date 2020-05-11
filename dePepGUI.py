#https://towardsdatascience.com/learn-how-to-quickly-create-uis-in-python-a97ae1394d5 follow with PyInstaller ?
#!pip install PySimpleGUI
import PySimpleGUI as sg
import re
import pandas as pd
def cnt(fname, modName):
    if modName == 'Phosphorylation':
        cnt = cntlib.Phosphorylation()
    elif modName == 'GlyGly':
        cnt = cntlib.GlyGly()
    else:
        cnt = cntlib.Other()
    with open(fname) as handle:
        for line in handle:
            cnt.update(line.encode(encoding = 'utf-8'))
    return(cnt.hexdigest())
layout = [
    [sg.Text('File 1'), sg.InputText(), sg.FileBrowse(),
     sg.Checkbox('Phosphorylation'), sg.Checkbox('GlyGly')
     ],
    [sg.Text('File 2'), sg.InputText(), sg.FileBrowse(),
     sg.Checkbox('Other')
     ],
    [sg.Output(size=(88, 20))],
    [sg.Submit(), sg.Cancel()]
]
window = sg.Window('File Compare', layout)
while True:                             # The Event Loop
    event, values = window.read()
    # print(event, values) #debug
    if event in (None, 'Exit', 'Cancel'):
        break
    if event == 'Submit':
        file1 = file2 = isitmodName = None
        # print(values[0],values[3])
        if values[0] and values[3]:
            file1 = re.findall('.+:\/.+\.+.', values[0])
            file2 = re.findall('.+:\/.+\.+.', values[3])
            isitmodName = 1
            if not file1 and file1 is not None:
                print('Error: File 1 path not valid.')
                isitmodName = 0
            elif not file2 and file2 is not None:
                print('Error: File 2 path not valid.')
                isitmodName = 0
            elif values[1] is not True and values[2] is not True and values[4] is not True:
                print('Error: Choose at least one PTM or Other')
            elif isitmodName == 1:
                print('Info: Filepaths correctly defined.')
                modNames = [] #modNames to compare
                if values[1] == True: modNames.append('GlyGly')
                if values[2] == True: modNames.append('Phosphorylation')
                if values[4] == True: modNames.append('Other')
                filepaths = [] #files
                filepaths.append(values[0])
                filepaths.append(values[3])
                print('Info: File Comparison using:', modNames)
                for modName in modNames:
                    print(modName, ':')
                    print(filepaths[0], ':', cnt(filepaths[0], modName))
                    print(filepaths[1], ':', cnt(filepaths[1], modName))
                    if cnt(filepaths[0],modName) == cnt(filepaths[1],modName):
                        print('Files match for ', modName)
                    else:
                        print('Files do NOT match for ', modName)
        else:
            print('Please choose 2 files.')
window.close()
