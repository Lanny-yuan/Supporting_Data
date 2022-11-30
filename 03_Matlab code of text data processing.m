%% Auto-generating Sina-Weibo searching result webpages under different keyword combinations. Note that the web crawling work can also be automatically achieved by Python.
% load district name
district_name_code=readcell("path of the administrative division table");

%keyword combination 1: Fangcang & bed & administrative divisions
url_1=char('https://s.weibo.com/weibo?q=%E2%80%9C%E6%96%B9%E8%88%B1%E5%8C%BB%E9%99%A2%E2%80%9D%EF%BC%9B%E2%80%9C%E5%BA%8A%E4%BD%8D%E2%80%9D%EF%BC%9B%E2%80%9C')
url_3=urlencode(char('”'))
URL_keywords1=[];
%keyword combination 2: Fangcang & room & administrative divisions
url_1=char('https://s.weibo.com/weibo?q=%E2%80%9C%E6%96%B9%E8%88%B1%E5%8C%BB%E9%99%A2%E2%80%9D%EF%BC%9B%E2%80%9C%E6%88%BF%E9%97%B4%E2%80%9D%EF%BC%9B%E2%80%9C')
url_3=urlencode(char('”'))
URL_keywords2=[];
%generating
for i=2:height(district_name_code);
    i
    sub_name=char(district_name_code(i,2));
    if length(sub_name)>2;
        sub_name_rm=sub_name(1:end-1);
        sub_name_code=urlencode(sub_name_rm);
        sub_URL=[url_1,sub_name_code,url_3];
        URL_keywords2=[URL_keywords2;cellstr(sub_URL)];
    else
        sub_name_code=urlencode(sub_name);
        sub_URL=[url_1,sub_name_code,url_3];
        URL_keywords2=[URL_keywords2;cellstr(sub_URL)];
    end
end
% Output all auto-generated URLs for implementing web crawling
writetable(cell2table(URL_keywords2),'rename files.xlsx')


%% natural Language Processing
% simplifying the province/city
district_name_code=readcell("path of the administrative division table");
%
for i=2:height(district_name_code);
    i
    %name
    sub_name=char(district_name_code(i,2));
    if length(sub_name)>2;
        sub_name_rm=sub_name(1:end-1);
        district_name_code(i,3)=cellstr(sub_name_rm);
    else
        district_name_code(i,3)=cellstr(sub_name);
    end
    %code
    sub_code=char(district_name_code(i,2));
end

% load crawled text data
rawData=readcell("path of crawled text data");
% pre-processing the matrix
rawData(1,10)={'bed_number_sentence'};
rawData(1,11)={'bed_number'};
rawData(1,12)={'hospital_name_sentence'};
rawData(1,13)={'hospital_name'};
rawData(1,14)={'room_number_sentence'};
rawData(1,15)={'room_number'};
rawData(1,16)={'constructed_area_sentence'};
rawData(1,17)={'constructed_area'};
rawData(1,18)={'city_province1'};
rawData(1,19)={'city_province1_code'};
rawData(1,20)={'city_province2'};
rawData(1,21)={'city_province2_code'};
rawData(1,22)={'city_province3'};
rawData(1,23)={'city_province3_code'};

% defining some orientation words
bed=string('床位');
hospital=string('方舱医院');
hospital_short=string('方舱');
room=string('房间');
area=string('面积');

%Extracting information from crawled Sina-Weibo texts
for i=2:height(rawData);
    i
    sub_content=string(rawData(i,6));
    %split
    sub_content_split=strsplit(sub_content,[string('；');string('：');string('】');string('【');string('。');string('！');string('#');string('？')]);
    sub_content_split=sub_content_split';
    %bed num sentence
    try
        k1=contains(sub_content_split,bed);
        k1=find(k1);
        bed_sentence=sub_content_split(k1(1));
        rawData(i,10)=cellstr(bed_sentence);
    catch
        rawData(i,10)={'Null'};
    end
    %bed num sentence refining
    bed_sentence_split=strsplit(string(rawData(i,10)),[string('//');string('●');string('，');string('、');string('“');string('”');string('：');string('……');string('@');string('；')]);
    bed_sentence_split=bed_sentence_split';
    try
        k1=contains(bed_sentence_split,bed);
        k1=find(k1);
        bed_sentence=bed_sentence_split(k1(1));
        rawData(i,10)=cellstr(bed_sentence);
    catch
        rawData(i,10)={'Null'};
    end
    %bed num: extracting number from strings
    bed_sentence=string(rawData(i,10));
    bed_sentence_num=regexp(bed_sentence,'\d*\.?\d*','match');
    k1=contains(bed_sentence,[string('万张');string('万余张');string('万余个')]);
    k2=contains(bed_sentence,[string('一');string('二');string('三');string('四');string('五');string('六');string('七');string('八');string('九');string('十')]);
    if length(bed_sentence_num)==1&k1==0;
        rawData(i,11)=num2cell(str2num(bed_sentence_num));
    elseif length(bed_sentence_num)==1&k1==1;
        rawData(i,11)=num2cell(str2num(bed_sentence_num)*10000);
    elseif length(bed_sentence_num)>1&k1==0;
        bed_sentence_num=bed_sentence_num';
        rawData(i,11)=num2cell(max(str2num(char(bed_sentence_num))));
    elseif length(bed_sentence_num)==0&k1==1&k2==0;
        rawData(i,11)=num2cell(10000);
    else
        rawData(i,11)=num2cell(0);
    end
    %hospital name
    try
        k2=contains(sub_content_split,hospital);
        k2=find(k2);
        hospital_sentence=sub_content_split(k2);
        hospital_sentence_comb=[];
        if height(hospital_sentence)>1;
            for j=1:height(hospital_sentence);
                sub_hospital_sentence=char(hospital_sentence(j));
                hospital_sentence_comb=[hospital_sentence_comb,char('//'),sub_hospital_sentence];
            end
            rawData(i,12)=cellstr(hospital_sentence_comb);
        elseif height(hospital_sentence)==1;
            rawData(i,12)=cellstr(hospital_sentence);
        else
            rawData(i,12)={'Null'};
        end
    catch
        k2=contains(sub_content_split,hospital_short);
        k2=find(k2);
        hospital_sentence=sub_content_split(k2);
        hospital_sentence_comb=[];
        if height(hospital_sentence)>1;
            for j=1:height(hospital_sentence);
                sub_hospital_sentence=char(hospital_sentence(j));
                hospital_sentence_comb=[hospital_sentence_comb,char('//'),sub_hospital_sentence];
            end
            rawData(i,12)=cellstr(hospital_sentence_comb);
        else
            rawData(i,12)=cellstr(hospital_sentence);
        end
    end
    %room bumber sentence
    try
        k5=contains(sub_content_split,room);
        k5=find(k5);
        room_sentence=sub_content_split(k5(1));
        rawData(i,14)=cellstr(room_sentence);
    catch
        rawData(i,14)={'Null'};
    end
    %room bumber sentence refining
    room_sentence_split=strsplit(string(rawData(i,14)),[string('，');string('、');string('“');string('”');string('：');string('……');string('@');string('；')]);
    room_sentence_split=room_sentence_split';
    try
        k1=contains(room_sentence_split,room);
        k1=find(k1);
        room_sentence_split=room_sentence_split(k1(1));
        rawData(i,14)=cellstr(room_sentence_split);
    catch
        rawData(i,14)={'Null'};
    end
    %constructed area sentence
    try
        k6=contains(sub_content_split,area);
        k6=find(k6);
        area_sentence=sub_content_split(k6(1));
        rawData(i,16)=cellstr(area_sentence);
    catch
        rawData(i,16)={'Null'};
    end
    %constructed area sentence refining
    area_sentence_split=strsplit(string(rawData(i,16)),[string('，');string('、');string('“');string('”');string('：');string('……');string('@');string('；')]);
    area_sentence_split=area_sentence_split';
    try
        k1=contains(area_sentence_split,area);
        k1=find(k1);
        area_sentence_split=area_sentence_split(k1(1));
        rawData(i,16)=cellstr(area_sentence_split);
    catch
        rawData(i,16)={'Null'};
    end
    %province:city+Fangcang+bed
    province3=[];
    for h=2:height(district_name_code);
        sub_name=string(district_name_code(h,3));
        sub_code=string(district_name_code(h,1));
        k3=contains(hospital_sentence,sub_name);
        k3=find(k3);
        k4=contains(hospital_sentence,hospital_short);
        k4=find(k4);
        k5=contains(hospital_sentence,bed);
        k5=find(k5);
        k3_k4=intersect(k3,k4);
        k3_k4_k5=intersect(k3_k4,k5);
        if length(k3_k4_k5)>0;
            province=[district_name_code(h,2),sub_code];
            rawData(i,18:19)=cellstr(province);
        else
            a=1;
        end
        if length(k3_k4)>0;
            province=[district_name_code(h,2),sub_code];
            rawData(i,20:21)=cellstr(province);
        else
            a=1;
        end
        if length(k3)>0;
            province3=[district_name_code(h,2),sub_code,province3];
        else
            a=1;
        end
    end
    if length(province3)>0;
        k6=length(province3)-1;
        rawData(i,22:(22+k6))=cellstr(province3);
    else
        a=1;
    end
end
%removing repeated data:bed sentence+city
sample=rawData(:,10);
[C,ia,ic] = unique(string(sample),'rows');
k_unique=sort(ia);
rawData_rm=rawData(k_unique,:);

%dividing data according to provinces
all_province=district_name_code(2:end,:);
all_province_code=cell2mat(all_province(:,1));
for i=2:height(rawData_rm);
    i
    sub_code1=rawData_rm(i,19);
    sub_code2=rawData_rm(i,21);
    if length(cell2mat(sub_code1))>0;
        sub_code1=char(sub_code1);
        sub_code1=strrep(sub_code1,char(' '),char(''));
        sub_code1_new=[sub_code1(1:2),char('0000')];
        k1=find(all_province_code==str2num(sub_code1_new));
        sub_province=all_province(k1,2);
        rawData_rm(i,16)=sub_province;
        rawData_rm(i,17)=cellstr(sub_code1_new);
    elseif length(cell2mat(sub_code2))>0;
        sub_code2=char(sub_code2);
        sub_code2=strrep(sub_code2,char(' '),char(''));
        sub_code2_new=[sub_code2(1:2),char('0000')];
        k1=find(all_province_code==str2num(sub_code2_new));
        sub_province=all_province(k1,2);
        rawData_rm(i,16)=sub_province;
        rawData_rm(i,17)=cellstr(sub_code2_new);
    else
        continue;
    end
end

% removing repetitive data
sample=[rawData_rm(:,11),rawData_rm(:,16)];
[C,ia,ic] = unique(string(sample),'rows');
k_unique=sort(ia);
processed_data_keywords=rawData_rm(k_unique,:);

% ourputting processed matrix as a table
writetable(cell2table(processed_data_keywords),'rename files.xlsx')









