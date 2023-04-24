function flight = GenerateAC(plan, flight)
global Perf

%Initial Values (강제 입력 상황) 추후 소프트 코딩으로 전환
% Flight plan에 따라 FS를 배정하는 설명은 메뉴얼 pp.19
for i=1:length(plan)
    flight(i).id = plan(i).id;
    flight(i).callsign=plan(i).callsign;
    flight(i).type=plan(i).type;
    flight(i).squawk=4252+i;
    flight(i).hdg=120;
    
    flight(i).Data = 1;
    
    flight(1).Vtas=0;
    % RKSI RWY33L_END
    flight(1).lat = 37.456380;
    flight(1).long = 126.464672;
    
    % KAMIT
    flight(2).Vtas = 500;
    flight(2).lat = 34.253889;
    flight(2).long = 126.771667;
% 
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
    
    
    %일단 잘 돌아가는지 보고자 고도를 바꿔서 넣어봤다
    flight(1).alt = 0;
    flight(2).alt = 40000;
%     flight(3).alt = 13000;
%     flight(4).alt = 7000;
%     flight(5).alt = 11000;
%     flight(6).alt = 0;
%     flight(7).alt = 22.9;
%     flight(8).alt = 0;
%     flight(9).alt = 0;
    
    flight(1).FS='TX'; %추후 TO 단계 포함시 삭제 요망 (현재는 바로 cruise 상태로 가정)
    flight(2).FS='AP'; %추후 TO 단계 포함시 삭제 요망 (현재는 바로 cruise 상태로 가정)
%     flight(3).FS='CR'; %추후 TO 단계 포함시 삭제 요망 (현재는 바로 cruise 상태로 가정)
%     flight(4).FS='CR'; %추후 TO 단계 포함시 삭제 요망 (현재는 바로 cruise 상태로 가정)
%     flight(5).FS='CR'; %추후 TO 단계 포함시 삭제 요망 (현재는 바로 cruise 상태로 가정)
%     flight(6).FS='TX'; %추후 TO 단계 포함시 삭제 요망 (현재는 바로 cruise 상태로 가정)
%     flight(7).FS='TX'; %추후 TO 단계 포함시 삭제 요망 (현재는 바로 cruise 상태로 가정)
%     flight(8).FS='TX'; %추후 TO 단계 포함시 삭제 요망 (현재는 바로 cruise 상태로 가정)
%     flight(9).FS='TX'; %추후 TO 단계 포함시 삭제 요망 (현재는 바로 cruise 상태로 가정)
%     
%     
%     for no = 10:13
%         flight(no).Vtas = 0;
%         flight(no).lat=37.472808;
%         flight(no).long=126.415572;
%         flight(no).alt = 22.9;
%         flight(no).FS = 'TX';
%     end
    
    
    
    flight(i).WaypointFrom = 1;
    flight(i).WaypointTo = 2;
    
    switch plan(i).mass
        case 'reference'
            flight(i).mass = Perf.(flight(i).type).Mass_ref; %일단 reference 질량으로 하자
        case 'maximum'
            flight(i).mass = Perf.(flight(i).type).Mass_max;
        case 'minimum'
            flight(i).mass = Perf.(flight(i).type).Mass_min;
        otherwise
            if isnan(str2double(plan(i).mass))
                switch plan(i).mass(isstrprop(plan(i).mass, 'alpha'))
                    case 'reference'
                        flight(i).mass = str2double(strrep(plan(i).mass, plan(i).mass(isstrprop(plan(i).mass, 'alpha')), '')) * Perf.(flight(i).type).Mass_ref;
                    case 'maximum'
                        flight(i).mass = str2double(strrep(plan(i).mass, plan(i).mass(isstrprop(plan(i).mass, 'alpha')), '')) * Perf.(flight(i).type).Mass_max;
                    case 'minimum'
                        flight(i).mass = str2double(strrep(plan(i).mass, plan(i).mass(isstrprop(plan(i).mass, 'alpha')), '')) * Perf.(flight(i).type).Mass_min;
                    otherwise
                        ['warning! cannot understand mass input in flight #' num2str(i) ', switching to reference mass']
                end
            else
                if plan(i).mass < Perf.(flight(i).type).Mass_min
                    ['error! ' num2str(i) 'th aircraft has planned mass(' num2str(plan(i).mass) ') which is less than minimum mass(' num2str(Perf.(flight(i).type).Mass_min) ') switching to minimum mass']
                    flight(i).mass = Perf.(flight(i).type).Mass_min;
                elseif plan(i).mass > Perf.(flight(i).type).Mass_max
                    ['error! ' num2str(i) 'th aircraft has planned mass(' num2str(plan(i).mass) ') which is grater than maximum mass(' num2str(Perf.(flight(i).type).Mass_max) ') switching to maximum mass']
                    flight(i).mass = Perf.(flight(i).type).Mass_max;
                else
                    flight(i).mass = str2double(plan(i).mass);
                end
            end
    end
    
    
    flight(i).FalseFix = [];
    flight(i).trajectory = [];
    flight(i).old_FalseFix = [];
    flight(i).old_trajectory = [];
    
    flight(i).Reference = [];
    flight(i).CurveFix = [];
    flight(i).ControlFix = [];
    
end


end