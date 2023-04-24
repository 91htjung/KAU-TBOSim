function [declat, declong]=dms2dec(lat,long)
if ischar(lat)==false;
    lat=num2str(lat);
end
if isnan(str2double(lat))==true;
    if isempty(strfind(lat, 'N'))==false;
        lat(lat=='N')=[];
        lat_neg=1;
    elseif isempty(strfind(lat, 'S'))==false;
        lat(lat=='S')=[];
        lat_neg=-1;
    end
end
if isempty(strfind(lat, '.'))==false;
    declat=lat_neg * (str2double(lat(strfind(lat,'.')-6:strfind(lat,'.')-5))+(str2double(lat(strfind(lat,'.')-4:strfind(lat,'.')-3))/60)+(str2double(lat(strfind(lat,'.')-2:length(lat)))/3600));
else
    if length(lat)==6;
        declat=lat_neg * (str2double(lat(1:2))+(str2double(lat(3:4))/60)+(str2double(lat(5:6))/3600));
    else
        ['error! input latitude' lat 'is not appropriate latitude, check length/format of input and position of decimal']
    end
end

if ischar(long)==false;
    long=num2str(long);
end
if isnan(str2double(long))==true;
    if isempty(strfind(long, 'E'))==false;
        long(long=='E')=[];
        long_neg=1;
    elseif isempty(strfind(long, 'W'))==false;
        long(long=='W')=[];
        long_neg=-1;
    end
end
if isempty(strfind(long, '.'))==false;
    declong=long_neg * (str2double(long(strfind(long,'.')-7:strfind(long,'.')-5))+(str2double(long(strfind(long,'.')-4:strfind(long,'.')-3))/60)+(str2double(long(strfind(long,'.')-2:length(long)))/3600));
else
    if length(long)==7;
        declong=long_neg * (str2double(long(1:3))+(str2double(long(4:5))/60)+(str2double(long(6:7))/3600));
    else
        ['error! input longitude' long 'is not appropriate longitude, check length/format of input and position of decimal'];
    end
end
end