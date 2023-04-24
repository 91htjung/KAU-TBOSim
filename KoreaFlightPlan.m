% function plan = KoreaFlightPlan(plan, Airspace, Procedure)
% global config Perf


fid = fopen('150118_plan.csv','r');
fplan = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'delimiter', ',');

% 1: Line Index
% 2: Category
% 3: Callsign
% 4: AC Type
% 5: AC Registration Number
% 6: Origination
% 7: ETD
% 8: ATD
% 9: Destination
% 10: ETA
% 11: ATA
% 12: Status (Dep, Arr, Del)
% 13: FPL -> disregard
% 14: SPT -> disregard
% 15: RAM -> disregard
% 16: Remarks

NonFPList = {};
NonACList = {};
timecount = 0;



for DataLen = 1:length(fplan{1})
    ['importing scenario data.. (' num2str(DataLen) '/' num2str(length(fplan{1})) ')']
    
    % Check if there is already corresponding aircrafts
    
    if ~any(strcmp({plan.callsign}, fplan{3}{DataLen}))
        
        if any(strcmp(config.AD_List, fplan{6}{DataLen}))
            % can support trajectory generation
            
            NewLine = length(plan) + 1;
            
            plan(NewLine).id = NewLine;
            plan(NewLine).callsign = fplan{3}{DataLen};
            
            
            if ~any(strcmp(fieldnames(Perf), fplan{4}{DataLen}))
                ['warning! flight #' num2str(NewLine) ' has Aircraft (' fplan{4}{DataLen} ') out of Performance List... Change into Default Aircraft (' config.defaultAC ')']
                plan(NewLine).type = config.defaultAC;
            else
                plan(NewLine).type = fplan{4}{DataLen};
            end
            
            plan(NewLine).departure = fplan{6}{DataLen};
            plan(NewLine).departure_RWY = '';
            plan(NewLine).arrival = fplan{9}{DataLen};
            plan(NewLine).arrival_RWY = '';
            
            plan(NewLine).mass = 'reference';
            plan(NewLine).gentime = (str2double(fplan{7}{DataLen}(1:2)) * 3600) + (str2double(fplan{7}{DataLen}(3:4)) * 60);
            
            
            DGA3942 FF RKSIZPZX RKRRZQZX 180620 KTULAALD  (FPL-AAL280-IS -B772/H-SDE1E3FGHIJ3J5RWXYZ/D1H -RKSI0900 -N0478F270 EGOB1L EGOBA G597 CUE Y71 XAC Y233 PQE OTR16 SMOLT  OTR15 MORAY/M080F270 DCT 34N150E 33N160E 34N170E 35N180E  36N170W 37N160W 38N150W 39N140W 39N130W DCT DACEM/N0481F370 DCT  SAC/N0477F390 DCT ILC DCT BCE DCT RSK DCT PNH DCT MDANO DEBBB1 -KDFW1217 KDAL -PBN/A1B1C1D1L1O1S2T1 NAV/RNVD1E2A1 RNP5 ACAS DOF/150118  REG/N783AN EET/RJJJ0039 RJJJ0132 SMOLT0140 MORAY0152  150E0212 160E0301 KZCE0326 170E0350 180E0439 170W0530  160W0622 150W0717 140W0812 130W0904 DACEM0920 SEL/JLRS     )"
            DGA7965 FF RKSIZPZX RKRRZQZX 171501 KTULAALD  (FPL-AAL281-IS -B772/H-SDE1E3FGHIJ3J5RWXYZ/D1H -KDFW1630 -N0494F300 LOWGN6 ADM DCT GCK DCT AKO DCT DDY DCT GTF J569  CASSL/N0483F340 J569 YYD DCT RIBIT DCT SSR/M084F340 J541 YAK  J501 TED DCT ENM B240 ERNIK/N0494F360 B240 BE B484 BUMAT A827  DERUD R213 BISMA/N0481F400 R213 MAGIT/N0488S1220 R213 JMU G212  HRB A588 CHI W107 SANKO A326 DONVO G597 AGAVO Y644 GONAV Y644  REBIT REBI1N -RKSI1405 RKSS -PBN/A1B1C1D1L1O1S2T1 NAV/RNVD1E2A1 RNP5 ACAS DOF/150117  REG/N783AN EET/CZEG0307 CZVR0316 PAZA0443 SSR0511 UHMA0735  UHMO0825 UHMM0849 UHHH1005 ZYSH1148 ZSHA1333 RKTT1344 SEL/JLRS     )"
            
            
            
            
            rem = fplan{16}{DataLen};
            if ~isempty(rem)
                % if the remarks are given
                try
                   line = rem(strfind(rem,'FPL-'):end);
                    
                    
                catch
                    
                end
            
            else
                % if the remarks are not given
                
                
            end
            
        else
            
            
            
            
        end
    else
        % There is corresponding callsign already!
        
        
        
    end
    
end
% 
%     % Check if ARTS data has same aircraft with flight data.
%     if ~and(str2double(arts{6}{DataLen}) == 0, str2double(arts{9}{DataLen}) >= 200)
%         if isempty(find(strcmp({flight.callsign}, arts{3}{DataLen}), 1))
%             if (str2double(arts{2}{DataLen}(1:2)) * 3600) + (str2double(arts{2}{DataLen}(4:5)) * 60) + str2double(arts{2}{DataLen}(7:8)) <= config.simtime
%                 
%                 % New AC
%                 FPIndex = find(strcmp(fplan{4}, arts{3}{DataLen}), 1);
%                 
%                 plan(NewLine).id = NewLine;
%                 plan(NewLine).callsign = arts{3}{DataLen};
%                 
%                 % import from plan
%                 if ~isempty(FPIndex)
%                     % AC Type
%                     if ~any(strcmp(fieldnames(Perf), fplan{7}{FPIndex}))
%                         NonACList{end + 1} = fplan{7}{FPIndex};
%                         ['warning! flight #' num2str(NewLine) ' has Aircraft (' fplan{7}{FPIndex} ') out of Performance List... Change into Default Aircraft (' config.defaultAC ')']
%                         plan(NewLine).type = config.defaultAC;
%                     else
%                         plan(NewLine).type = fplan{7}{FPIndex};
%                     end
%                     
%                     plan(NewLine).departure = fplan{11}{FPIndex};
%                     plan(NewLine).departure_RWY = '';
%                     plan(NewLine).arrival = fplan{16}{FPIndex};
%                     plan(NewLine).arrival_RWY = ['RWY' arts{10}{DataLen}];
%                     
%                     rem = cellstr(fplan{25}{FPIndex});
%                     plan(NewLine).remarks = rem{1};
%                 else
%                     % No match from plan
%                     NonFPList{end + 1} = arts{3}{DataLen};
%                     ['warning! flight #' num2str(NewLine) ' (' arts{3}{DataLen} ') has No matching Flight Plan ... Setting into default configuration']
%                     % AC Type
%                     if ~any(strcmp(fieldnames(Perf), arts{7}{DataLen}))
%                         NonACList{end + 1} = arts{7}{DataLen};
%                         ['warning! flight #' num2str(NewLine) ' has Aircraft (' arts{7}{DataLen} ') out of Performance List... Change into Default Aircraft (' config.defaultAC ')']
%                         plan(NewLine).type = config.defaultAC;
%                     else
%                         plan(NewLine).type = arts{7}{DataLen};
%                     end
%                     if length(arts{12}{DataLen}) == 4
%                         plan(NewLine).arrival = arts{12}{DataLen};
%                     else
%                         plan(NewLine).arrival = '';
%                     end
%                     
%                     if length(arts{11}{DataLen}) == 4
%                         plan(NewLine).departure = arts{11}{DataLen};
%                     else
%                         plan(NewLine).departure = '';
%                     end
%                     
%                     plan(NewLine).departure_RWY = '';
%                     plan(NewLine).arrival_RWY = ['RWY' arts{10}{DataLen}];
%                 end
%                 
%                 plan(NewLine).mass = 'reference';
%                 plan(NewLine).gentime = (str2double(arts{2}{DataLen}(1:2)) * 3600) + (str2double(arts{2}{DataLen}(4:5)) * 60) + str2double(arts{2}{DataLen}(7:8));
%                 
%                 
%                 
%                     
% 
% function [flight, plan] = ReadPlan(Airspace, Procedure)
% % 추후 txt import로 바꾸기
% 
% global Perf
% 
% plan(1).id = 1;
% plan(1).callsign = 'KAL1275';
% plan(1).type = 'B738';
% plan(1).departure = 'RKSI';
% plan(1).departure_RWY = 'RWY33R';
% plan(1).arrival = 'RKSI';
% plan(1).arrival_RWY = 'RWY33R';
% plan(1).cruising_alt = 31000;
% % 추후 profile을 개발하자 -> simulation fitting
% % 강하 profile: CDO, nomial, lowest_alt 등 여러가지, 각 번호로 세부 구분
% % CDO_flex : altitude constraint 지점간 : linear, 그 외 desc_angle
% % CDO_strict : altitude constraint 지점만 constraint 준수, 그 외 모두 desc_angle
% % CDO_linear : 모든 지점에서 altitude constraint의 linear form 
% plan(1).desc_profile = 'CDO_flex';
% % Glidepath 각도 (3도 전후), CDO 이면 Crusing Alt 부터, 아니면 IAF 부터
% plan(1).desc_angle = 3;
% % nomial_profile일 경우, lowalt와 highalt 사이의 비율로 alt 결정하는 변수
% % 0 이면 lowalt, 1 이면 highalt: 즉 0 ~ 1 사이 값
% % 일단은 uniform하게 가지만 추후 profile을 다양화하면, 각 지점별(고도별) desc_rate를 실 data에 fitting 할것
% plan(1).desc_rate = 0;
% % 상승 profile: CCO, NABP, nomial 등
% plan(1).climb_profile = 'CCO_flex';
% % CCO_climbrate는 optimum fuel로 구해야 할듯
% plan(1).climb_angle = 0;
% plan(1).climb_rate = 2200;
% plan(1).speed_control = 'linear';
% plan(1).accel_control = 'linear';
% plan(1).mass = 'reference';
% plan(1).gentime = 10;
% plan(1).Curve = 'strict';
% plan(1).remarks = '';
% 
% 
% plan(2).id = 2;
% plan(2).callsign = 'AAR251';
% plan(2).type = 'B744';
% plan(2).departure = 'RKSI';
% plan(2).departure_RWY = 'RWY15L';
% plan(2).arrival = 'RKSI';
% plan(2).arrival_RWY = 'RWY15L';
% plan(2).cruising_alt = 29000;
% plan(2).desc_profile = 'CDO_flex';
% plan(2).desc_angle = 3;
% plan(2).desc_rate = 0;
% plan(2).climb_profile = 'CCO_flex';
% plan(2).climb_angle = 0;
% plan(2).climb_rate = 2200;
% plan(2).speed_control = 'linear';
% plan(2).accel_control = 'linear';
% plan(2).mass = 'reference';
% plan(2).gentime = 10;
% plan(2).Curve = 'strict';
% plan(2).remarks = '';
% 
% plan(3).id = 3;
% plan(3).callsign = 'JJA552';
% plan(3).type = 'A333';
% plan(3).departure = 'RKSI';
% plan(3).departure_RWY = 'RWY15L';
% plan(3).arrival = 'RKSI';
% plan(3).arrival_RWY = 'RWY15L';
% plan(3).cruising_alt = 11000;
% plan(3).desc_profile = 'CDO_flex';
% plan(3).desc_angle = 3;
% plan(3).desc_rate = 0;
% plan(3).climb_profile = 'CCO_flex';
% plan(3).climb_angle = 0;
% plan(3).climb_rate = 2200;
% plan(3).speed_control = 'linear';
% plan(3).accel_control = 'linear';
% plan(3).mass = 'reference';
% plan(3).gentime = 10;
% plan(3).Curve = 'strict';
% plan(3).remarks = '';
% 
% plan(4).id = 4;
% plan(4).callsign = 'CCA2482';
% plan(4).type = 'B773';
% plan(4).departure = 'RKSI';
% plan(4).departure_RWY = 'RWY15L';
% plan(4).arrival = 'RKSI';
% plan(4).arrival_RWY = 'RWY15L';
% plan(4).cruising_alt = 28000;
% plan(4).desc_profile = 'CDO_flex';
% plan(4).desc_angle = 3;
% plan(4).desc_rate = 0;
% plan(4).climb_profile = 'CCO_flex';
% plan(4).climb_angle = 0;
% plan(4).climb_rate = 2200;
% plan(4).speed_control = 'linear';
% plan(4).accel_control = 'linear';
% plan(4).mass = 'reference';
% plan(4).gentime = 10;
% plan(4).Curve = 'strict';
% plan(4).remarks = '';
% 
% plan(5).id = 5;
% plan(5).callsign = 'JNA320';
% plan(5).type = 'C172';
% plan(5).departure = 'RKSI';
% plan(5).departure_RWY = 'RWY15L';
% plan(5).arrival = 'RKSI';
% plan(5).arrival_RWY = 'RWY15L';
% plan(5).cruising_alt = 8000;
% plan(5).desc_profile = 'CDO_flex';
% plan(5).desc_angle = 3;
% plan(5).desc_rate = 0;
% plan(5).climb_profile = 'CCO_flex';
% plan(5).climb_angle = 0;
% plan(5).climb_rate = 2200;
% plan(5).speed_control = 'linear';
% plan(5).accel_control = 'linear';
% plan(5).mass = 'reference';
% plan(5).gentime = 10;
% plan(5).Curve = 'strict';
% plan(5).remarks = '';
% 
% 
% plan(6).id = 6;
% plan(6).callsign = 'KAU1234';
% plan(6).type = 'B738';
% plan(6).departure = 'RKSI';
% plan(6).departure_RWY = 'RWY16';
% plan(6).arrival = 'RKPC';
% plan(6).arrival_RWY = 'RWY25';
% plan(6).cruising_alt = 29000;
% plan(6).desc_profile = 'CDO_flex';
% plan(6).desc_angle = 3;
% plan(6).desc_rate = 0;
% plan(6).climb_profile = 'CCO_flex';
% plan(6).climb_angle = 0;
% plan(6).climb_rate = 2800;
% plan(6).speed_control = 'linear';
% plan(6).accel_control = 'linear';
% plan(6).mass = 'reference';
% plan(6).gentime = 1;
% plan(6).Curve = 'strict';
% plan(6).remarks = '';
% 
% plan(7).id = 7;
% plan(7).callsign = 'KAU5678';
% plan(7).type = 'B738';
% plan(7).departure = 'RKSI';
% plan(7).departure_RWY = 'RWY16';
% plan(7).arrival = 'RKPC';
% plan(7).arrival_RWY = 'RWY25';
% plan(7).cruising_alt = 29000;
% plan(7).desc_profile = 'CDO_flex';
% plan(7).desc_angle = 3;
% plan(7).desc_rate = 0;
% plan(7).climb_profile = 'CCO_flex';
% plan(7).climb_angle = 0;
% plan(7).climb_rate = 2800;
% plan(7).speed_control = 'linear';
% plan(7).accel_control = 'linear';
% plan(7).mass = 'reference';
% plan(7).gentime = 120;
% plan(7).Curve = 'strict';
% plan(7).remarks = '';
% 
% plan(8).id = 8;
% plan(8).callsign = 'ABC8888';
% plan(8).type = 'A333';
% plan(8).departure = 'RKPC';
% plan(8).departure_RWY = 'RWY25';
% plan(8).arrival = 'RKSI';
% plan(8).arrival_RWY = 'RWY33L';
% plan(8).cruising_alt = 29000;
% plan(8).desc_profile = 'CDO_flex';
% plan(8).desc_angle = 3;
% plan(8).desc_rate = 0;
% plan(8).climb_profile = 'CCO_flex';
% plan(8).climb_angle = 0;
% plan(8).climb_rate = 2800;
% plan(8).speed_control = 'linear';
% plan(8).accel_control = 'linear';
% plan(8).mass = 'reference';
% plan(8).gentime = 300;
% plan(8).Curve = 'strict';
% plan(8).remarks = '';
% 
% plan(9).id = 9;
% plan(9).callsign = 'DEF9999';
% plan(9).type = 'A333';
% plan(9).departure = 'RKPC';
% plan(9).departure_RWY = 'RWY25';
% plan(9).arrival = 'RKSI';
% plan(9).arrival_RWY = 'RWY33L';
% plan(9).cruising_alt = 29000;
% plan(9).desc_profile = 'CDO_flex';
% plan(9).desc_angle = 3;
% plan(9).desc_rate = 0;
% plan(9).climb_profile = 'CCO_flex';
% plan(9).climb_angle = 0;
% plan(9).climb_rate = 2800;
% plan(9).speed_control = 'linear';
% plan(9).accel_control = 'linear';
% plan(9).mass = 'reference';
% plan(9).gentime = 480;
% plan(9).Curve = 'strict';
% plan(9).remarks = '';
% 
% 
% plan(1).route.status={'procedure' 'route' 'route'};
% plan(1).route.origination={'SI707' 'BOPTA' 'BEDES'};
% plan(1).route.destination={'BOPTA' 'BEDES' 'DOTOL'};
% plan(1).route.type={'SID' 'route' 'route'};
% plan(1).route.trajectory={'BOPTA1L' 'Z51' 'Y711'};
% plan(1).route.altitude={'default' 'default' 'default'};
% 
% plan(2).route.status={'route' 'procedure' 'procedure'};
% plan(2).route.origination={'KAMIT' 'OLMEN' 'DANAN'};
% plan(2).route.destination={'OLMEN' 'DANAN' 'RKSI_RWY15L_THR'};
% plan(2).route.type={'route' 'STAR' 'INST'};
% plan(2).route.trajectory={'Y722' 'OLMEN1N' 'GNSSRWY15L'};
% plan(2).route.altitude={'default' 'default' 'default'};
% 
% plan(3).route.status={'route' 'route' 'route' 'route'};
% plan(3).route.origination={'AGAVO' 'EGOBA' 'KAE' 'TENAS'};
% plan(3).route.destination={'EGOBA' 'KAE' 'TENAS' 'ANDOL'};
% plan(3).route.type={'route' 'route' 'route' 'route'};
% plan(3).route.trajectory={'Y644' 'G597' 'B467' 'L512'};
% plan(3).route.altitude={'default' 'default' 'default' 'default'};
% 
% plan(4).route.status={'direct'};
% plan(4).route.origination={''};
% plan(4).route.destination={'DANAN'};
% plan(4).route.type={'waypoint'};
% plan(4).route.trajectory={''};
% plan(4).route.altitude={'7000'};
% 
% plan(5).route.status={'vectoring' 'procedure'};
% plan(5).route.origination={'OLMEN' 'DANAN'};
% plan(5).route.destination={'DANAN' 'RKSI_RWY15L_THR'};
% plan(5).route.type={'vectoring' 'INST'};
% plan(5).route.trajectory={'' 'GNSSRWY15L'};
% plan(5).route.altitude={'default' 'default'};
% 
% plan(6).route.status={'procedure' 'route' 'route' 'procedure' 'procedure'};
% plan(6).route.origination={'SI701' 'BOPTA' 'BEDES' 'DOTOL' 'HANUL'};
% plan(6).route.destination={'BOPTA' 'BEDES' 'DOTOL' 'HANUL' 'RKPC_RWY25_THR'};
% plan(6).route.type={'SID' 'route' 'route' 'STAR' 'INST'};
% plan(6).route.trajectory={'BOPTA1S' 'Z51' 'Y711' 'DOTOL2T' 'GNSSRWY25'};
% plan(6).route.altitude={'default' 'default' 'default' 'default' 'default'};
% 
% plan(7).route.status={'procedure' 'route' 'route' 'procedure' 'procedure'};
% plan(7).route.origination={'SI701' 'BOPTA' 'BEDES' 'DOTOL' 'HANUL'};
% plan(7).route.destination={'BOPTA' 'BEDES' 'DOTOL' 'HANUL' 'RKPC_RWY25_THR'};
% plan(7).route.type={'SID' 'route' 'route' 'STAR' 'INST'};
% plan(7).route.trajectory={'BOPTA1S' 'Z51' 'Y711' 'DOTOL2T' 'GNSSRWY25'};
% plan(7).route.altitude={'default' 'default' 'default' 'default' 'default'};
% 
% plan(8).route.status={      'procedure'     'route'     'procedure' 'procedure'};
% plan(8).route.origination={ 'LAXER'         'KAMIT'     'OLMEN'     'PULUN'};
% plan(8).route.destination={ 'KAMIT'         'OLMEN'     'PULUN'     'RKSI_RWY33L_THR'};
% plan(8).route.type={        'SID'           'route'     'STAR'      'INST'};
% plan(8).route.trajectory={  'KAMIT1W'       'Y722'      'OLMEN1P'   'ILSRWY33L_P'};
% plan(8).route.altitude={    'default'       'default'   'default'   'default'};
% 
% plan(9).route.status={      'procedure'     'route'     'procedure' 'procedure'};
% plan(9).route.origination={ 'LAXER'         'KAMIT'     'OLMEN'     'PULUN'};
% plan(9).route.destination={ 'KAMIT'         'OLMEN'     'PULUN'     'RKSI_RWY33L_THR'};
% plan(9).route.type={        'SID'           'route'     'STAR'      'INST'};
% plan(9).route.trajectory={  'KAMIT1W'       'Y722'      'OLMEN1P'   'ILSRWY33L_P'};
% plan(9).route.altitude={    'default'       'default'   'default'   'default'};
% 
% for no = 10:13
%     
%     plan(no).id = no;
%     plan(no).type = 'B738';
%     plan(no).departure = 'RKSI';
%     plan(no).departure_RWY = 'RWY16';
%     plan(no).arrival = 'RKPC';
%     plan(no).arrival_RWY = 'RWY25';
%     plan(no).cruising_alt = 29000;
%     plan(no).desc_profile = 'CDO_flex';
%     plan(no).desc_angle = 3;
%     plan(no).desc_rate = 0;
%     plan(no).climb_profile = 'CCO_flex';
%     plan(no).climb_angle = 0;
%     plan(no).climb_rate = 2800;
%     plan(no).speed_control = 'linear';
%     plan(no).accel_control = 'linear';
%     plan(no).mass = 'reference';
%     plan(no).gentime = 120;
%     plan(no).Curve = 'strict';
%     
%     
%     
%     plan(no).route.status={'procedure' 'route' 'route' 'procedure' 'procedure'};
%     plan(no).route.origination={'SI701' 'BOPTA' 'BEDES' 'DOTOL' 'HANUL'};
%     plan(no).route.destination={'BOPTA' 'BEDES' 'DOTOL' 'HANUL' 'RKPC_RWY25_THR'};
%     plan(no).route.type={'SID' 'route' 'route' 'STAR' 'INST'};
%     plan(no).route.trajectory={'BOPTA1S' 'Z51' 'Y711' 'DOTOL2T' 'GNSSRWY25'};
%     plan(no).route.altitude={'default' 'default' 'default' 'default' 'default'};
%     
%     
%     flight(no).command.status={'procedure' 'route' 'route' 'procedure' 'procedure'};
%     flight(no).command.origination={'SI701' 'BOPTA' 'BEDES' 'DOTOL' 'HANUL'};
%     flight(no).command.destination={'BOPTA' 'BEDES' 'DOTOL' 'HANUL' 'RKPC_RWY25_THR'};
%     flight(no).command.type={'SID' 'route' 'route' 'STAR' 'INST'};
%     flight(no).command.trajectory={'BOPTA1S' 'Z51' 'Y711' 'DOTOL2T' 'GNSSRWY25'};
%     flight(no).command.altitude={'default' 'default' 'default' 'default' 'default'};
% end
% 
%     plan(10).callsign = 'KAUDYNW';
%     plan(11).callsign = 'KAUDYWA';
%     plan(12).callsign = 'KAUSTNW';
%     plan(13).callsign = 'KAUSTWA';
%     
%     
% %     flight(i).command.status='idle'; % 현재 행동 (avoid collision, direct to, procedure, follow, holding, idle  등
% %     flight(i).command.dest=0;
% 
% % 일단 개발 편의을 위해서 각 waypoint 및 변수를 string으로 받았지만,
% % 코드 완성 후 이를 모두 WP_id, Proc_id로 바꿀것 -> 메모리 사용 최소화를 위해
% flight(1).command.status={'procedure' 'route' 'route'};
% flight(1).command.origination={'SI707' 'BOPTA' 'BEDES'};
% flight(1).command.destination={'BOPTA' 'BEDES' 'DOTOL'};
% flight(1).command.type={'SID' 'route' 'route'};
% flight(1).command.trajectory={'BOPTA1L' 'Z51' 'Y711'};
% flight(1).command.altitude={'default' 'default' 'default'};
% 
% flight(2).command.status={'route' 'procedure' 'procedure'};
% flight(2).command.origination={'KAMIT' 'OLMEN' 'DANAN'};
% flight(2).command.destination={'OLMEN' 'DANAN' 'RKSI_RWY15L_THR'};
% flight(2).command.type={'route' 'STAR' 'INST'};
% flight(2).command.trajectory={'Y722' 'OLMEN1N' 'GNSSRWY15L'};
% flight(2).command.altitude={'default' 'default' 'default'};
% 
% flight(3).command.status={'route' 'route' 'route' 'route'};
% flight(3).command.origination={'AGAVO' 'EGOBA' 'KAE' 'TENAS'};
% flight(3).command.destination={'EGOBA' 'KAE' 'TENAS' 'ANDOL'};
% flight(3).command.type={'route' 'route' 'route' 'route'};
% flight(3).command.trajectory={'Y644' 'G597' 'B467' 'L512'};
% flight(3).command.altitude={'default' 'default' 'default' 'default'};
% 
% flight(4).command.status={'direct'};
% flight(4).command.origination={''};
% flight(4).command.destination={'DANAN'};
% flight(4).command.type={'waypoint'};
% flight(4).command.trajectory={''};
% flight(4).command.altitude={'7000'};
% 
% flight(5).command.status={'vectoring' 'procedure'};
% flight(5).command.origination={'OLMEN' 'DANAN'};
% flight(5).command.destination={'DANAN' 'RKSI_RWY15L_THR'};
% flight(5).command.type={'vectoring' 'INST'};
% flight(5).command.trajectory={'' 'GNSSRWY15L'};
% flight(5).command.altitude={'default' 'default'};
% 
% flight(6).command.status={'procedure' 'route' 'route' 'procedure' 'procedure'};
% flight(6).command.origination={'SI701' 'BOPTA' 'BEDES' 'DOTOL' 'HANUL'};
% flight(6).command.destination={'BOPTA' 'BEDES' 'DOTOL' 'HANUL' 'RKPC_RWY25_THR'};
% flight(6).command.type={'SID' 'route' 'route' 'STAR' 'INST'};
% flight(6).command.trajectory={'BOPTA1S' 'Z51' 'Y711' 'DOTOL2T' 'GNSSRWY25'};
% flight(6).command.altitude={'default' 'default' 'default' 'default' 'default'};
% 
% flight(7).command.status={'procedure' 'route' 'route' 'procedure' 'procedure'};
% flight(7).command.origination={'SI701' 'BOPTA' 'BEDES' 'DOTOL' 'HANUL'};
% flight(7).command.destination={'BOPTA' 'BEDES' 'DOTOL' 'HANUL' 'RKPC_RWY25_THR'};
% flight(7).command.type={'SID' 'route' 'route' 'STAR' 'INST'};
% flight(7).command.trajectory={'BOPTA1S' 'Z51' 'Y711' 'DOTOL2T' 'GNSSRWY25'};
% flight(7).command.altitude={'default' 'default' 'default' 'default' 'default'};
% 
% flight(8).command.status={      'procedure'     'route'     'procedure' 'procedure'};
% flight(8).command.origination={ 'LAXER'         'KAMIT'     'OLMEN'     'PULUN'};
% flight(8).command.destination={ 'KAMIT'         'OLMEN'     'PULUN'     'RKSI_RWY33L_THR'};
% flight(8).command.type={        'SID'           'route'     'STAR'      'INST'};
% flight(8).command.trajectory={  'KAMIT1W'       'Y722'      'OLMEN1P'   'ILSRWY33L_P'};
% flight(8).command.altitude={    'default'       'default'   'default'   'default'};
% 
% flight(9).command.status={      'procedure'     'route'     'procedure' 'procedure'};
% flight(9).command.origination={ 'LAXER'         'KAMIT'     'OLMEN'     'PULUN'};
% flight(9).command.destination={ 'KAMIT'         'OLMEN'     'PULUN'     'RKSI_RWY33L_THR'};
% flight(9).command.type={        'SID'           'route'     'STAR'      'INST'};
% flight(9).command.trajectory={  'KAMIT1W'       'Y722'      'OLMEN1P'   'ILSRWY33L_P'};
% flight(9).command.altitude={    'default'       'default'   'default'   'default'};
% 
% % name to id 변환 코드
% for i = 1:length(flight)
%     for k = 1:length(flight(i).command.status);
%         if isempty(flight(i).command.origination{k}) == 0;
%             flight(i).command.origination{k} = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, flight(i).command.origination{k})==1).id;
%         end
%         if isempty(flight(i).command.destination{k}) == 0;
%             flight(i).command.destination{k} = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, flight(i).command.destination{k})==1).id;
%         end
%         
%         if isempty(flight(i).command.trajectory{k}) == 0;
%             flight(i).command.trajectory{k} = Procedure(strcmp({Procedure.name}, flight(i).command.trajectory{k})==1).id;
%         end
%     end
% end
% 
% 
% end
% 
%             end
%             
%         end
%     end
% end
% end
% 
