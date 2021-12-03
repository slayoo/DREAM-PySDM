%D Partridge, University of Exeter, Sept 2021

clc
clear all 
close all 

Pars = []

Pars(1,5) = 0.35   %Updraft velocity (ms-1)
Pars(1,9) = 285    %Temperature (K)

Pars(1,1) = 1e+008 %Number mode 1 (m^-3)
Pars(1,6) = 5e+007 %Number mode 2 (m^-3)

Pars(1,2) = 0.0200 %Mean radius mode 1 (microns)
Pars(1,7) = 0.0700 %Mean radius mode 2 (microns)

Pars(1,3) = 1.4000 %GSD mode 1 
Pars(1,8) = 1.4000 %GSD mode 2 

Pars(1,4) = 0.9000 %Soluble volume fraction (soluble component = (nh4)hso4, insoluble = BC)


%Write the parameters to the par.in file
%[dummy] = WriteParFile_Parcel(Pars,Extra);

format='%10.4e'
  
%In first comparison have two modes, internally mixed (same chemistry in
%each). In future tests we should allow chemistry to vary per mode. For
%now, lets keep as is and ensure icpm vs drops similar. 

% Compute effective kappa. 
  
  %In the previous version of Drops it was not
  % possible to initialise the model with volume fractions (as done in icpm
  % parcel model). This was a workaround to initialise a soluble volume
  % fraction [soluble component represented by (nh4)hso4, insoluble component BC ]
  kpa_s = .61;
  d_s = 1.77;
  d_i = 2.10;
  
  %In ICPM the following paramter values are used
  %Mass accomodation coefficient = 1; 
  %Surface tension water = 72.8;
  
  %Write the parameters to a structure (all in SI units)
  dt = .25;                      %Timestep
  input = struct(...
    'n_bins', 250, ...           %Number of bins
    'T',  Pars(1,9), ...         %Initial Temperature (K)
    'RH', .999, ...              %Initial Relative Humidity (%)
    'p',  1.00e+05, ...          %Initial Pressure (Pa)
    'w',  Pars(1,5), ...         %Updraft velocity (m/s)
    'kappa', .5, ... %kpa_s * volfrac(Pars(1,4), d_s, d_i), ...
    'n_tot', [num2str(Pars(1,1),format),        ' ', num2str(Pars(1,6),format)       ], ...  %N mode 1,2
    'meanr', [num2str(Pars(1,2) * 1e-6,format), ' ', num2str(Pars(1,7) * 1e-6,format)], ...  %Mean radius mode 1,2
    'gstdv', [num2str(Pars(1,3),format),        ' ', num2str(Pars(1,8),format)       ], ...  %GSD mode 1,2
    'dt', dt, ... 
    'nt', ceil(1000 / Pars(1,5) / dt) ... % TODO: stop at S_max !                            %Output height. Needs changing so stop at S_max. 
  );  

    
  % Run the forward model 
  %try
    output = drops_py(input);
  %catch
  %end
   
  % Define the return vector for comparison with the measurements
  N_Parcel = [output.N_act, output.S_max]; 
  N_Parcel = N_Parcel(:);
