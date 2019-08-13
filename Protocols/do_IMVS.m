function sol_IMVS = do_IMVS(sol_ini, int_base, int_delta, frequency, tmax, tpoints)
% Switches to open circuit at INT_BASE, runs to stabilised OC then performs IMVS measurement at the
% specified FREQUENCY
% INT_BASE = constant (DC) bias component [mulitples of GX]
% INT_DELTA = variable (AC) bias component [mulitples of GX]
disp(['Starting IMVS, base intensity', num2str(in_base), 'delta intensity', num2str(int_delta), 'at frequency' num2str(frequency)']);
par = sol_ini.par;

%sol_ill = lighton_Rs(sol_ini, int1, stable_time, mobseti, Rs, pnts)
sol_ill = lighton_Rs(sol_ini, int_base, -1, 0, 1e6, 100);
par = sol_ill.par;

% Setup time mesh
par.tmesh_type = 1;
par.tmax = tmax;
par.t0 = 0;

% Setup square wave function generator
par.g1_fun_type = 'sin';
par.tpoints = tpoints;
par.gen_arg1(1) = int_base;      % Lower intensity
par.gen_arg1(2) = int_delta;     % Higher intensity
par.gen_arg1(3) = frequency;    % Frequency [Hz]

disp('Applying oscillating optical bias')
sol_IMVS = df(sol_ill, par);

disp('IMVS complete')

end

