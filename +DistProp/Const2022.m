classdef Const2022
% Physical Constants CODATA 2022
    
    properties (Constant)
        deltavCs =  DistProp.Const2022.data.deltavCs;    % Hyperfine transition frequency of Cs-133 / Hz
        c0 =        DistProp.Const2022.data.c0;          % Speed of light in vacuum / (m/s)
        h =         DistProp.Const2022.data.h;           % Planck constant / Js
        e =         DistProp.Const2022.data.e;           % Elementary charge / C
        k =         DistProp.Const2022.data.k;           % Boltzmann constant / (J/K)
        Na =        DistProp.Const2022.data.Na;          % Avogadro constant / (1/mol)
        Kcd =       DistProp.Const2022.data.Kcd;         % Luminous efficacy / (lm/W)
        Kj =        DistProp.Const2022.data.Kj;          % Josephson constant / (Hz/V)
        Rk =        DistProp.Const2022.data.Rk;          % von Klitzing constant / Ohm
        F =         DistProp.Const2022.data.F;           % Faraday constant / (C/mol)
        R =         DistProp.Const2022.data.R;           % Molar gas constant / (J/(mol*K))
        eV =        DistProp.Const2022.data.eV;          % Electron volt / J
        G =         DistProp.Const2022.data.G;           % Newtonian constant of gravitation / (m^3/(kg*s^2))
        alpha =     DistProp.Const2022.data.alpha;       % Fine-structure constant
        mu0 =       DistProp.Const2022.data.mu0;         % Vacuum magnetic permeability / (Vs/Am)
        ep0 =       DistProp.Const2022.data.ep0;         % Vacuum electric permittivity / (As/Vm)
        Ryd =       DistProp.Const2022.data.Ryd;         % Rydberg constant / (1/m)
        me =        DistProp.Const2022.data.me;          % Electron mass / kg
        are =       DistProp.Const2022.data.are;         % Electron relative atomic mass
        arp =       DistProp.Const2022.data.arp;         % Proton relative atomic mass
        mpsme =     DistProp.Const2022.data.mpsme;       % Proton-electron mass ratio
        mp =        DistProp.Const2022.data.mp;          % Proton mass / kg
        u =         DistProp.Const2022.data.u;           % Atomic mass constant / kg
        Mu =        DistProp.Const2022.data.Mu;          % Molar mass constant / (kg/mol)
    end
    
    properties (Constant, Hidden, Access = private)
        data = loadData(); % Internal field used for loading data - Required to ensure UncPropLoadNETAssemblies('DistProp'); is called
    end
    
end

function data = loadData()
    UncPropLoadNETAssemblies('DistProp');
    
    data = struct();
    
    data = addFields(data, Metas.UncLib.Core.Const2022);
    data = addFields(data, NET.createGeneric('Metas.UncLib.Core.Const2022', {'Metas.UncLib.DistProp.UncNumber'}), @(x) DistProp(x));

end

function s = addFields(s, s2, fH)
% Adds all fields of s2 to s. If defined, the function handle fH is
% applied to each field of s2.
    if nargin < 3
        fH = @(x) x;
    end

    fields = fieldnames(s2);
    for ii = 1:numel(fields)
        s.(fields{ii}) = fH(s2.(fields{ii}));
    end
end
