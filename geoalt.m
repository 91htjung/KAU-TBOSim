function galt=geoalt(alt)
global unit atmos config

% �ϴ� ISA�� �����߱� ������... ���� else�� ������ ������� �޴� ��� ����
% if config.Temp == 0 && config.Pres == 0
[T, a, P, rho] = atmosisa((alt*unit.ft2meter));

galt = atmospalt(P) / unit.ft2meter;
% end
%galt=(1/atmos.beta_Tb)*(((atmos.T_0)-(T))+(atmos.Td*(log(atmos.T_0/T))));

end



