function galt=geoalt(alt)
global unit atmos config

% 일단 ISA를 가정했기 때문에... 이후 else문 생성후 기상데이터 받는 모듈 병합
% if config.Temp == 0 && config.Pres == 0
[T, a, P, rho] = atmosisa((alt*unit.ft2meter));

galt = atmospalt(P) / unit.ft2meter;
% end
%galt=(1/atmos.beta_Tb)*(((atmos.T_0)-(T))+(atmos.Td*(log(atmos.T_0/T))));

end



