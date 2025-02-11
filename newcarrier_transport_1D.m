% Carrier Transport Simulation with User Input & Improved Animation
clear; clc; close all;

% Constants
q = 1.6e-19;  % Electron charge (C)
k = 1.38e-23; % Boltzmann constant (J/K)
eps_0 = 8.85e-12; % Vacuum permittivity (F/m)

% Material properties (Silicon, GaAs, Germanium)
materials = {'Si', 'GaAs', 'Ge'};
mobility_n = [1350, 8500, 3900] * 1e-4; % Electron mobility (m²/Vs)
mobility_p = [480, 400, 1900] * 1e-4; % Hole mobility (m²/Vs)

% User selects material
disp('Choose Material: 1 = Si, 2 = GaAs, 3 = Ge');
choice = input('Enter your choice: ');
if choice < 1 || choice > 3
    error('Invalid choice! Select 1, 2, or 3.');
end
material = materials{choice};

% User Inputs
T = input('Enter temperature (Kelvin): ');
L = input('Enter semiconductor length (microns): ') * 1e-6; % Convert to meters
Nx = input('Enter number of spatial points: ');
Nt = input('Enter number of time steps: ');
dt = input('Enter time step (in picoseconds): ') * 1e-12; % Convert to seconds
E_start = input('Enter starting electric field (V/m): ');
E_end = input('Enter ending electric field (V/m): ');

% Assign properties based on material
mu_n = mobility_n(choice);
mu_p = mobility_p(choice);
D_n = mu_n * (k*T/q);
D_p = mu_p * (k*T/q);

% Display chosen material properties
fprintf('\nSelected Material: %s\n', material);
fprintf('Temperature: %.1f K\n', T);
fprintf('Electron Mobility: %.2e m^2/Vs\n', mu_n);
fprintf('Hole Mobility: %.2e m^2/Vs\n', mu_p);
fprintf('Electron Diffusion Coeff: %.2e m^2/s\n', D_n);
fprintf('Hole Diffusion Coeff: %.2e m^2/s\n', D_p);

% Define space and electric field
x = linspace(0, L, Nx);
dx = x(2) - x(1);
E = linspace(E_start, E_end, Nx);

% Initial carrier concentration (Gaussian distribution)
n = exp(-((x - L/2) / (0.1e-6)).^2) * 1e21; % Electrons
p = exp(-((x - L/2) / (0.1e-6)).^2) * 1e21; % Holes

% Animation setup
figure;
for t = 1:Nt
    % Compute drift & diffusion currents
    J_drift_n = q * n .* mu_n .* E;
    J_drift_p = q * p .* mu_p .* E;
    dn_dx = gradient(n, x);
    dp_dx = gradient(p, x);
    J_diff_n = q * D_n * dn_dx;
    J_diff_p = q * D_p * dp_dx;

    % Update carrier concentration
    n = n - dt * gradient(J_drift_n + J_diff_n, x);
    p = p - dt * gradient(J_drift_p + J_diff_p, x);

    % Improved animation with moving carriers
    subplot(2,1,1);
    plot(x * 1e6, n, 'bo-', 'LineWidth', 2, 'MarkerSize', 4); hold on;
    plot(x * 1e6, p, 'ro-', 'LineWidth', 2, 'MarkerSize', 4); hold off;
    xlabel('Position (μm)');
    ylabel('Carrier Concentration (m^{-3})');
    title(sprintf('Carrier Transport - Time Step %d', t));
    legend('Electrons', 'Holes');
    ylim([0 max(n) * 1.2]);
    grid on;

    subplot(2,1,2);
    plot(x * 1e6, J_drift_n, 'b', 'LineWidth', 2); hold on;
    plot(x * 1e6, J_drift_p, 'r', 'LineWidth', 2);
    plot(x * 1e6, J_diff_n, '--b', 'LineWidth', 2);
    plot(x * 1e6, J_diff_p, '--r', 'LineWidth', 2); hold off;
    xlabel('Position (μm)');
    ylabel('Current Density (A/m²)');
    title('Drift & Diffusion Current');
    legend('J_{drift} (e-)', 'J_{drift} (h+)', 'J_{diff} (e-)', 'J_{diff} (h+)');
    grid on;

    pause(0.1); % Slower animation for better visibility
end


