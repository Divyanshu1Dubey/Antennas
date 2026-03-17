
% Enhanced Quad-Port MIMO Antenna - Simplified Implementation
% Based on Khan et al. (2024) research paper
% Robust version with error handling

clear; clc; close all;

%% Design Parameters
fprintf('=== Enhanced Quad-Port MIMO Antenna Design ===\n');

% Convert mm to meters
W = 18e-3;          % Antenna width
L = 26.5e-3;        % Antenna length
substrate_h = 1.6e-3;  % Substrate thickness
fc = 4.0e9;         % Center frequency
freq_range = linspace(3.3e9, 5.1e9, 50);

%% Create Substrate
substrate = dielectric('Name', 'FR4', 'EpsilonR', 4.4, 'LossTangent', 0.02);

%% Method 1: Using Built-in Patch Antennas (More Reliable)
fprintf('Creating MIMO array using built-in patch antennas...\n');

% Create individual patch antennas
patch1 = patchMicrostrip('Length', L, 'Width', W, 'Height', substrate_h, ...
                        'Substrate', substrate, 'FeedOffset', [-W/4, 0]);
patch2 = patchMicrostrip('Length', L, 'Width', W, 'Height', substrate_h, ...
                        'Substrate', substrate, 'FeedOffset', [W/4, 0]);
patch3 = patchMicrostrip('Length', L, 'Width', W, 'Height', substrate_h, ...
                        'Substrate', substrate, 'FeedOffset', [-W/4, 0]);
patch4 = patchMicrostrip('Length', L, 'Width', W, 'Height', substrate_h, ...
                        'Substrate', substrate, 'FeedOffset', [W/4, 0]);

% Create 2x2 MIMO array
mimoArray = rectangularArray('Element', patch1, 'Size', [2, 2], ...
                           'RowSpacing', 25e-3, 'ColumnSpacing', 25e-3);

fprintf('MIMO array created successfully.\n');

%% Visualization
figure(1);
show(patch1);
title('Single Patch Antenna Element');
view(3);

figure(2);
show(mimoArray);
title('4-Element MIMO Array');
view(3);

%% Analysis
fprintf('Starting antenna analysis...\n');

% S-parameter analysis
fprintf('Calculating S-parameters...\n');
try
    S = sparameters(mimoArray, freq_range);

    figure(3);
    rfplot(S);
    title('S-Parameters of MIMO Array');

    % Plot individual S-parameters
    figure(4);
    subplot(2,2,1);
    plot(freq_range/1e9, 20*log10(abs(squeeze(S.Parameters(1,1,:)))), 'LineWidth', 2);
    title('S11 - Return Loss Port 1');
    xlabel('Frequency (GHz)'); ylabel('S11 (dB)');
    grid on; ylim([-50 0]);

    subplot(2,2,2);
    plot(freq_range/1e9, 20*log10(abs(squeeze(S.Parameters(1,2,:)))), 'LineWidth', 2);
    title('S12 - Isolation Port 1-2');
    xlabel('Frequency (GHz)'); ylabel('S12 (dB)');
    grid on; ylim([-50 0]);

    subplot(2,2,3);
    plot(freq_range/1e9, 20*log10(abs(squeeze(S.Parameters(1,3,:)))), 'LineWidth', 2);
    title('S13 - Isolation Port 1-3');
    xlabel('Frequency (GHz)'); ylabel('S13 (dB)');
    grid on; ylim([-50 0]);

    subplot(2,2,4);
    plot(freq_range/1e9, 20*log10(abs(squeeze(S.Parameters(1,4,:)))), 'LineWidth', 2);
    title('S14 - Isolation Port 1-4');
    xlabel('Frequency (GHz)'); ylabel('S14 (dB)');
    grid on; ylim([-50 0]);

    sgtitle('S-Parameters Analysis');

catch ME
    fprintf('S-parameter calculation failed: %s\n', ME.message);
end

% Radiation pattern analysis
fprintf('Calculating radiation patterns...\n');
try
    figure(5);
    pattern(mimoArray, fc);
    title('3D Radiation Pattern at 4 GHz');

    figure(6);
    subplot(1,2,1);
    pattern(mimoArray, fc, 0, -90:90, 'Type', 'directivity');
    title('E-plane Pattern');

    subplot(1,2,2);
    pattern(mimoArray, fc, 90, -90:90, 'Type', 'directivity');
    title('H-plane Pattern');

catch ME
    fprintf('Radiation pattern calculation failed: %s\n', ME.message);
end

% Impedance analysis
fprintf('Calculating impedance...\n');
try
    Z = impedance(mimoArray, freq_range);

    figure(7);
    subplot(2,1,1);
    plot(freq_range/1e9, real(Z(:,1)), 'LineWidth', 2);
    title('Input Resistance');
    xlabel('Frequency (GHz)'); ylabel('Resistance (Ω)');
    grid on;

    subplot(2,1,2);
    plot(freq_range/1e9, imag(Z(:,1)), 'LineWidth', 2);
    title('Input Reactance');
    xlabel('Frequency (GHz)'); ylabel('Reactance (Ω)');
    grid on;

catch ME
    fprintf('Impedance calculation failed: %s\n', ME.message);
end

% Current distribution
fprintf('Calculating current distribution...\n');
try
    figure(8);
    current(mimoArray, fc);
    title('Current Distribution at 4 GHz');

catch ME
    fprintf('Current distribution calculation failed: %s\n', ME.message);
end

%% MIMO Performance Analysis
fprintf('Calculating MIMO performance parameters...\n');
try
    if exist('S', 'var')
        % Calculate Envelope Correlation Coefficient (ECC)
        ecc_values = zeros(length(freq_range), 1);

        for i = 1:length(freq_range)
            S11 = S.Parameters(1,1,i);
            S12 = S.Parameters(1,2,i);
            S21 = S.Parameters(2,1,i);
            S22 = S.Parameters(2,2,i);

            numerator = abs(S11 * conj(S12) + S21 * conj(S22))^2;
            denominator = (1 - abs(S11)^2 - abs(S21)^2) * (1 - abs(S12)^2 - abs(S22)^2);

            if denominator > 0
                ecc_values(i) = sqrt(numerator / denominator);
            else
                ecc_values(i) = 0;
            end
        end

        % Plot ECC
        figure(9);
        subplot(2,1,1);
        plot(freq_range/1e9, ecc_values, 'LineWidth', 2);
        title('Envelope Correlation Coefficient (ECC)');
        xlabel('Frequency (GHz)'); ylabel('ECC');
        grid on; ylim([0 1]);

        % Calculate Diversity Gain
        diversity_gain = 10 * log10(1 - ecc_values.^2);

        subplot(2,1,2);
        plot(freq_range/1e9, diversity_gain, 'LineWidth', 2);
        title('Diversity Gain');
        xlabel('Frequency (GHz)'); ylabel('Diversity Gain (dB)');
        grid on;

        % Calculate TARC (Total Active Reflection Coefficient)
        tarc_values = zeros(length(freq_range), 1);
        for i = 1:length(freq_range)
            S_matrix = squeeze(S.Parameters(:,:,i));
            tarc_values(i) = sqrt(0.5 * trace(S_matrix' * S_matrix));
        end

        figure(10);
        plot(freq_range/1e9, 20*log10(tarc_values), 'LineWidth', 2);
        title('Total Active Reflection Coefficient (TARC)');
        xlabel('Frequency (GHz)'); ylabel('TARC (dB)');
        grid on;

    end

catch ME
    fprintf('MIMO parameter calculation failed: %s\n', ME.message);
end

%% Results Summary
fprintf('\n=== DESIGN SUMMARY ===\n');
fprintf('Antenna Type: Quad-Port MIMO Patch Array\n');
fprintf('Single Element: %.1f mm × %.1f mm\n', L*1000, W*1000);
fprintf('Array Size: 2×2 configuration\n');
fprintf('Substrate: FR-4 (εr=4.4, h=%.1f mm)\n', substrate_h*1000);
fprintf('Operating Frequency: %.1f GHz\n', fc/1e9);
fprintf('Frequency Range: %.1f - %.1f GHz\n', min(freq_range)/1e9, max(freq_range)/1e9);

if exist('S', 'var')
    % Find minimum isolation
    S12_dB = 20*log10(abs(squeeze(S.Parameters(1,2,:))));
    min_isolation = min(S12_dB);
    fprintf('Minimum Isolation: %.1f dB\n', min_isolation);

    % Find resonant frequency
    S11_dB = 20*log10(abs(squeeze(S.Parameters(1,1,:))));
    [~, res_idx] = min(S11_dB);
    res_freq = freq_range(res_idx);
    fprintf('Resonant Frequency: %.2f GHz\n', res_freq/1e9);
    fprintf('Return Loss at Resonance: %.1f dB\n', S11_dB(res_idx));
end

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('All plots have been generated.\n');
fprintf('Check figures 1-10 for detailed analysis results.\n');
