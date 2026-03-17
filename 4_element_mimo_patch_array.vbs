
'============================================================
' CST 2019 VBScript: 4-Element MIMO Patch Antenna with DGS
' Frequency: 3.2 GHz | Substrate: FR4 | 2x2 Array | 45° Rotated
'============================================================

Sub Main()
    ' Set units
    With Units
        .Geometry "mm"
        .Frequency "GHz"
    End With

    ' Define FR4 (lossy) material
    With Material
        .Reset
        .Name "FR4 (lossy)"
        .Folder ""
        .Type "Normal"
        .Epsilon 4.3
        .TanD 0.025
        .Colour 0,0,255
        .Create
    End With

    ' Create Substrate
    With Brick
        .Reset
        .Name "Substrate"
        .Component "Component1"
        .Material "FR4 (lossy)"
        .Xrange "-29", "29"
        .Yrange "-30", "30"
        .Zrange "-1.6", "0"
        .Create
    End With

    ' Create Ground Plane
    With Brick
        .Reset
        .Name "Ground"
        .Component "Component1"
        .Material "PEC"
        .Xrange "-29", "29"
        .Yrange "-30", "30"
        .Zrange "-1.6", "-1.57"
        .Create
    End With

    ' Create Feed Line
    With Brick
        .Reset
        .Name "Feed"
        .Component "Component1"
        .Material "PEC"
        .Xrange "-1.41", "1.41"
        .Yrange "0", "7.07"
        .Zrange "0", "0.03"
        .Create
    End With

    ' Create Patch
    With Brick
        .Reset
        .Name "Patch"
        .Component "Component1"
        .Material "PEC"
        .Xrange "-9.575", "9.575"
        .Yrange "7.07", "31.07"
        .Zrange "0", "0.03"
        .Create
    End With

    ' Merge Feed + Patch
    With Boolean
        .Reset
        .Name "PatchWithFeed"
        .Component "Component1"
        .Operation "Add"
        .FirstObject "Patch"
        .SecondObject "Feed"
        .Delete1 True
        .Delete2 True
        .CreateNewObject True
    End With

    ' Create Left Slot (for DGS)
    With Brick
        .Reset
        .Name "Slot_L"
        .Component "Component1"
        .Material "PEC"
        .Xrange "-4.5", "4.5"
        .Yrange "10", "12.5"
        .Zrange "0", "0.03"
        .Create
    End With

    ' Create Right Slot (for DGS)
    With Brick
        .Reset
        .Name "Slot_R"
        .Component "Component1"
        .Material "PEC"
        .Xrange "-6", "6"
        .Yrange "20", "22.5"
        .Zrange "0", "0.03"
        .Create
    End With

    ' Subtract Slots from PatchWithFeed
    With Boolean
        .Reset
        .Name "PatchFinal"
        .Component "Component1"
        .Operation "Subtract"
        .FirstObject "PatchWithFeed"
        .SecondObject "Slot_L"
        .Delete1 True
        .Delete2 True
        .CreateNewObject True
    End With

    With Boolean
        .Reset
        .Name "PatchFinal"
        .Component "Component1"
        .Operation "Subtract"
        .FirstObject "PatchFinal"
        .SecondObject "Slot_R"
        .Delete1 True
        .Delete2 True
        .CreateNewObject False
    End With

    ' Duplicate and rotate elements to form 4-element MIMO
    With Transform
        .Reset
        .Name "Copy1"
        .Vector "47", "0", "0"
        .MultipleObjects True
        .UsePickedObjects False
        .GroupObjects False
        .Repetitions 1
        .Destination "Component1"
        .Material ""
        .Transform "Copy"
    End With

    With Transform
        .Reset
        .Name "Copy2"
        .Vector "0", "47", "0"
        .MultipleObjects True
        .UsePickedObjects False
        .GroupObjects False
        .Repetitions 1
        .Destination "Component1"
        .Material ""
        .Transform "Copy"
    End With

    With Transform
        .Reset
        .Name "RotateArray"
        .Center "0", "0", "0"
        .Angle "45"
        .Axis "z"
        .MultipleObjects True
        .UsePickedObjects False
        .GroupObjects False
        .Transform "Rotate"
    End With

    ' Define open boundary and frequency range
    With Boundary
        .Xmin "open"
        .Xmax "open"
        .Ymin "open"
        .Ymax "open"
        .Zmin "expanded open"
        .Zmax "expanded open"
        .ApplyInAllDirections "False"
        .Type "open"
        .Create
    End With

    With Solver
        .Reset
        .FrequencyRange "1", "6"
        .SolverType "FrequencyDomain"
        .Start
    End With
End Sub
