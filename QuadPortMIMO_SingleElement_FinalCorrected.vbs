
' HFSS Script: Single Element of Quad-Port MIMO Antenna with Metamaterial Superstrate
' Updated: Enable SolveInside for dielectric materials

Set oAnsoftApp = CreateObject("Ansoft.ElectronicsDesktop")
Set oDesktop = oAnsoftApp.GetAppDesktop()
Set oProject = oDesktop.NewProject()
Set oDesign = oProject.InsertDesign("HFSS", "QuadPortMIMO", "DrivenModal", "")
Set oEditor = oDesign.SetActiveEditor("3D Modeler")

' ---------------------------
' 1) Substrate (FR4_epoxy, SolveInside = true)
oEditor.CreateBox _
  Array("NAME:BoxParameters", "XPosition:=", "0mm", "YPosition:=", "0mm", "ZPosition:=", "0mm", _
        "XSize:=", "50mm", "YSize:=", "50mm", "ZSize:=", "1.6mm"), _
  Array("NAME:Attributes", "Name:=", "Substrate", "MaterialName:=", "FR4_epoxy", "SolveInside:=", true)

' ---------------------------
' 2) Ground Plane (PEC)
oEditor.CreateRectangle _
  Array("NAME:RectangleParameters", "XStart:=", "0mm", "YStart:=", "0mm", "ZStart:=", "0mm", _
        "Width:=", "50mm", "Height:=", "50mm", "WhichAxis:=", "Z"), _
  Array("NAME:Attributes", "Name:=", "Ground", "MaterialName:=", "pec", "SolveInside:=", false)

' ---------------------------
' 3) Patch Element
oEditor.CreateRectangle _
  Array("NAME:RectangleParameters", "XStart:=", "16mm", "YStart:=", "11.75mm", "ZStart:=", "1.6mm", _
        "Width:=", "3.5mm", "Height:=", "11.6mm", "WhichAxis:=", "Z"), _
  Array("NAME:Attributes", "Name:=", "Patch", "MaterialName:=", "pec", "SolveInside:=", false)

' ---------------------------
' 4) Slot Cut-Out in Patch
oEditor.CreateRectangle _
  Array("NAME:RectangleParameters", "XStart:=", "17.3mm", "YStart:=", "12mm", "ZStart:=", "1.6mm", _
        "Width:=", "2.4mm", "Height:=", "12.5mm", "WhichAxis:=", "Z"), _
  Array("NAME:Attributes", "Name:=", "Slot", "MaterialName:=", "vacuum", "SolveInside:=", true)

oEditor.Subtract _
  Array("NAME:Selections", "Blank Parts:=", "Patch", "Tool Parts:=", "Slot"), _
  Array()

' ---------------------------
' 5) Superstrate Layer (Air, SolveInside = false)
oEditor.CreateBox _
  Array("NAME:BoxParameters", "XPosition:=", "0mm", "YPosition:=", "0mm", "ZPosition:=", "16.6mm", _
        "XSize:=", "50mm", "YSize:=", "50mm", "ZSize:=", "1.5mm"), _
  Array("NAME:Attributes", "Name:=", "Superstrate", "MaterialName:=", "air", "SolveInside:=", false)

' ---------------------------
' 6) Radiation Boundary Box
oEditor.CreateBox _
  Array("NAME:BoxParameters", "XPosition:=", "-10mm", "YPosition:=", "-10mm", "ZPosition:=", "-10mm", _
        "XSize:=", "70mm", "YSize:=", "70mm", "ZSize:=", "40mm"), _
  Array("NAME:Attributes", "Name:=", "RadBox", "MaterialName:=", "vacuum", "SolveInside:=", true)

Set oBound = oDesign.GetModule("BoundarySetup")
oBound.AssignRadiation _
  Array("NAME:RadBnd", "Objects:=", Array("RadBox"), "IsMultiRegion:=", false)

' ---------------------------
' 7) Lumped Port Feed
oEditor.CreateRectangle _
  Array("NAME:RectangleParameters", "XStart:=", "17mm", "YStart:=", "11.75mm", "ZStart:=", "1.6mm", _
        "Width:=", "0.5mm", "Height:=", "1.5mm", "WhichAxis:=", "Y"), _
  Array("NAME:Attributes", "Name:=", "Port1", "MaterialName:=", "vacuum", "SolveInside:=", true)

Set oExcite = oDesign.GetModule("Excitation")
oExcite.AssignLumpedPort _
  Array("NAME:Port1_Lumped", "Objects:=", Array("Port1"), "PortName:=", "Port1", "Impedance:=", "50ohm")

' ---------------------------
' 8) Analysis Setup
Set oSetup = oDesign.GetModule("AnalysisSetup")
oSetup.InsertSetup "HfssDriven", _
  Array("NAME:Setup1", "Frequency:=", "4GHz", "PortsOnly:=", false, "MaxDeltaS:=", 0.02)

oSetup.InsertFrequencySweep "Setup1", _
  Array("NAME:Sweep1", "IsEnabled:=", true, "StartValue:=", "3GHz", "StopValue:=", "6GHz", _
        "Count:=", 61, "Type:=", "LinearStep")

' ---------------------------
' 9) Save Project
oProject.SaveAs "QuadPortMIMO_SingleElement_FinalCorrected.aedt", true
