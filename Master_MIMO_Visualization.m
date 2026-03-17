
%% ================================================================
%% MASTER INTEGRATION FILE FOR ENHANCED MIMO ANTENNA VISUALIZATION
%% ================================================================
% This is the main file that integrates all visualization modules
% Run this file to get the complete CST-like experience

clear all; close all; clc;

fprintf('\n=== ENHANCED MIMO ANTENNA - COMPLETE 3D VISUALIZATION SUITE ===\n');
fprintf('Initializing CST-like visualization environment...\n');

%% Design Parameters
W = 18e-3; L = 26.5e-3; h = 1.6e-3; er = 4.4;
freq = 4e9; freq_range = 3.3e9:0.1e9:5.1e9;
element_spacing = 25e-3; ground_size = 50e-3;

%% Create MIMO Array
try
    substrate = dielectric('FR4');
    substrate.EpsilonR = er; substrate.Thickness = h;

    patch1 = patchMicrostrip('Length', L, 'Width', W, ...
                            'Substrate', substrate, 'Height', h, ...
                            'GroundPlaneLength', ground_size, ...
                            'GroundPlaneWidth', ground_size);

    mimo_array = rectangularArray('Element', patch1, 'Size', [2 2], ...
                                  'RowSpacing', element_spacing, ...
                                  'ColumnSpacing', element_spacing);

    fprintf('✓ MIMO array created successfully\n');
catch
    fprintf('⚠ Error creating MIMO array, using simplified version\n');
    patch_simple = patchMicrostrip('Length', L, 'Width', W, 'Height', h);
    mimo_array = rectangularArray('Element', patch_simple, 'Size', [2 2], ...
                                  'RowSpacing', element_spacing, ...
                                  'ColumnSpacing', element_spacing);
end

%% Execute Main Visualization
fprintf('\nExecuting main 3D visualization...\n');
try
    run('Enhanced_MIMO_Antenna_3D_Visualization.m');
    fprintf('✓ Main visualization completed\n');
catch ME
    fprintf('⚠ Main visualization error: %s\n', ME.message);
end

%% Execute Specialized Modules
fprintf('\nExecuting specialized analysis modules...\n');

% Mesh Analysis
try
    analyze_mesh_quality(mimo_array, freq);
    fprintf('✓ Mesh analysis completed\n');
catch ME
    fprintf('⚠ Mesh analysis error: %s\n', ME.message);
end

% Field Analysis
try
    analyze_fields_comprehensive(mimo_array, freq);
    fprintf('✓ Field analysis completed\n');
catch ME
    fprintf('⚠ Field analysis error: %s\n', ME.message);
end

% Report Generation
try
    generate_report(mimo_array, freq, freq_range);
    fprintf('✓ Report generation completed\n');
catch ME
    fprintf('⚠ Report generation error: %s\n', ME.message);
end

% 3D Animations (Optional - can be slow)
user_choice = input('\nDo you want to run 3D animations? (y/n): ', 's');
if strcmpi(user_choice, 'y')
    try
        create_3d_animations(mimo_array, freq);
        fprintf('✓ 3D animations completed\n');
    catch ME
        fprintf('⚠ Animation error: %s\n', ME.message);
    end
end

%% Final Summary
fprintf('\n=== COMPLETE VISUALIZATION SUITE FINISHED ===\n');
figHandles = findall(0, 'Type', 'figure');
numFigures = numel(figHandles);
fprintf('Total figures generated: %d\n', numFigures);
fprintf('\n=== CST-LIKE FEATURES AVAILABLE ===\n');
fprintf('✓ 3D Geometry with Professional Lighting\n');
fprintf('✓ Interactive Mesh Visualization\n');
fprintf('✓ Multiple Radiation Pattern Views\n');
fprintf('✓ 3D Current Distribution with Vectors\n');
fprintf('✓ Near-Field E-H Visualization\n');
fprintf('✓ Comprehensive Field Analysis\n');
fprintf('✓ Professional Report Generation\n');
fprintf('✓ Interactive 3D Controls (Rotate/Zoom)\n');
fprintf('✓ Animation Capabilities\n');
fprintf('✓ Export and Documentation\n');
fprintf('\nUse mouse to interact with 3D plots!\n');
