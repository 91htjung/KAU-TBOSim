function Vtas=cas2tas(cas, alt)
global unit atmos
[T, a, p, rho] = atmosisa((alt*unit.ft2meter));

Vtas=(((2/atmos.kmu)*(p/rho))*(((1+(atmos.p_0/p)*(((1+((atmos.kmu/2)*(atmos.rho_0/atmos.p_0)*((cas)^2)))^(1/atmos.kmu))-1))^atmos.kmu)-1))^0.5;
end



