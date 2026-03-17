
' HFSS Script for Single Element of Quad-Port MIMO Antenna with Metamaterial Superstrate
' Based on IEEE Paper: "Enhanced Quad-Port MIMO Antenna Isolation With Metamaterial Superstrate"

Set oAnsoftApp = CreateObject("Ansoft.ElectronicsDesktop")
Set oDesktop = oAnsoftApp.GetAppDesktop()
Set oProject = oDesktop.NewProject
Set oDesign = oProject.InsertDesign("HFSS", "QuadPortMIMO", "DrivenModal", "")
Set oEditor = oDesign.SetActiveEditor("3D Modeler")

' -------------------------------------------------------------
' Create Substrate
oEditor.CreateBox Array(0, 0, 0), Array("50mm", "50mm", "1.6mm"), "FR4_epoxy"

' Create Ground Plane
oEditor.CreateRectangle "ground", "Z", Array(0, 0, 0), Array("50mm", "50mm")
oEditor.AssignMaterial "ground", "pec"
oEditor.AssignBoundary "ground", "PerfectE"

' Create Patch
oEditor.CreateRectangle "patch", "Z", Array("16mm", "11.75mm", "1.6mm"), Array("3.5mm", "11.6mm")
oEditor.AssignMaterial "patch", "pec"

' Create Slot in Patch
oEditor.CreateRectangle "slot", "Z", Array("17.3mm", "12mm", "1.6mm"), Array("2.4mm", "12.5mm")
oEditor.Subtract Array("patch"), Array("slot")

' Create Superstrate (Metamaterial Layer)
oEditor.CreateBox Array(0, 0, "16.6mm"), Array("50mm", "50mm", "1.5mm"), "air"

' Assign Radiation Boundary
oEditor.CreateBox Array("-10mm", "-10mm", "-10mm"), Array("70mm", "70mm", "40mm"), "air"
oEditor.AssignBoundary "radiation", "Radiation"

' Assign Port (Lumped Port as example)
oEditor.CreateRectangle "port", "Y", Array("17mm", "11.75mm", "1.6mm"), Array("0.5mm", "1.5mm")
oEditor.AssignLumpedPort "port", "z"

' Analysis Setup
Set oModule = oDesign.GetModule("AnalysisSetup")
oModule.InsertSetup "HfssDriven", Array("Name:Setup1", "Frequency:=", "4GHz", "PortsOnly:=", false)
oModule.InsertFrequencySweep "Setup1", Array("Name: Sweep1", "StartFrequency:=", "3GHz", "StopFrequency:=", "6GHz", "Type:=", "LinearStep", "StepSize:=", "0.05GHz")

' Save Project
oProject.SaveAs "QuadPortMIMO_SingleElement.aedt", True
