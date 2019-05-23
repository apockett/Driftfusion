function [n_coeff, i_coeff, U_coeff, dQ_coeff, n_noionic_coeff] = ISwave_single_analysis(asymstruct_ISwave, minimal_mode, demodulation)
%ISWAVE_SINGLE_ANALYSIS - Calculate impedance (reactance and resistance) and phase by Impedance Spectroscopy (ISwave) with oscillating voltage
%
% Syntax:  ISwave_single_analysis(asymstruct_ISwave, minimal_mode, demodulation)
%
% Inputs:
%   ASYMSTRUCT_ISWAVE - a struct with a solution being perturbed by an
%     oscillating voltage, as generated from ISwave_EA_single_exec
%   MINIMAL_MODE - logical, when true graphics does not get created and
%     ISwave_subtracting_analysis does not get launched, useful when
%     launched under parallelization
%   DEMODULATION - logical, get phase via demodulation instead of using a fitting
%
% Outputs:
%   n_coeff - array of background current, half peak to peak amplitude of
%     oscillation and phase of total electronic current
%   i_coeff - array of background current, half peak to peak amplitude of
%     oscillation and phase of ionic displacement current
%   U_coeff - array of background current, half peak to peak amplitude of
%     oscillation and phase of recombinating charge per unit time
%   dQ_coeff - array of background current, half peak to peak amplitude of
%     oscillation and phase of accumulating current, this is the real
%     capacitive current, obtained comparing the free charges profiles at
%     different times
%   n_noionic_coeff - array of background current, half peak to peak amplitude of
%     oscillation and phase of non ionic current as obtained via
%     subtraction of ionic current from total electronic current
%  
% Example:
%   ISwave_single_analysis(ssol_i_1S_SR_is_100mHz_2mV, false, true)
%     plot current profile, reference profiles and calculate the phase using demodulation approach
%
% Other m-files required: ISwave_subtracting_analysis,
%   ISwave_EA_single_fit, ISwave_EA_single_demodulation, pinana
% Subfunctions: none
% MAT-files required: none
%
% See also ISwave_full_exec, ISwave_EA_single_exec, ISwave_subtracting_analysis, ISwave_EA_single_demodulation, ISwave_EA_single_fit.

% Author: Ilario Gelmetti, Ph.D. student, perovskite photovoltaics
% Institute of Chemical Research of Catalonia (ICIQ)
% Research Group Prof. Emilio Palomares
% email address: iochesonome@gmail.com
% Supervised by: Dr. Phil Calado, Dr. Piers Barnes, Prof. Jenny Nelson
% Imperial College London
% October 2017; Last revision: January 2018

%------------- BEGIN CODE --------------

% increase graphics font size
set(0, 'defaultAxesFontSize', 24);
% set image dimension
set(0, 'defaultfigureposition', [0, 0, 1000, 750]);
% set line thickness
set(0, 'defaultLineLineWidth', 2);

% shortcut
s = asymstruct_ISwave;

% verify if the simulation broke, in that case return just NaNs
if size(asymstruct_ISwave.sol, 1) < asymstruct_ISwave.p.tpoints
    n_coeff = [NaN, NaN, NaN];
    i_coeff = [NaN, NaN, NaN];
    U_coeff = [NaN, NaN, NaN];
    dQ_coeff = [NaN, NaN, NaN];
    n_noionic_coeff = [NaN, NaN, NaN];
    return;
end

%% get current profiles

% s.p.Vapp_params(4) is pulsatance
% round _should_ not be needed here
periods = round(s.p.tmax * s.p.Vapp_params(4) / (2 * pi));

% here is critical that exactely an entire number of periods is provided to
% ISwave_single_demodulation
fit_t_index = round((s.p.tpoints - 1) * floor(periods / 2) / periods) + 1;
fit_t = s.t(fit_t_index:end)';

% current profile to be analyzed
fit_J = s.Jn(fit_t_index:end) / 1000; % in Ampere

% recombination current profile to be analyzed
[~, ~, U] = pinana(s);
fit_U = U(fit_t_index:end) / 1000; % in Ampere

% accumulating current profile to be analyzed
[dQ_t, ~] = ISwave_subtracting_analysis(asymstruct_ISwave);
fit_dQ = dQ_t(fit_t_index:end); % in Ampere

%% remove some tilting from fit_J

% to get better fit and better demodulation in case of
% unstabilized solutions (not usually the case). In case of noisy solutions this could work badly
% but should not affect too much the fitting/demodulation
delta_t = fit_t(end) - fit_t(1);
% this assumes that the first and last point are at the same point in the oscillating voltage
delta_J = fit_J(end) - fit_J(1);
tilting = delta_J/delta_t;
t_middle = fit_t(round(end/2));
% because of this, the bias value that will be obtained from the fit/demodulation is not going to be correct
fit_J_flat = fit_J - tilting * (fit_t - t_middle);

%% extract parameters from current profiles

if demodulation
    n_coeff = ISwave_EA_single_demodulation(fit_t, fit_J_flat, s.p.Vapp_func, s.p.Vapp_params);
    U_coeff = ISwave_EA_single_demodulation(fit_t, fit_U, s.p.Vapp_func, s.p.Vapp_params);
    dQ_coeff = ISwave_EA_single_demodulation(fit_t, -fit_dQ', s.p.Vapp_func, s.p.Vapp_params);
else
    n_coeff = ISwave_EA_single_fit(fit_t, fit_J_flat, s.p.J_E_func);
    U_coeff = ISwave_EA_single_fit(fit_t, fit_U, s.p.J_E_func);
    dQ_coeff = ISwave_EA_single_fit(fit_t, -fit_dQ, s.p.J_E_func);
end

%% calculate ionic contribution

if s.p.mui % if there was ion mobility, current due to ions have been calculated, fit it
    % Intrinsic points logical array
    itype_points= (s.x >= s.p.tp & s.x <= s.p.tp + s.p.ti);
    % subtract background ion concentration, for having less noise in trapz
    i_matrix = s.sol(:, :, 3) - s.p.NI;
    % calculate electric field due to ions
    Efield_i = s.p.e * cumtrapz(s.x, i_matrix, 2) / s.p.eppi;
    % an average would be enough if the spatial mesh was homogeneous in the
    % intrinsic, indeed I have to use trapz for considering the spatial mesh
    Efield_i_mean = trapz(s.x(itype_points), Efield_i(:, itype_points), 2) / s.p.ti;
    % calculate displacement current due to ions
    Ji_disp = -s.p.eppi * gradient(Efield_i_mean, s.t); % in Amperes

    fit_Ji = Ji_disp(fit_t_index:end); % in Ampere
    
    % remove some tilting from fit_Ji to get better fit and better demodulation in case of
    % unstabilized solutions
    % this assumes that the first and last point are at the same point in the oscillating voltage
    delta_Ji = fit_Ji(end) - fit_Ji(1);
    tilting_i = delta_Ji/delta_t;
    % because of this, the bias value that will be obtained from the fit/demodulation is not going to be correct
    % here the fit_Ji has to be provided as a row
    fit_Ji_flat = fit_Ji - tilting_i * (fit_t - t_middle);

    if demodulation
        i_coeff = ISwave_EA_single_demodulation(fit_t, fit_Ji_flat, s.p.Vapp_func, s.p.Vapp_params);
    else
        i_coeff = ISwave_EA_single_fit(fit_t, fit_Ji_flat, s.p.J_E_func);
    end
    
    % calculate electronic current subtracting ionic contribution
    Jn_noionic = s.Jn/1000 - Ji_disp; % in Ampere

else % if no ionic mobility is present, report NaNs
    i_coeff = [NaN, NaN, NaN];
    Ji_disp = NaN;
    Jn_noionic = NaN;
end

%% plot solutions

if ~minimal_mode % disable all this stuff if under parallelization or if explicitly asked to not plot any graphics

    % in phase electronic current
    Jn_inphase = s.p.J_E_func([n_coeff(1)*abs(cos(n_coeff(3))), n_coeff(2)*cos(n_coeff(3)), 0], s.t);
    % out of phase electronic current
    Jn_quadrature = s.p.J_E_func([n_coeff(1)*abs(sin(n_coeff(3))), n_coeff(2)*sin(n_coeff(3)), pi/2], s.t);

    if s.p.mui
        fit_Jn_noionic = Jn_noionic(fit_t_index:end);
        if demodulation
            n_noionic_coeff = ISwave_EA_single_demodulation(fit_t, fit_Jn_noionic, s.p.Vapp_func, s.p.Vapp_params);
        else
            n_noionic_coeff = ISwave_EA_single_fit(fit_t, fit_Jn_noionic, s.p.J_E_func);
        end

        % in phase electronic current
        Jn_noionic_inphase =  s.p.J_E_func([n_noionic_coeff(1)*abs(cos(n_noionic_coeff(3))), n_noionic_coeff(2)*cos(n_noionic_coeff(3)), 0], s.t);
        % out of phase electronic current
        Jn_noionic_quadrature = s.p.J_E_func([n_noionic_coeff(1)*abs(sin(n_noionic_coeff(3))), n_noionic_coeff(2)*sin(n_noionic_coeff(3)), pi/2], s.t);

    else
        Jn_noionic_inphase = NaN;
        Jn_noionic_quadrature = NaN;
        n_noionic_coeff = [NaN, NaN, NaN];
    end

    Vapp = s.p.Vapp_func(s.p.Vapp_params, s.t);
    U_mean = mean(fit_U*1000); % mA

    % fourth value of Vapp_params is pulsatance
    figure('Name', ['Single ISwave, Int ' num2str(s.p.Int) ' Freq '...
        num2str(s.p.Vapp_params(4) / (2 * pi))], 'NumberTitle', 'off');
        yyaxis right
        hold off
        i=1;
        h(i) = plot(s.t, Vapp, 'r', 'LineWidth', 2);
        legend_array = "Applied Voltage";
        ylabel('Applied voltage [V]');

        yyaxis left
        hold off
        i=i+1; h(i) = plot(s.t, s.Jn, 'k-', 'LineWidth', 2); % mA
        legend_array = [legend_array, "Current"];
        hold on
        i=i+1; h(i) = plot(s.t, U - U_mean, 'k--'); % mA
        legend_array = [legend_array, strcat("Recombination current ", num2str(-U_mean, '%+.4g'), " mA/cm2")];
        i=i+1; h(i) = plot(s.t, -dQ_t * 1000, 'b:', 'LineWidth', 2); % mA
        legend_array = [legend_array, "Accumulating current"];
        fitted_Jn = s.p.J_E_func_tilted(n_coeff, fit_t, tilting, t_middle); % A
        i=i+1; h(i) = plot(fit_t, fitted_Jn * 1000, 'kx-'); % mA
        legend_array = [legend_array, "Fit of Current"];
        i=i+1; h(i) = plot(s.t, Jn_inphase*1000, 'm-', 'LineWidth', 1, 'Marker', 'o', 'MarkerSize', 7); % mA
        legend_array = [legend_array, "In phase J"];
        i=i+1; h(i) = plot(s.t, Jn_quadrature*1000, 'm-', 'LineWidth', 1, 'Marker', 'x', 'MarkerSize', 7); % mA
        legend_array = [legend_array, "Out of phase J"];
        if s.p.mui % if there was ion mobility, current due to ions have been calculated, plot stuff
            i_normalization_factor = 10^round(log10(max(fitted_Jn)/max(Ji_disp)));
            i=i+1; h(i) = plot(s.t, Ji_disp * 1000 * i_normalization_factor, 'g--', 'LineWidth', 2); % mA
            legend_array = [legend_array, strcat("Ionic displacement current x ", num2str(i_normalization_factor))];
            i=i+1; h(i) = plot(s.t, Jn_noionic * 1000, 'c-.', 'LineWidth', 2); % mA
            legend_array = [legend_array, "Non-ionic electronic current"];
            i=i+1; h(i) = plot(s.t, Jn_noionic_inphase*1000, 'm--', 'LineWidth', 1, 'Marker', '+', 'MarkerSize', 7); % mA
            legend_array = [legend_array, "In phase electronic J"];
            i=i+1; h(i) = plot(s.t, Jn_noionic_quadrature*1000, 'm--', 'LineWidth', 1, 'Marker', 's', 'MarkerSize', 7); % mA
            legend_array = [legend_array, "Out of phase electronic J"];
        end
        ylabel('Current [mA/cm^2]');
        hold off
        xlabel('Time [s]');
        legend(h, legend_array);
        hold off
else
    n_noionic_coeff = [NaN, NaN, NaN];
end

%------------- END OF CODE --------------
