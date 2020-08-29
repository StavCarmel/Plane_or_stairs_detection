function [vec_A,vec_G,vec_P,vec_T,label,A,G,P,T] = load_data(folder,filetype,window,filenum,row,f_A,f_G,f_P,f_T,isfirst,A,G,P,T)
% num 0/1 -isfirst: means that if it is the first window of this session than don't
% load again and use the tables from before. less running time

% num- window [s]
% string- folder
% string- folder type

% num- f_A/G/P/T: frequency
% table A/G/P/T: the tables that were loaded at the first window

cd =folder;
pathname = folder;
string_type=strcat('*.',filetype,'*');
fileList = dir(string_type);
numberOfFiles = length(fileList);

% calculating how many indicies we need to take from every signal in order
% to get one window

ind_A=f_A*window;
ind_G=f_G*window;
ind_P=f_P*window;
ind_T=window/f_T;

i=filenum;
fileName1 = fileList(i).name;
fileName2 = fileList(i+1).name;
fileName3 = fileList(i+2).name;
fileName4 = fileList(i+3).name;


check_labels=[];
files={fileName1,fileName2,fileName3,fileName4};
for file=1:4
    if contains(files{file},'Accelerometer') 
       fileA=files{file};
    elseif contains(files{file},'Gyroscope') 
        fileG=files{file};
    elseif contains(files{file},'Pressure') 
        fileP=files{file};
    else
        fileT=files{file};
    end
    if contains(files{file},'plane')
        label=1;
    elseif contains(files{file},'up')
       label=2;
    elseif contains(files{file},'stairs')
       label=3;
    end 
    check_labels(file)=label;
end

if length(unique(check_labels))~=1
    error('There is a missing parameter in this record');
end

if isfirst==1 % it means that this is the first window for this session than load the files and create a table
A=readtable(fileA);  
G=readtable(fileG);
P=readtable(fileP); 
T=readtable(fileT); 
end

A_window=A(row*f_A:row*f_A+ind_A,:); 
    
G_window=G(row*f_G:row*f_G+ind_G,:);
    
P_window=P(row*f_P:row*f_P+ind_P,:);
    
T_window=T(row*f_T:row*f_T+ind_T,:);

vec_A=mean([A_window.x_axis_g_,A_window.y_axis_g_,A_window.z_axis_g_],2);
vec_G=mean([G_window.x_axis_deg_s_,G_window.y_axis_deg_s_,G_window.z_axis_deg_s_],2);
vec_P=P_window.pressure_Pa_;
vec_T=T_window.temperature_C_;
        
end

