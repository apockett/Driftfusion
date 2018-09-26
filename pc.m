% Class defining the properties and methods for the simulation parameters
classdef pc
    % Parameters Class
    
    properties (Constant)
        
        % Physical constants
        kB = 8.617330350e-5;     % Boltzmann constant [eV K^-1]
        epp0 = 552434;           % Epsilon_0 [e^2 eV^-1 cm^-1] - Checked (02-11-15)
        q = 1;                   % Charge of the species in units of e.
        e = 1.61917e-19;         % Elementary charge in Coulombs.
       
    end
    
    properties
        
        % Temperature [K]
        T = 300;
        
        % Device Dimensions [cm]
        d = [200e-7, 400e-7, 50e-7];       % Layer thickness array
        parr = [100, 200, 20];             % Spatial mesh points array
                         
        dint = 2e-7;        % 0.5x Interfacial region thickness (x_mesh_type = 3), this is related to Space Charge Region, read below for wp and wn parameters
        pint = 20;          % 0.5x Interfacial points (x_mesh_type = 3)
        dscr = 30e-7;       % Approx space charge region thickness
        pscr = 30;          % No of points in space charge region
        pepe = 20;          % electrode interface points
        te = 10e-7;         % electrode interface thickness
        dmin = 1e-7;        % start value for log meshes
        deltax = 1e-7;
        
        % Define spatial cordinate system
        % m=0 cartesian
        % m=1 cylindrical polar coordinates
        % m=2 spherical polar coordinates
        m = 0;
        
        %%%%%%% GENERAL CONTROL PARAMETERS %%%%%%%%%%
        OC = 0;                 % Closed circuit = 0, Open Circuit = 1
        Int = 0;                % Bias Light intensity (Suns Eq.)
        pulseon = 0;            % Switch pulse on TPC or TPV
        Vapp = 0;               % Applied bias
        BC = 3;                 % Boundary Conditions. Must be set to one for first solution
        figson = 1;             % Toggle figures on/off
        meshx_figon = 0;        % Toggles x-mesh figures on/off
        mesht_figon = 0;        % Toggles t-mesh figures on/off
        side = 1;               % illumination side 1 = EE, 2 = SE
        calcJ = 0;              % Calculates Currents- slows down solving calcJ = 1, calculates DD currents at every position
        mobset = 1;             % Switch on/off electron hole mobility- MUST BE SET TO ZERO FOR INITIAL SOLUTION
        mobseti = 1;
        SRHset = 1;
        JV = 0;                 % Toggle run JV scan on/off
        Ana = 1;                % Toggle on/off analysis
        
        % OM = Optical Model
        % Current only uniform generation functionality is avaiable- this will be
        % updated in future versions.
        % 0 = Uniform Generation
        OM = 0;
        
        %%%%%%% MESHES %%%%%%
        % xmesh_type specification - see xmesh_gen
        xmesh_type = 3;
        
        % Parameters for time mesh
        tmax = 1e-12;               % Max time value
        t0 = 1e-16;                 % Initial log mesh time value
        tpoints = 100;              % Number of time points
        tmesh_type = 2;             % Mesh type- for use with meshgen_t
        
        %%%%%%%%%%% MATERIAL PROPERTIES %%%%%%%%%%%%%%%%%%%%
        %% Layer description- currently for optical properties only
        % See Index of Refraction library for choices- names must be exactly the same but '_n', '_k' should be omitted
        stack = {'PEDOT', 'MAPICl', 'PCBM'}
        
        %% Energy levels    
        EA = [-1.9, -3.8, -4.1];
        IP = [-4.9, -5.4, -7.4];
        
        % PCBM: Sigma Aldrich https://www.sigmaaldrich.com/technical-documents/articles/materials-science/organic-electronics/pcbm-n-type-semiconductors.html
        
        %% Equilibrium Fermi energies - defines doping density
        E0 = [-4.8, -4.6, -4.3];
        
        % Workfunction energies
        PhiA = -4.8;
        PhiC = -4.2;
        
        % Effective Density Of States
        N0 = [1e19, 1e19, 1e19];
        % PEDOT eDOS: https://aip.scitation.org/doi/10.1063/1.4824104
        % MAPI eDOS: F. Brivio, K. T. Butler, A. Walsh and M. van Schilfgaarde, Phys. Rev. B, 2014, 89, 155204.
        % PCBM eDOS:
                
        %%%%% MOBILE ION DEFECT DENSITY %%%%%
        Nion = [0, 1e18, 0];                     % [cm-3] A. Walsh, D. O. Scanlon, S. Chen, X. G. Gong and S.-H. Wei, Angewandte Chemie, 2015, 127, 1811.
        DOSion = [0, 1.21e22, 0];                % [cm-3] max density of iodide sites- P. Calado thesis
        
        % Mobilities
        mue = [0.02, 20, 0.09];         % electron mobility [cm2V-1s-1]
        muh = [0.02, 20, 0.09];         % hole mobility [cm2V-1s-1]
        muion = [0, 1e-10, 0];                   % ion mobility [cm2V-1s-1]
        % PTPD h+ mobility: https://pubs.rsc.org/en/content/articlehtml/2014/ra/c4ra05564k
        % PEDOT mue = 0.01 cm2V-1s-1 https://aip.scitation.org/doi/10.1063/1.4824104
        % TiO2 mue = 0.09?Bak2008
        % Spiro muh = 0.02 cm2V-1s-1 Hawash2018
        
        % Dielectric constants
        epp = [4,23,12];
        % TiO2?Wypych2014
        
        %%% Generation %%%%%
        G0 = [0, 2.6409e+21, 0];        % Uniform generation rate @ 1 Sun      
        
        %%%%%%% RECOMBINATION %%%%%%%%%%%
        % Radiative recombination, U = k(np - ni^2)
        krad = [3.18e-11, 3.6e-12, 1.54e-10];  % [cm3 s-1] Radiative Recombination coefficient
        % p-type/pi-interface/intrinsic/in-interface/n-type
                
        % SRH trap energies- currently set to mid gap - always set
        % respective to energy levels to avoid conflicts
        % U = (np-ni^2)/(taun(p+pt) +taup(n+nt))           
        Et_bulk =[-0.5, -0.5, -0.5];
        Et_inter = [-0.7, -0.8];
        
        % Bulk SRH time constants for each layer
        taun_bulk = [1e6, 1e-6, 1e6];           % [s] SRH time constant for electrons
        taup_bulk = [1e6, 1e-6, 1e6];           % [s] SRH time constant for holes
        
        % Interfacial SRH time constants - should be of length (number of layers)-1
        taun_inter = [1e-12, 1e-9];
        taup_inter = [1e-12, 1e-9];
                
        % Surface recombination and extraction coefficients
        sn_r = 1e8;            % [cm s-1] electron surface recombination velocity (rate constant for recombination at interface)
        sn_l = 1e8;
        sp_r = 1e8;             % [cm s-1] hole surface recombination velocity (rate constant for recombination at interface)
        sp_l = 1e8;
        
        % Defect recombination rate coefficient - not currently used
        k_defect_p = 0;
        k_defect_n = 0;
        
        %% Pulse settings
        laserlambda = 638;      % Pulse wavelength (Currently implemented with OM2 (Transfer Matrix only)
        pulselen = 1e-6;        % Transient pulse length
        pulsepow = 10;          % Pulse power [mW cm-2] OM2 (Transfer Matrix only)
        pulsestart = 1e-7;
        
        %% Current voltage scan parameters
        Vstart = 0;             % Initial scan point
        Vend = 1.2;             % Final scan point
        JVscan_rate = 1;        % JV scan rate (Vs-1)
        JVscan_pnts = 100;
        
        %% Dynamically created variables
        genspace = [];
        x = [];
        t = [];
        xpoints = [];
        
        % Define the default relative tolerance for the pdepe solver
        % 1e-3 is the default, can be decreased if more precision is needed
        % Solver options
        RelTol = 1e-3;
        AbsTol = 1e-6;
        
        dev;
        xx;
                
    end
    
    
    %%  Properties whose values depend on other properties (see 'get' methods).
    properties (Dependent)
        
        dcum
        dEAdx
        dIPdx
        dN0dx
        Eg
        Eif
        NA
        ND
        Vbi
        n0
        nleft
        nright
        ni
        nt_bulk          % Density of CB electrons when Fermi level at trap state energy
        nt_inter
        p0
        pleft
        pright
        pt_bulk           % Density of VB holes when Fermi level at trap state energy
        pt_inter
        wn
        wp
        wscr            % Space charge region width
        x0              % Initial spatial mesh value
        
    end
    
    methods
        
        function par = pc
            % paramsStruct Constructor for paramsStruct.
            %
            % Warn if tmesh_type is not correct
            
            par.dev  = pc.builddev(par);
            par.xx = pc.xmeshini(par);
            
            if ~ any([1 2 3 4] == par.tmesh_type)
                warning('PARAMS.tmesh_type should be an integer from 1 to 4 inclusive. MESHGEN_T cannot generate a mesh if this is not the case.')
            end
            
            % Warn if xmesh_type is not correct
            if ~ any(1:1:10 == par.xmesh_type)
                warning('PARAMS.xmesh_type should be an integer from 1 to 9 inclusive. MESHGEN_X cannot generate a mesh if this is not the case.')
            end
            
            for i = 1:length(par.ND)
                if par.ND(i) >= par.N0(i) || par.NA(i) >= par.N0(i)
                    msg = 'Doping density must be less than eDOS. For consistent values ensure electrode workfunctions are within the band gap and check expressions for doping density in Dependent variables.';
                    error(msg);
                end
            end
            
            % warn if trap energies are outside of band gpa energies
            for i = 1:length(par.Et_bulk)
                if par.Et_bulk(i) >= par.EA(2) || par.Et_bulk(i) <= par.IP(2)
                    msg = 'Trap energies must exist within layer 2 band gap.';
                    error(msg);
                end
            end
            
        end
        
        function params = set.xmesh_type(params, value)
            % SET.xmesh_type Check if xmesh_type is an integer from 1 to 4.
            %
            %   SET.xmesh_type(PARAMS, VALUE) checks if VALUE is an integer
            %   from 1 to 4, and if so, changes PARAMS.xmesh_type to VALUE.
            %   Otherwise, a warning is shown. Runs automatically whenever
            %   xmesh_type is changed.
            if any(1:1:9 == value)
                par.xmesh_type = value;
            else
                error('PARAMS.xmesh_type should be an integer from 1 to 9 inclusive. MESHGEN_X cannot generate a mesh if this is not the case.')
            end
        end
        
        function params = set.tmesh_type(params, value)
            % SET.tmesh_type Check if xmesh_type is an integer from 1 to 2.
            %
            %   SET.tmesh_type(PARAMS, VALUE) checks if VALUE is an integer
            %   from 1 to 2, and if so, changes PARAMS.tmesh_type to VALUE.
            %   Otherwise, a warning is shown. Runs automatically whenever
            %   tmesh_type is changed.
            if any([1 2 3 4] == value)
                par.tmesh_type = value;
            else
                error('PARAMS.tmesh_type should be an integer from 1 to 4 inclusive. MESHGEN_T cannot generate a mesh if this is not the case.')
            end
        end
        
        function params = set.ND(params, value)
            for i = 1:length(par.ND)
                if value(i) >= par.N0(i)
                    error('Doping density must be less than eDOS. For consistent values ensure electrode workfunctions are within the band gap.')
                end
            end
        end
        
        function params = set.NA(params, value)
            for i = 1:length(par.ND)
                if value(i) >= par.N0(i)
                    error('Doping density must be less than eDOS. For consistent values ensure electrode workfunctions are within the band gap.')
                end
            end
        end
                               
        % Cumulative thickness
        function value = get.dcum(par)
                value = cumsum(par.d);                % cumulative thickness     
        end
        
        % Band gap energies
        function value = get.Eg(par)
            
            value = par.EA - par.IP;
            
        end
        
        % Vbi based on difference in boundary workfunctions
        function value = get.Vbi(par)
            
            value = par.PhiC - par.PhiA;
            
        end
                
        % Intrinsic Fermi Energies (Botzmann)
        function value = get.Eif(par)
            
            value = [0.5*((par.EA(1)+par.IP(1))+par.kB*par.T*log(par.N0(1)/par.N0(1))),...
                0.5*((par.EA(2)+par.IP(2))+par.kB*par.T*log(par.N0(2)/par.N0(2))),...
                0.5*((par.EA(3)+par.IP(3))+par.kB*par.T*log(par.N0(3)/par.N0(3)))];
            
        end
        
        % Conduction band gradients at interfaces
        function value = get.dEAdx(par)
            
            value = [(par.EA(2)-par.EA(1))/(2*par.dint), (par.EA(3)-par.EA(2))/(2*par.dint)];
         
        end
                
        %Valence band gradients at interfaces
        function value = get.dIPdx(par)
            
            value = [(par.IP(2)-par.IP(1))/(2*par.dint), (par.IP(3)-par.IP(2))/(2*par.dint)];
         
        end
        
        % eDOS gradients at interfaces 
        function value = get.dN0dx(par)
            
            value = [(par.N0(2)-par.N0(1))/(2*par.dint), (par.N0(3)-par.N0(2))/(2*par.dint)];
         
        end

        % Donor densities
        function value = get.ND(par)
            
            value = [0, 0, F.fdn(par.N0(3), par.EA(3), par.E0(3), par.T)];

        end
        % Donor densities
        function value = get.NA(par)
            
            value = [F.fdp(par.N0(1), par.IP(1), par.E0(1), par.T), 0, 0];
            
        end
        
        % Intrinsic carrier densities - Boltzmann for now
        function value = get.ni(par)
            
            value = [par.N0(1)*(exp(-par.Eg(1)/(2*par.kB*par.T))),...
                par.N0(2)*(exp(-par.Eg(2)/(2*par.kB*par.T))),...
                par.N0(3)*(exp(-par.Eg(3)/(2*par.kB*par.T)))];
            
        end
        % Equilibrium electron densities
        function value = get.n0(par)
            
            value = [F.fdn(par.N0(1), par.EA(1), par.E0(1), par.T),...
                F.fdn(par.N0(2), par.EA(2), par.E0(2), par.T),...
                F.fdn(par.N0(3), par.EA(3), par.E0(3), par.T)];           
        end
                     
        function value = get.p0(par)
            
            value = [F.fdp(par.N0(1), par.IP(1), par.E0(1), par.T),...
                F.fdp(par.N0(2), par.IP(2), par.E0(2), par.T),...
                F.fdp(par.N0(3), par.IP(3), par.E0(3), par.T)];          % Background density holes in htl/p-type
            
        end
                
        % Boundary electron and hole densities - based on the workfunction
        % of the electrodes
        function value = get.nleft(par)
            
            value = F.fdn(par.N0(1), par.EA(1), par.PhiA, par.T);
        
        end
        
                % Boundary electron and hole densities
        function value = get.nright(par)
            
            value = F.fdn(par.N0(end), par.EA(end), par.PhiC, par.T);
        
        end
        
                % Boundary electron and hole densities
        function value = get.pleft(par)
            
            value = F.fdp(par.N0(1), par.IP(1), par.PhiA, par.T);
        
        end
        
        function value = get.pright(par)
            
            value = F.fdp(par.N0(end), par.IP(end), par.PhiC, par.T);
        
        end
                       
        %% Space charge layer widths
        function value = get.wp (par)
            
            value = ((-par.d(2)*par.NA(1)*par.q) + ((par.NA(1)^0.5)*(par.q^0.5)*(((par.d(2)^2)*par.NA(1)*par.q) + (4*par.epp(2)*par.Vbi))^0.5))/(2*par.NA(1)*par.q);
            
        end
        
        function value = get.wn (par)
            
            value = ((-par.d(2)*par.ND(3)*par.q) + ((par.ND(3)^0.5)*(par.q^0.5)*(((par.d(2)^2)*par.ND(3)*par.q) + (4*par.epp(2)*par.Vbi))^0.5))/(2*par.ND(3)*par.q);
            
        end
        
        % wscr - space charge region width
        function value = get.wscr(par)
            
            value = par.wp + par.d(2) + par.wn;         % cm
            
        end
        
        %%
        
    end
    
    methods (Static)
        
        function xx = xmeshini(par)
            
            xx = meshgen_x(par);
            
        end
        
        % EA array
        function dev = builddev(par)
            % This function builds the properties for the device as
            % concatenated arrays such that each property can be called for
            % each point including grading at interfaces. For future
            % versions a choice of functions defining how the properties change
            % at the interfaces is intended. For the time being the
            % properties simply change linearly.
            xx = pc.xmeshini(par);
            
            dev.EA = zeros(1, length(xx));
            dev.IP = zeros(1, length(xx)); 
            dev.mue = zeros(1, length(xx));
            dev.muh = zeros(1, length(xx));
            dev.muion = zeros(1, length(xx));
            dev.NA = zeros(1, length(xx));
            dev.ND = zeros(1, length(xx));
            dev.N0 = zeros(1, length(xx));
            dev.Nion = zeros(1, length(xx));
            dev.ni = zeros(1, length(xx));
            dev.n0 = zeros(1, length(xx));
            dev.p0 = zeros(1, length(xx));
            dev.DOSion = zeros(1, length(xx));
            dev.epp = zeros(1, length(xx));
            dev.krad = zeros(1, length(xx));
            dev.gradEA = zeros(1, length(xx));
            dev.gradIP = zeros(1, length(xx));
            dev.gradN0 = zeros(1, length(xx));
            dev.E0 = zeros(1, length(xx));
            dev.G0 = zeros(1, length(xx));
            dev.taun = zeros(1, length(xx));
            dev.taup = zeros(1, length(xx));
            dev.Et = zeros(1, length(xx));
            dev.nt = zeros(1, length(xx));
            dev.pt = zeros(1, length(xx));
            
            dcum0 = [0,par.dcum];
          for i =1:length(par.dcum)
                    if i == 1
                        aa = 0;
                    else
                        aa = 1;
                    end
                    
                    if i == length(par.dcum)
                        bb = 0;
                    else
                        bb = 1;
                    end
                    
                    for j = 1:length(xx)                     
                        if xx(j) >= dcum0(i) + aa*par.dint && xx(j) <= dcum0(i+1) - bb*par.dint                         
                            dev.EA(j) = par.EA(i); 
                            dev.IP(j) = par.IP(i);
                            dev.mue(j) = par.mue(i);
                            dev.muh(j) = par.muh(i);
                            dev.muion(j) = par.muion(i);
                            dev.N0(j) = par.N0(i);
                            dev.NA(j) = par.NA(i);
                            dev.ND(j) = par.ND(i);
                            dev.epp(j) = par.epp(i);
                            dev.ni(j) = par.ni(i);
                            dev.Nion(j) = par.Nion(i);
                            dev.DOSion(j) = par.DOSion(i);
                            dev.krad(j) = par.krad(i);
                            dev.n0(j) = par.n0(i);
                            dev.p0(j) = par.p0(i);
                            dev.E0(j) = par.E0(i);
                            dev.G0(j) = par.G0(i);
                            dev.gradEA(j) = 0;
                            dev.gradIP(j) = 0;
                            dev.gradN0(j) = 0;
                            dev.taun(j) = par.taun_bulk(i);
                            dev.taup(j) = par.taup_bulk(i);
                            dev.Et(j) = par.Et_bulk(i);
                           
                            
                        elseif xx(j) > dcum0(i+1) - bb*par.dint && xx(j) < dcum0(i+2) + bb*par.dint             
                            xprime = xx(j)-(dcum0(i+1) - bb*par.dint);
                            
                            dEAdxprime = (par.EA(i+1)-par.EA(i))/(2*par.dint);
                            dev.EA(j) = par.EA(i) + xprime*dEAdxprime;
                            dev.gradEA(j) = dEAdxprime;
                            
                            dIPdxprime = (par.IP(i+1)-par.IP(i))/(2*par.dint);
                            dev.IP(j) = par.IP(i) + xprime*dIPdxprime;
                            dev.gradIP(j) = dIPdxprime;
                                                        
                            % Mobilities
                            dmuedx = (par.mue(i+1)-par.mue(i))/(2*par.dint);
                            dev.mue(j) = par.mue(i) + xprime*dmuedx;
                            
                            dmuhdx = (par.muh(i+1)-par.muh(i))/(2*par.dint);
                            dev.muh(j) = par.muh(i) + xprime*dmuhdx;                           
                            
                            dmuiondx = (par.muion(i+1)-par.muion(i))/(2*par.dint);
                            dev.muion(j) = par.muion(i) + xprime*dmuiondx;
                            
                            dmuhdx = (par.muh(i+1)-par.muh(i))/(2*par.dint);
                            dev.muh(j) = par.muh(i) + xprime*dmuhdx;                                
                            
                            % effective density of states
                            dN0dx = (par.N0(i+1)-par.N0(i))/(2*par.dint);
                            dev.N0(j) = par.N0(i) + xprime*dN0dx;  
                            dev.gradN0(j) = dN0dx;
                            
                            % Doping densities
                            dNAdx = (par.NA(i+1)-par.NA(i))/(2*par.dint);
                            dev.NA(j) = par.NA(i) + xprime*dNAdx;   
                            
                            dNDdx = (par.ND(i+1)-par.ND(i))/(2*par.dint);
                            dev.ND(j) = par.ND(i) + xprime*dNDdx;
                            
                            % Dielectric constants
                            deppdx = (par.epp(i+1)-par.epp(i))/(2*par.dint);
                            dev.epp(j) = par.epp(i) + xprime*deppdx;
                            
                            % Intrinsic carrier densities
                            dnidx = (par.ni(i+1)-par.ni(i))/(2*par.dint);
                            dev.ni(j) = par.ni(i) + xprime*dnidx;
                            
                            % Equilibrium carrier densities
                            dn0dx = (par.n0(i+1)-par.n0(i))/(2*par.dint);
                            dev.n0(j) = par.n0(i) + xprime*dn0dx;
                                                                                    
                            % Equilibrium carrier densities
                            dp0dx = (par.p0(i+1)-par.p0(i))/(2*par.dint);
                            dev.p0(j) = par.p0(i) + xprime*dp0dx;
                            
                            % Equilibrium Fermi energy
                            dE0dx = (par.E0(i+1)-par.E0(i))/(2*par.dint);
                            dev.E0(j) = par.E0(i) + xprime*dE0dx;
                            
                            % Uniform generation rate
                            dG0dx = (par.G0(i+1)-par.G0(i))/(2*par.dint);
                            dev.G0(j) = par.G0(i) + xprime*dG0dx;
                            
                            % Static ion background density
                            dNiondx = (par.Nion(i+1)-par.Nion(i))/(2*par.dint);
                            dev.Nion(j) = par.Nion(i) + xprime*dNiondx;
                            
                            % Ion density of states
                            dDOSiondx = (par.DOSion(i+1)-par.DOSion(i))/(2*par.dint);
                            dev.DOSion(j) = par.DOSion(i) + xprime*dDOSiondx;
                            
                            %recombination
                            dkraddx = (par.krad(i+1)-par.krad(i))/(2*par.dint);
                            dev.krad(j) = par.krad(i) + xprime*dkraddx;
                            
                            dev.taun(j) = par.taun_inter(i);
                            dev.taup(j) = par.taup_inter(i);
                            dev.Et(j) = par.Et_inter(i);
                                                        
                        end  
                    end                                   
                    
          end
                
          dev.nt = F.fdn(dev.N0, dev.EA, dev.Et, par.T);
          dev.pt = F.fdp(dev.N0, dev.IP, dev.Et, par.T);
          
                % calculate the gradients
                %dev.gradEA = gradient(dev.EA, xx);
                %dev.gradIP = gradient(dev.IP, xx);
                %dev.gradN0 = gradient(dev.N0, xx);
        end
        
    end
end
