function flight = initialize(flight)
global plan Perf Weather config
msg='Initialize Flights.....';
Weather.Wind=struct;
for i=1:length(flight)

    [msg flight(i).callsign '.....(' num2str(i) '/' num2str(length(flight)) ')' ]

  
    flight(i).manual.spd = [0;0;0]; % �ӵ� ���� ����(������ ����) - boolean ; ������ �ӵ� - double
    flight(i).manual.alt = [0;0;0]; % �� ���� ����(������ ����), 3rd arg: ROCD limit (ft/min) -> 0: auto, -1: maximum, other: inputed ROCD
    flight(i).manual.hdg = [0;0;0]; % ��� ���� ����(������ ����), 3rd arg: direction (0: auto, 1: one loop clockwise, -2: two loop counter clockwise)
    flight(i).manual.cta = [1;0;0]; % ���� TBO ��� ���߿� (CTA)
    flight(i).manual.exp = [0;0;0]; % expedite ���� -> rot, thrust, ROCD max ��ġ ����
    flight(i).manual.ban = [0;0;0]; % Bankangle
    flight(i).manual.pit = [0;0;0]; % Pitch
    flight(i).manual.crs = [0;0;0]; % Course
    flight(i).label = 1;
    
    if config.EXPTEST
        % ������ӽ��ڵ� -> ��õ���� manual
        if strcmp(plan(i).arrival, 'RKSI')
%             if flight(i).gentime > 100
% %                 flight(i).manual.spd = [1 ; flight(i).Vtas ; 0]; % �ӵ� ���� ����(������ ����) - boolean ; ������ �ӵ� - double
% %                 flight(i).manual.alt = [1 ; flight(i).hdg ; 0]; % �� ���� ����(������ ����), 3rd arg: ROCD limit (ft/min) -> 0: auto, -1: maximum, other: inputed ROCD
% %                 flight(i).manual.hdg = [1 ; flight(i).alt ; 0]; % ��� ���� ����(������ ����), 3rd arg: direction (0: auto, 1: one loop clockwise, -2: two loop counter clockwise)
% %                 flight(i).manual.cta = [0 ; 0 ; 0]; % ���� TBO ��� ���߿� (CTA)
%             end
        else
            
            flight(i).label = 0;
        end
    end
    
%     
%     flight(10).manual.cta(1) = 1;
%     flight(11).manual.cta(1) = 1;
    
%     flight(1).manual.cta(1) = 1;
%     flight(2).manual.cta(1) = 1;
%     flight(3).manual.hdg(1) = 1;
    
    flight(i).Bankangle = 0;
    flight(i).Pitch = 0;
    flight(i).Course = 0;
    flight(i).FixFlap = '';
    flight(i).FixFlapCount = 0;
    
    
    flight(i).ReferenceFrom = 1;
    [flight(i).long, flight(i).lat, flight(i).alt, flight(i).Vtas, flight(i).hdg] = GetNextReference(flight(i), flight(i).ReferenceFrom);

    flight(i).ReferenceTo = 2;
    [flight(i).long_sc, flight(i).lat_sc, flight(i).alt_sc, flight(i).Vtas_sc, flight(i).hdg_sc, flight(i).FS] = GetNextReference(flight(i), flight(i).ReferenceTo);
        
    flight(i).mass = Perf.(flight(i).type).Mass_ref;

    
    flight(i).ROCD = 0;
    flight(i).LongAccel = 0;
    flight(i).VertAccel = 0;
    flight(i).RateOfTurn = 0;
    flight(i).Thrust = 0;
    flight(i).FuelFlow = 0;
    flight(i).FuelConsumption = 0;
   
    flight(i).Lift = 0;
    flight(i).Drag = 0;
    
    
    flight(i).status = 1;
    flight(i).arrived = -1;
    
    flight(i).gentime = plan(flight(i).id).gentime;

    flight(i).delay = 0;
%     flight(1).trajectory=Procedure.
   

    Weather.Wind(i).dir = 0;
    Weather.Wind(i).spd = 0;

end


    flight(1).Vtas=0;
    % RKSI RWY33L_END
    flight(1).lat = 37.456380;
    flight(1).long = 126.464672;
    
%     % KAMIT
    flight(2).Vtas = 500;
    flight(2).lat = 34.253889;
    flight(2).long = 126.771667;

%     % AGAVO
%     flight(3).Vtas = 210;
%     flight(3).lat = 37.169444;
%     flight(3).long = 123.998056;
%     
%     % GUKDO
%     flight(4).Vtas = 300;
%     flight(4).lat = 37.019694;
%     flight(4).long = 127.639611;
%     
%     flight(5).Vtas = 200;
%     flight(5).lat=36.000000;
%     flight(5).long=128.000000;
%     
%     % RKSI RWY16 THR
%     flight(6).Vtas = 0;
%     flight(6).lat=37.472808;
%     flight(6).long=126.415572;
%     
%     % RKSI RWY16 THR
%     flight(7).Vtas = 0;
%     flight(7).lat=37.472808;
%     flight(7).long=126.415572;
%     
%     % RKPC RWY25 THR
%     flight(8).Vtas = 0;
%     flight(8).lat=33.514878;
%     flight(8).long=126.497642;
% 
%     % RKPC RWY25 THR
%     flight(9).Vtas = 0;
%     flight(9).lat=33.514878;
%     flight(9).long=126.497642;
%     
%     
%     %�ϴ� �� ���ư����� ������ ���� �ٲ㼭 �־�ô�
    flight(1).alt = 0;
    flight(2).alt = 40000;
%     flight(3).alt = 13000;
%     flight(4).alt = 7000;
%     flight(5).alt = 11000;
%     flight(6).alt = 0;
%     flight(7).alt = 22.9;
%     flight(8).alt = 0;
%     flight(9).alt = 0;
    
    
%     
    flight(1).FS='TX'; %���� TO �ܰ� ���Խ� ���� ��� (����� �ٷ� cruise ���·� ����)
    flight(2).FS='AP'; %���� TO �ܰ� ���Խ� ���� ��� (����� �ٷ� cruise ���·� ����)
%     flight(3).FS='CR'; %���� TO �ܰ� ���Խ� ���� ��� (����� �ٷ� cruise ���·� ����)
%     flight(4).FS='CR'; %���� TO �ܰ� ���Խ� ���� ��� (����� �ٷ� cruise ���·� ����)
%     flight(5).FS='CR'; %���� TO �ܰ� ���Խ� ���� ��� (����� �ٷ� cruise ���·� ����)
%     flight(6).FS='TX'; %���� TO �ܰ� ���Խ� ���� ��� (����� �ٷ� cruise ���·� ����)
%     flight(7).FS='TX'; %���� TO �ܰ� ���Խ� ���� ��� (����� �ٷ� cruise ���·� ����)
%     flight(8).FS='TX'; %���� TO �ܰ� ���Խ� ���� ��� (����� �ٷ� cruise ���·� ����)
%     flight(9).FS='TX'; %���� TO �ܰ� ���Խ� ���� ��� (����� �ٷ� cruise ���·� ����)
%     
%     for no = 10:13
%         flight(no).Vtas = 0;
%         flight(no).lat=37.472808;
%         flight(no).long=126.415572;
%         flight(no).alt = 22.9;
%         flight(no).FS = 'TX';
%     end
%     
    
end