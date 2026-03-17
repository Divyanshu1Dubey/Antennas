
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
        .Colour 0, 0, 1
        .Create
    End With

    ' Substrate
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

    ' Ground
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

    ' Feed
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

    ' Patch
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

    ' Merge Patch + Feed
    Solid.Reset
    Solid.Add "Component1:Patch", "Component1:Feed"
    Solid.Rename "Component1:Patch", "PatchWithFeed"

    ' Left Slot
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

    Solid.Reset
    Solid.Subtract "Component1:PatchWithFeed", "Component1:Slot_L"
    Solid.Rename "Component1:PatchWithFeed", "PatchMinusL"

    ' Right Slot
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

    Solid.Reset
    Solid.Subtract "Component1:PatchMinusL", "Component1:Slot_R"
    Solid.Rename "Component1:PatchMinusL", "PatchFinal"

    ' Duplicate X
    Pick.PickObject "Component1:PatchFinal"
    Transform.Reset
    Transform.Vector "47", "0", "0"
    Transform.MultipleObjects False
    Transform.GroupObjects False
    Transform.Destination "Component1"
    Transform.Duplicate

    ' Duplicate Y
    Pick.PickObject "Component1:PatchFinal"
    Transform.Reset
    Transform.Vector "0", "47", "0"
    Transform.MultipleObjects False
    Transform.GroupObjects False
    Transform.Destination "Component1"
    Transform.Duplicate

    ' Duplicate Diagonal
    Pick.PickObject "Component1:PatchFinal"
    Transform.Reset
    Transform.Vector "47", "47", "0"
    Transform.MultipleObjects False
    Transform.GroupObjects False
    Transform.Destination "Component1"
    Transform.Duplicate

    ' Rotate everything 45 degrees around center
    Pick.PickObject "Component1:PatchFinal"
    Pick.PickObject "Component1:PatchFinal_1"
    Pick.PickObject "Component1:PatchFinal_2"
    Pick.PickObject "Component1:PatchFinal_3"

    Transform.Reset
    Transform.Center "0", "0", "0"
    Transform.MultipleObjects True
    Transform.GroupObjects False
    Transform.Rotate "45", "0", "0", "1"

    ' Boundaries
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

    ' Solver
    With Solver
        .Reset
        .FrequencyRange "1", "6"
        .SolverType "FrequencyDomain"
        .Start
    End With
End Sub
