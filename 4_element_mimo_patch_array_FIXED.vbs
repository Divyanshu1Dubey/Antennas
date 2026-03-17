
'============================================================
' CST 2019 VBScript: 4-Element MIMO Patch Antenna with DGS
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

    ' Merge Feed + Patch (Boolean Add)
    Add "Component1:Patch", "Component1:Feed"
    Solid.Delete "Patch"
    Solid.Delete "Feed"
    Solid.Rename "Union1", "Component1", "PatchWithFeed"

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
    Subtract "Component1:PatchWithFeed", "Component1:Slot_L"
    Solid.Delete "PatchWithFeed"
    Solid.Delete "Slot_L"
    Solid.Rename "Subtract1", "Component1", "PatchWithFeed"

    Subtract "Component1:PatchWithFeed", "Component1:Slot_R"
    Solid.Delete "PatchWithFeed"
    Solid.Delete "Slot_R"
    Solid.Rename "Subtract1", "Component1", "PatchFinal"

    ' Duplicate and rotate elements to form 4-element MIMO
    Transform.Reset
    Transform.Name "Copy1"
    Transform.Vector "47", "0", "0"
    Transform.MultipleObjects True
    Transform.GroupObjects False
    Transform.Repetitions 1
    Transform.Destination "Component1"
    Transform.Transform "Copy"

    Transform.Reset
    Transform.Name "Copy2"
    Transform.Vector "0", "47", "0"
    Transform.MultipleObjects True
    Transform.GroupObjects False
    Transform.Repetitions 1
    Transform.Destination "Component1"
    Transform.Transform "Copy"

    Transform.Reset
    Transform.Name "RotateArray"
    Transform.Center "0", "0", "0"
    Transform.Angle "45"
    Transform.Axis "z"
    Transform.MultipleObjects True
    Transform.GroupObjects False
    Transform.Transform "Rotate"

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
