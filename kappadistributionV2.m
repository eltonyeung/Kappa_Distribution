%Kappa distribution analysis (Within sensor)

%% Predefine Paths and Patient ID
% clear variables
clear
clc

%load list of selected patient number
patientnumber = readtable('patientnumber.csv');
patientnumber = table2array(patientnumber);
patientnumber_XsensN = patientnumber(:,1);
patientnumber_XsensC = patientnumber(:,2);
patientnumber_Apple = patientnumber(:,3);

%Define input and output pathways
pathEY ='D:\Box Sync\Box Sync\Elton Shared\All task classifications (E.Y.) V3\';
pathMA ='D:\Box Sync\Box Sync\Elton Shared\All task classifications (M.A.) V3\';
pathTW ='D:\Box Sync\Box Sync\Elton Shared\Natural Xsens classifications (T.W.) V3 csvformat\';
pathOUT = 'D:\Box Sync\Box Sync\Elton Shared\KappaFigures\Summated CM\';

%load list of files in each rater's folder for data extraction
fileIDsEY =dir(strcat(pathEY,'*.csv'));
fileIDsEY = struct2cell(fileIDsEY)';
fileIDsEY(:,[2:6]) = [];

fileIDsMA =dir(strcat(pathMA,'*.csv'));
fileIDsMA = struct2cell(fileIDsMA)';
fileIDsMA(:,[2:6]) = [];

fileIDsTW = [dir(strcat(pathTW,'*.csv')); dir(strcat(pathTW,'*.xlsx'))];
fileIDsTW = struct2cell(fileIDsTW)';
fileIDsTW(:,[2:6]) = [];


%% Automatically generate and save annotation and confusion matrix in a loop
%Predefine number of subjects for Xsens Natural
m = 49

%initialise loop
for n = 1:m   %patient number, manually insert number of patient selected here.

disp(patientnumber_XsensN(n))
Patient = char(patientnumber_XsensN(n));

idx1 = contains(fileIDsEY, patientnumber_XsensN(n));
rownum1 = find(idx1,1,'last');

idx2 = contains(fileIDsMA, patientnumber_XsensN(n));
rownum2 = find(idx2,1,'last');

idx3 = contains(fileIDsTW, patientnumber_XsensN(n));
rownum3 = find(idx3,1,'last');

%direct pathname and file directory and display raters' initials
if isempty(rownum1) == 1,
    raters = 'TW&MA'
    pn1 = pathTW;
     else pn1 = pathEY;
    raters = 'EY&MA'
end
     pn2 = pathMA;
    
%define filename in preparation for loading in following steps
if raters == 'TW&MA'
    fn1 = char(fileIDsTW(rownum3));
else fn1 = char(fileIDsEY(rownum1));
end
     fn2 = char(fileIDsMA(rownum2));
     
%break here!!!!!!!!!!!!!!!!!!
%load rater 1's rating
F1 = pwd;

cd(pn1)
fprintf('CHOSEN FOLDER No.1: %s\n', pn1)
fprintf('\tReading: ');
rawClassData1 = readtable(fn1);
fprintf('%s [%d x %d] & ', fn1);

%load rater 2's rating
cd(pn2)
fprintf('\nCHOSEN FOLDER No.2: %s\n', pn2)
fprintf('\tReading: ');
rawClassData2 = readtable(fn2);
fprintf('%s [%d x %d] & ', fn2);

cd(F1)

clear pathEY pathMA pathTW idx1 idx2 idx3 pn1 pn2 rownum1 rownum2 rownum3 fileIDs*

% data preparation    BREAK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%rater1
ClassData1 = rawClassData1(:,[7 11 12]);
ClassData1 =table2array(ClassData1);
%rater2
ClassData2 = rawClassData2(:,[7 11 12]);
ClassData2 =table2array(ClassData2);

%Convert Rater 1 annotation seconds into DeciSeconds (this is to preserve those classifications that start and end within same second)
ClassDataDS1=[ClassData1(:,[2 3])*10 ClassData1(:,1) zeros(length(ClassData1),1)];

%Convert Rater 2 annotation seconds into DeciSeconds (this is to preserve those classifications that start and end within same second)
ClassDataDS2=[ClassData2(:,[2 3])*10 ClassData2(:,1) zeros(length(ClassData2),1)];

clear rawClassData1 rawClassData2 ClassData1 ClassData2 pn1 pn2 F1

%Correct for NPT unsync
%ClassDataDS2(:,1:2) = ClassDataDS2(:,1:2)-58;

% Generate Running Order of Annotations 
ClassDataDS1 =round(ClassDataDS1); %rater 1
ClassDataDS2 =round(ClassDataDS2); %rater 2

%%remove zero start index from all class files
if ClassDataDS1(1,1) ==0
   ClassDataDS1(1,1)=10;
end 
if ClassDataDS1(2,1) ==0
   ClassDataDS1(2,1)=10;
end 
if ClassDataDS2(1,1)==0
    ClassDataDS2(1,1)=10;
end 
if ClassDataDS2(2,1)==0
    ClassDataDS2(2,1)=10;
end 

% cut classification files same size
max1 =max(ClassDataDS1(:,2)); %find last annotation rater 1
max2 =max(ClassDataDS2(:,2)); %find last annotation rater 2

minfinal = min(max1,max2); %find where to cut annotation files
maxfinal = max(max1,max2);

RunOrderpos =zeros(maxfinal,3); 
RunOrderact =zeros(maxfinal,3);
RunOrderfun =zeros(maxfinal,3);
RunOrdertrans =zeros(maxfinal,3);

clear max1 max2


% Writing into RunOrder format   %BREAKHERE!!!!!!!!!!!!!!!!
%add postures to RunOrderpos
%rater 1
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3)<6
    RunOrderpos(ClassDataDS1(i,1): ClassDataDS1(i,2),1)=  ClassDataDS1(i,3);
    end
end 

%rater 2
for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3)<6
    RunOrderpos(ClassDataDS2(i,1): ClassDataDS2(i,2),2)=  ClassDataDS2(i,3);
    end
end 

%add functional to RunOrderfun
%rater 1
funindex1 =find(ClassDataDS1(:,3)==6 | ClassDataDS1(:,3)==8 ...
        | ClassDataDS1(:,3)==9 | ClassDataDS1(:,3)==27 | ClassDataDS1(:,3)==22 ...
        | ClassDataDS1(:,3)==23 | ClassDataDS1(:,3)==26 | ClassDataDS1(:,3)==24);
funindex1 =[1;funindex1];

for k =1:length(funindex1)-1
    t=k+1;
    RunOrderfun(ClassDataDS1(funindex1(k)):ClassDataDS1(funindex1(t)),1)= ClassDataDS1(funindex1(t),3);
end

%rater 2
funindex2 =find(ClassDataDS2(:,3)==6 | ClassDataDS2(:,3)==8 ...
        | ClassDataDS2(:,3)==9 | ClassDataDS2(:,3)==27 | ClassDataDS2(:,3)==22 ...
        | ClassDataDS2(:,3)==23 | ClassDataDS2(:,3)==26 | ClassDataDS2(:,3)==24);
funindex2 =[1;funindex2];
    
for k =1:length(funindex2)-1
    t=k+1;
    RunOrderfun(ClassDataDS2(funindex2(k)):ClassDataDS2(funindex2(t)),2)= ClassDataDS2(funindex2(t),3);
end

%
% add activities to RunOrderact
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3)>9 && ClassDataDS1(i,3)<18
    RunOrderact(ClassDataDS1(i,1): ClassDataDS1(i,2),1)=  ClassDataDS1(i,3);
    end
end 

%MS
for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3)>9 && ClassDataDS2(i,3)<18
    RunOrderact(ClassDataDS2(i,1): ClassDataDS2(i,2),2)=  ClassDataDS2(i,3);
    end
end


%add transition to RunOrdertrans
%Rater1
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) ==28
    RunOrdertrans(ClassDataDS1(i,1): ClassDataDS1(i,2),1)=  ClassDataDS1(i,3);
    end
end

%Rater2
for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3)==28
    RunOrdertrans(ClassDataDS2(i,1): ClassDataDS2(i,2),2)=  ClassDataDS2(i,3);
    end
end

%BREAK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% label occluded or sensor removed periods
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) >17 && ClassDataDS1(i,3) <21
    RunOrderact(ClassDataDS1(i,1): ClassDataDS1(i,2),1)= 18;  %original:= ClassDataDS1(i,3);
    end
end 


for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3) >17 && ClassDataDS2(i,3) <21
    RunOrderact(ClassDataDS2(i,1): ClassDataDS2(i,2),2)= 18;
    end
end

for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) >17 && ClassDataDS1(i,3) <21
    RunOrderpos(ClassDataDS1(i,1): ClassDataDS1(i,2),1)= 18;
    end
end 

for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3) >17 && ClassDataDS2(i,3) <21
    RunOrderpos(ClassDataDS2(i,1): ClassDataDS2(i,2),2)= 18;
    end
end

for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) >17 && ClassDataDS1(i,3) <21
    RunOrderfun(ClassDataDS1(i,1): ClassDataDS1(i,2),1)= 18;
    end
end 

for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3) >17 && ClassDataDS2(i,3) <21
    RunOrderfun(ClassDataDS2(i,1): ClassDataDS2(i,2),2)= 18;
    end
end

% 
%Locate disagreement between two raters for plotting figures
% RunOrderpos = RunOrderpos(all(RunOrderpos(:,1:2),2),:);
RunOrderpos(:,3)=RunOrderpos(:,1)~=RunOrderpos(:,2);

% RunOrderfun = RunOrderfun(all(RunOrderfun(:,1:2),2),:);
RunOrderfun(:,3)=RunOrderfun(:,1)~=RunOrderfun(:,2);

% RunOrderact = RunOrderact(all(RunOrderact(:,1:2),2),:);
RunOrderact(:,3)=RunOrderact(:,1)~=RunOrderact(:,2);

% RunOrdertrans = RunOrdertrans(all(RunOrdertrans(:,1:2),2),:);
RunOrdertrans(:,3)=RunOrdertrans(:,1)~=RunOrdertrans(:,2);


%MODIFICATION HERE 
% Remove occluded rows
RunOrderact(RunOrderact(:,1)==18,:) = [];
RunOrderact(RunOrderact(:,2)==18,:) = [];
RunOrderfun(RunOrderfun(:,1)==18,:) = [];
RunOrderfun(RunOrderfun(:,2)==18,:) = [];
RunOrderpos(RunOrderpos(:,1)==18,:) = [];
RunOrderpos(RunOrderpos(:,2)==18,:) = [];

% Posture preparation
%remove dispute rows, extract only the incidents agreed upon by 2 raters
RunOrderpos(RunOrderpos(:,3)==1,:) = [];
RunOrderact(RunOrderact(:,3)==1,:) = [];
RunOrderfun(RunOrderfun(:,3)==1,:) = [];



% figure(1)
% cm =confusionchart(RunOrderpos(:,1),RunOrderpos(:,2));
% % cm.Normalization = 'total-normalized';
% cm.XLabel = 'Rater 1';
% cm.YLabel = 'Rater 2';
% cm.Title =  'Xsens Natural Summated CM Postures';
% cm.RowSummary = 'row-normalized';
% cm.ColumnSummary = 'column-normalized';
% cmpos_XsensN = cm.NormalizedValues;
% %
% figure(2)
% cm =confusionchart(RunOrderfun(:,1),RunOrderfun(:,2));
% cm.Normalization = 'total-normalized';
% cm.XLabel = 'Rater 1';
% cm.YLabel = 'Rater 2';
% cm.Title = 'Xsens Natural Summated CM Functional';
% cm.RowSummary = 'row-normalized';
% cm.ColumnSummary = 'column-normalized';
% cmfun_XsensN = cm.NormalizedValues;
% 
% figure(3)
% cm =confusionchart(RunOrderact(:,1),RunOrderact(:,2));
% cm.Normalization = 'total-normalized';
% cm.XLabel = 'Rater 1';
% cm.YLabel = 'Rater 2';
% cm.Title = 'Xsens Natural Summated CM Activities';
% cm.RowSummary = 'row-normalized';
% cm.ColumnSummary = 'column-normalized';
% cmact_XsensN = cm.NormalizedValues;
% 

% cm_pos_XsensN = zeros(6,6);
%     for k=1:5
%      %rater1
%         if RunOrderpos(i,1) ==k
%            cm_pos_XsensN(i,k)=cm_pos_XsensN(i,k)+1;
%         end
%     end


mat_pos_score_XsensN(n).name = Patient;
mat_pos_score_XsensN(n).lyingbed = sum(RunOrderpos(:,1) == 1);
mat_pos_score_XsensN(n).sittingbed = sum(RunOrderpos(:,1) == 2);
mat_pos_score_XsensN(n).sittingchair = sum(RunOrderpos(:,1) == 3);
mat_pos_score_XsensN(n).standing = sum(RunOrderpos(:,1) == 4);
mat_pos_score_XsensN(n).walking = sum(RunOrderpos(:,1) == 5);
mat_pos_score_XsensN(n).notask = sum(RunOrderpos(:,1) == 0);

%clear current workspace
clear ClassDataDS* fn* funindex* i max1 max2 raters Patient maxfinal minfinal RunOrder* k

%Re-initialise with path details
pathEY ='D:\Box Sync\Box Sync\Elton Shared\All task classifications (E.Y.) V3\';
pathMA ='D:\Box Sync\Box Sync\Elton Shared\All task classifications (M.A.) V3\';
pathTW ='D:\Box Sync\Box Sync\Elton Shared\Natural Xsens classifications (T.W.) V3 csvformat\';

%load list of files in each rater's folder for data extraction
fileIDsEY =dir(strcat(pathEY,'*.csv'));
fileIDsEY = struct2cell(fileIDsEY)';
fileIDsEY(:,[2:6]) = [];

fileIDsMA =dir(strcat(pathMA,'*.csv'));
fileIDsMA = struct2cell(fileIDsMA)';
fileIDsMA(:,[2:6]) = [];

fileIDsTW = [dir(strcat(pathTW,'*.csv')); dir(strcat(pathTW,'*.xlsx'))];
fileIDsTW = struct2cell(fileIDsTW)';
fileIDsTW(:,[2:6]) = [];


end

for n = 1:m
x = sum([mat_pos_score_XsensN(n).lyingbed mat_pos_score_XsensN(n).sittingbed mat_pos_score_XsensN(n).sittingchair mat_pos_score_XsensN(n).standing mat_pos_score_XsensN(n).walking mat_pos_score_XsensN(n).notask])
mat_pos_score_XsensN(n).lyingbed = mat_pos_score_XsensN(n).lyingbed ./x
mat_pos_score_XsensN(n).sittingbed = mat_pos_score_XsensN(n).sittingbed ./x
mat_pos_score_XsensN(n).sittingchair = mat_pos_score_XsensN(n).sittingchair ./x
mat_pos_score_XsensN(n).standing = mat_pos_score_XsensN(n).standing ./x
mat_pos_score_XsensN(n).walking = mat_pos_score_XsensN(n).walking ./x
mat_pos_score_XsensN(n).notask = mat_pos_score_XsensN(n).notask ./x
end 

clear RunOrder* maxfinal minfinal m n k t ClassData*
%% Repeat for XsensC 
%Predefine number of subjects for the analysis
m = 18

% Automatically generate and save annotation and confusion matrix in a loop - XSENSC GROUP
%initialise loop
for n = 1:m   %patient number, manually insert number of patient selected here.

disp(patientnumber_XsensC(n))
Patient = char(patientnumber_XsensC(n));

idx1 = contains(fileIDsEY, patientnumber_XsensC(n));
rownum1 = find(idx1,1,'last');

idx2 = contains(fileIDsMA, patientnumber_XsensC(n));
rownum2 = find(idx2,1,'last');

idx3 = contains(fileIDsTW, patientnumber_XsensC(n));
rownum3 = find(idx3,1,'last');

%direct pathname and file directory and display raters' initials
if isempty(rownum1) == 1,
    raters = 'TW&MA'
    pn1 = pathTW;
     else pn1 = pathEY;
    raters = 'EY&MA'
end
     pn2 = pathMA;
    
%define filename in preparation for loading in following steps
if raters == 'TW&MA'
    fn1 = char(fileIDsTW(rownum3));
else fn1 = char(fileIDsEY(rownum1));
end
     fn2 = char(fileIDsMA(rownum2));
     
%break here!!!!!!!!!!!!!!!!!!
%load rater 1's rating
F1 = pwd;

cd(pn1)
fprintf('CHOSEN FOLDER No.1: %s\n', pn1)
fprintf('\tReading: ');
rawClassData1 = readtable(fn1);
fprintf('%s [%d x %d] & ', fn1);

%load rater 2's rating
cd(pn2)
fprintf('\nCHOSEN FOLDER No.2: %s\n', pn2)
fprintf('\tReading: ');
rawClassData2 = readtable(fn2);
fprintf('%s [%d x %d] & ', fn2);

cd(F1)

clear pathEY pathMA pathTW idx1 idx2 idx3 pn1 pn2 rownum1 rownum2 rownum3 fileIDs*

% data preparation    BREAK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%rater1
ClassData1 = rawClassData1(:,[7 11 12]);
ClassData1 =table2array(ClassData1);
%rater2
ClassData2 = rawClassData2(:,[7 11 12]);
ClassData2 =table2array(ClassData2);

%Convert Rater 1 annotation seconds into DeciSeconds (this is to preserve those classifications that start and end within same second)
ClassDataDS1=[ClassData1(:,[2 3])*10 ClassData1(:,1) zeros(length(ClassData1),1)];

%Convert Rater 2 annotation seconds into DeciSeconds (this is to preserve those classifications that start and end within same second)
ClassDataDS2=[ClassData2(:,[2 3])*10 ClassData2(:,1) zeros(length(ClassData2),1)];

clear rawClassData1 rawClassData2 ClassData1 ClassData2 pn1 pn2 F1

%Correct for NPT unsync
%ClassDataDS2(:,1:2) = ClassDataDS2(:,1:2)-58;

% Generate Running Order of Annotations 
ClassDataDS1 =round(ClassDataDS1); %rater 1
ClassDataDS2 =round(ClassDataDS2); %rater 2

%%remove zero start index from all class files
if ClassDataDS1(1,1) ==0
   ClassDataDS1(1,1)=10;
end 
if ClassDataDS1(2,1) ==0
   ClassDataDS1(2,1)=10;
end 
if ClassDataDS2(1,1)==0
    ClassDataDS2(1,1)=10;
end 
if ClassDataDS2(2,1)==0
    ClassDataDS2(2,1)=10;
end 

%%remove negative start index from all class files
if ClassDataDS1(1,1) <0
   ClassDataDS1(1,1)=10;
end 
if ClassDataDS1(2,1) <0
   ClassDataDS1(2,1)=10;
end 
if ClassDataDS2(1,1) <0
    ClassDataDS2(1,1)=10;
end 
if ClassDataDS2(2,1) <0
    ClassDataDS2(2,1)=10;
end 


% cut classification files same size
max1 =max(ClassDataDS1(:,2)); %find last annotation rater 1
max2 =max(ClassDataDS2(:,2)); %find last annotation rater 2

minfinal = min(max1,max2); %find where to cut annotation files
maxfinal = max(max1,max2);

RunOrderpos =zeros(maxfinal,3); 
RunOrderact =zeros(maxfinal,3);
RunOrderfun =zeros(maxfinal,3);
RunOrdertrans =zeros(maxfinal,3);

clear max1 max2


% Writing into RunOrder format   %BREAKHERE!!!!!!!!!!!!!!!!
%add postures to RunOrderpos
%rater 1
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3)<6
    RunOrderpos(ClassDataDS1(i,1): ClassDataDS1(i,2),1)=  ClassDataDS1(i,3);
    end
end 

%rater 2
for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3)<6
    RunOrderpos(ClassDataDS2(i,1): ClassDataDS2(i,2),2)=  ClassDataDS2(i,3);
    end
end 

%add functional to RunOrderfun
%rater 1
funindex1 =find(ClassDataDS1(:,3)==6 | ClassDataDS1(:,3)==8 ...
        | ClassDataDS1(:,3)==9 | ClassDataDS1(:,3)==27 | ClassDataDS1(:,3)==22 ...
        | ClassDataDS1(:,3)==23 | ClassDataDS1(:,3)==26 | ClassDataDS1(:,3)==24);
funindex1 =[1;funindex1];

for k =1:length(funindex1)-1
    t=k+1;
    RunOrderfun(ClassDataDS1(funindex1(k)):ClassDataDS1(funindex1(t)),1)= ClassDataDS1(funindex1(t),3);
end

%rater 2
funindex2 =find(ClassDataDS2(:,3)==6 | ClassDataDS2(:,3)==8 ...
        | ClassDataDS2(:,3)==9 | ClassDataDS2(:,3)==27 | ClassDataDS2(:,3)==22 ...
        | ClassDataDS2(:,3)==23 | ClassDataDS2(:,3)==26 | ClassDataDS2(:,3)==24);
funindex2 =[1;funindex2];
    
for k =1:length(funindex2)-1
    t=k+1;
    RunOrderfun(ClassDataDS2(funindex2(k)):ClassDataDS2(funindex2(t)),2)= ClassDataDS2(funindex2(t),3);
end

%
% add activities to RunOrderact
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3)>9 && ClassDataDS1(i,3)<18
    RunOrderact(ClassDataDS1(i,1): ClassDataDS1(i,2),1)=  ClassDataDS1(i,3);
    end
end 

%MS
for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3)>9 && ClassDataDS2(i,3)<18
    RunOrderact(ClassDataDS2(i,1): ClassDataDS2(i,2),2)=  ClassDataDS2(i,3);
    end
end


%add transition to RunOrdertrans
%Rater1
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) ==28
    RunOrdertrans(ClassDataDS1(i,1): ClassDataDS1(i,2),1)=  ClassDataDS1(i,3);
    end
end

%Rater2
for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3)==28
    RunOrdertrans(ClassDataDS2(i,1): ClassDataDS2(i,2),2)=  ClassDataDS2(i,3);
    end
end

%BREAK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% label occluded or sensor removed periods
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) >17 && ClassDataDS1(i,3) <21
    RunOrderact(ClassDataDS1(i,1): ClassDataDS1(i,2),1)= 18;  %original:= ClassDataDS1(i,3);
    end
end 


for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3) >17 && ClassDataDS2(i,3) <21
    RunOrderact(ClassDataDS2(i,1): ClassDataDS2(i,2),2)= 18;
    end
end

for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) >17 && ClassDataDS1(i,3) <21
    RunOrderpos(ClassDataDS1(i,1): ClassDataDS1(i,2),1)= 18;
    end
end 

for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3) >17 && ClassDataDS2(i,3) <21
    RunOrderpos(ClassDataDS2(i,1): ClassDataDS2(i,2),2)= 18;
    end
end

for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) >17 && ClassDataDS1(i,3) <21
    RunOrderfun(ClassDataDS1(i,1): ClassDataDS1(i,2),1)= 18;
    end
end 

for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3) >17 && ClassDataDS2(i,3) <21
    RunOrderfun(ClassDataDS2(i,1): ClassDataDS2(i,2),2)= 18;
    end
end

% 
%Locate disagreement between two raters for plotting figures
% RunOrderpos = RunOrderpos(all(RunOrderpos(:,1:2),2),:);
RunOrderpos(:,3)=RunOrderpos(:,1)~=RunOrderpos(:,2);

% RunOrderfun = RunOrderfun(all(RunOrderfun(:,1:2),2),:);
RunOrderfun(:,3)=RunOrderfun(:,1)~=RunOrderfun(:,2);

% RunOrderact = RunOrderact(all(RunOrderact(:,1:2),2),:);
RunOrderact(:,3)=RunOrderact(:,1)~=RunOrderact(:,2);

% RunOrdertrans = RunOrdertrans(all(RunOrdertrans(:,1:2),2),:);
RunOrdertrans(:,3)=RunOrdertrans(:,1)~=RunOrdertrans(:,2);


mat_pos_score_XsensC(n).name = Patient;
mat_pos_score_XsensC(n).lyingbed = sum(RunOrderpos(:,1) == 1);
mat_pos_score_XsensC(n).sittingbed = sum(RunOrderpos(:,1) == 2);
mat_pos_score_XsensC(n).sittingchair = sum(RunOrderpos(:,1) == 3);
mat_pos_score_XsensC(n).standing = sum(RunOrderpos(:,1) == 4);
mat_pos_score_XsensC(n).walking = sum(RunOrderpos(:,1) == 5);
mat_pos_score_XsensC(n).notask = sum(RunOrderpos(:,1) == 0);

%clear current workspace
clear ClassDataDS* fn* funindex* i max1 max2 raters Patient maxfinal minfinal RunOrder* k

%Re-initialise with path details
pathEY ='D:\Box Sync\Box Sync\Elton Shared\All task classifications (E.Y.) V3\';
pathMA ='D:\Box Sync\Box Sync\Elton Shared\All task classifications (M.A.) V3\';
pathTW ='D:\Box Sync\Box Sync\Elton Shared\Natural Xsens classifications (T.W.) V3 csvformat\';

%load list of files in each rater's folder for data extraction
fileIDsEY =dir(strcat(pathEY,'*.csv'));
fileIDsEY = struct2cell(fileIDsEY)';
fileIDsEY(:,[2:6]) = [];

fileIDsMA =dir(strcat(pathMA,'*.csv'));
fileIDsMA = struct2cell(fileIDsMA)';
fileIDsMA(:,[2:6]) = [];

fileIDsTW = [dir(strcat(pathTW,'*.csv')); dir(strcat(pathTW,'*.xlsx'))];
fileIDsTW = struct2cell(fileIDsTW)';
fileIDsTW(:,[2:6]) = [];

end

%normalize the score for comparison
m=18; 
for n = 1:m
x = sum([mat_pos_score_XsensC(n).lyingbed mat_pos_score_XsensC(n).sittingbed mat_pos_score_XsensC(n).sittingchair mat_pos_score_XsensC(n).standing mat_pos_score_XsensC(n).walking mat_pos_score_XsensC(n).notask])
mat_pos_score_XsensC(n).lyingbed = mat_pos_score_XsensC(n).lyingbed ./x
mat_pos_score_XsensC(n).sittingbed = mat_pos_score_XsensC(n).sittingbed ./x
mat_pos_score_XsensC(n).sittingchair = mat_pos_score_XsensC(n).sittingchair ./x
mat_pos_score_XsensC(n).standing = mat_pos_score_XsensC(n).standing ./x
mat_pos_score_XsensC(n).walking = mat_pos_score_XsensC(n).walking ./x
mat_pos_score_XsensC(n).notask = mat_pos_score_XsensC(n).notask ./x
end 


clear RunOrder* k m t n maxfinal minfinal m maxfinal minfinal 

%% Repeat for Apple 
%Predefine number of subjects for the analysis
m = 9

%Change MA pathname for apple
pathMA ='D:\Box Sync\Box Sync\Elton Shared\All task classifications (M.A.) V3\Renamed Apple\';
%Redirect to new apple MA folder 
fileIDsMA =dir(strcat(pathMA,'*.csv'));
fileIDsMA = struct2cell(fileIDsMA)';
fileIDsMA(:,[2:6]) = [];


% Automatically generate and save annotation and confusion matrix in a loop  - APPLE GROUP
%initialise loop
c=1  %data we are looking for: 1 = xsens natural; 2 = xsens control 3 = apple
for n = 1:m   %patient number, manually insert number of patient selected here.

disp(patientnumber_Apple(n))
Patient = char(patientnumber_Apple(n));

idx1 = contains(fileIDsEY, patientnumber_Apple(n));
rownum1 = find(idx1,1,'last');

idx2 = contains(fileIDsMA, patientnumber_Apple(n));
rownum2 = find(idx2,1,'last');

idx3 = contains(fileIDsTW, patientnumber_Apple(n));
rownum3 = find(idx3,1,'last');

%direct pathname and file directory and display raters' initials
if isempty(rownum1) == 1,
    raters = 'TW&MA'
    pn1 = pathTW;
     else pn1 = pathEY;
    raters = 'EY&MA'
end
     pn2 = pathMA;
    
%define filename in preparation for loading in following steps
if raters == 'TW&MA'
    fn1 = char(fileIDsTW(rownum3));
else fn1 = char(fileIDsEY(rownum1));
end
     fn2 = char(fileIDsMA(rownum2));
     
%break here!!!!!!!!!!!!!!!!!!
%load rater 1's rating
F1 = pwd;

cd(pn1)
fprintf('CHOSEN FOLDER No.1: %s\n', pn1)
fprintf('\tReading: ');
rawClassData1 = readtable(fn1);
fprintf('%s [%d x %d] & ', fn1);

%load rater 2's rating
cd(pn2)
fprintf('\nCHOSEN FOLDER No.2: %s\n', pn2)
fprintf('\tReading: ');
rawClassData2 = readtable(fn2);
fprintf('%s [%d x %d] & ', fn2);

cd(F1)

clear pathEY pathMA pathTW idx1 idx2 idx3 pn1 pn2 rownum1 rownum2 rownum3 fileIDs*

% data preparation    BREAK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%rater1
ClassData1 = rawClassData1(:,[7 11 12]);
ClassData1 =table2array(ClassData1);
%rater2
ClassData2 = rawClassData2(:,[7 11 12]);
ClassData2 =table2array(ClassData2);

%Convert Rater 1 annotation seconds into DeciSeconds (this is to preserve those classifications that start and end within same second)
ClassDataDS1=[ClassData1(:,[2 3])*10 ClassData1(:,1) zeros(length(ClassData1),1)];

%Convert Rater 2 annotation seconds into DeciSeconds (this is to preserve those classifications that start and end within same second)
ClassDataDS2=[ClassData2(:,[2 3])*10 ClassData2(:,1) zeros(length(ClassData2),1)];

clear rawClassData1 rawClassData2 ClassData1 ClassData2 pn1 pn2 F1

%Correct for NPT unsync
%ClassDataDS2(:,1:2) = ClassDataDS2(:,1:2)-58;

% Generate Running Order of Annotations 
ClassDataDS1 =round(ClassDataDS1); %rater 1
ClassDataDS2 =round(ClassDataDS2); %rater 2

%%remove zero start index from all class files
if ClassDataDS1(1,1) ==0
   ClassDataDS1(1,1)=10;
end 
if ClassDataDS1(2,1) ==0
   ClassDataDS1(2,1)=10;
end 
if ClassDataDS2(1,1)==0
    ClassDataDS2(1,1)=10;
end 
if ClassDataDS2(2,1)==0
    ClassDataDS2(2,1)=10;
end 

% cut classification files same size
max1 =max(ClassDataDS1(:,2)); %find last annotation rater 1
max2 =max(ClassDataDS2(:,2)); %find last annotation rater 2

minfinal = min(max1,max2); %find where to cut annotation files
maxfinal = max(max1,max2);


% Writing into RunOrder format   %BREAKHERE!!!!!!!!!!!!!!!!
%add postures to RunOrderpos
%rater 1
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3)<6
    RunOrderpos(ClassDataDS1(i,1): ClassDataDS1(i,2),1)=  ClassDataDS1(i,3);
    end
end 

%rater 2
for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3)<6
    RunOrderpos(ClassDataDS2(i,1): ClassDataDS2(i,2),2)=  ClassDataDS2(i,3);
    end
end 

%add functional to RunOrderfun
%rater 1
funindex1 =find(ClassDataDS1(:,3)==6 | ClassDataDS1(:,3)==8 ...
        | ClassDataDS1(:,3)==9 | ClassDataDS1(:,3)==27 | ClassDataDS1(:,3)==22 ...
        | ClassDataDS1(:,3)==23 | ClassDataDS1(:,3)==26 | ClassDataDS1(:,3)==24);
funindex1 =[1;funindex1];

for k =1:length(funindex1)-1
    t=k+1;
    RunOrderfun(ClassDataDS1(funindex1(k)):ClassDataDS1(funindex1(t)),1)= ClassDataDS1(funindex1(t),3);
end

%rater 2
funindex2 =find(ClassDataDS2(:,3)==6 | ClassDataDS2(:,3)==8 ...
        | ClassDataDS2(:,3)==9 | ClassDataDS2(:,3)==27 | ClassDataDS2(:,3)==22 ...
        | ClassDataDS2(:,3)==23 | ClassDataDS2(:,3)==26 | ClassDataDS2(:,3)==24);
funindex2 =[1;funindex2];
    
for k =1:length(funindex2)-1
    t=k+1;
    RunOrderfun(ClassDataDS2(funindex2(k)):ClassDataDS2(funindex2(t)),2)= ClassDataDS2(funindex2(t),3);
end

%
% add activities to RunOrderact
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3)>9 && ClassDataDS1(i,3)<18
    RunOrderact(ClassDataDS1(i,1): ClassDataDS1(i,2),1)=  ClassDataDS1(i,3);
    end
end 

%MS
for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3)>9 && ClassDataDS2(i,3)<18
    RunOrderact(ClassDataDS2(i,1): ClassDataDS2(i,2),2)=  ClassDataDS2(i,3);
    end
end


%add transition to RunOrdertrans
% %Rater1
% for i=1:length(ClassDataDS1)
%     if ClassDataDS1(i,3) ==28
%     RunOrdertrans(ClassDataDS1(i,1): ClassDataDS1(i,2),1)=  ClassDataDS1(i,3);
%     end
% end
% 
% %Rater2
% for i=1:length(ClassDataDS2)
%     if ClassDataDS2(i,3)==28
%     RunOrdertrans(ClassDataDS2(i,1): ClassDataDS2(i,2),2)=  ClassDataDS2(i,3);
%     end
% end

%BREAK HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% label occluded or sensor removed periods
for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) >17 && ClassDataDS1(i,3) <21
    RunOrderact(ClassDataDS1(i,1): ClassDataDS1(i,2),1)= 18;  %original:= ClassDataDS1(i,3);
    end
end 


for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3) >17 && ClassDataDS2(i,3) <21
    RunOrderact(ClassDataDS2(i,1): ClassDataDS2(i,2),2)= 18;
    end
end

for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) >17 && ClassDataDS1(i,3) <21
    RunOrderpos(ClassDataDS1(i,1): ClassDataDS1(i,2),1)= 18;
    end
end 

for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3) >17 && ClassDataDS2(i,3) <21
    RunOrderpos(ClassDataDS2(i,1): ClassDataDS2(i,2),2)= 18;
    end
end

for i=1:length(ClassDataDS1)
    if ClassDataDS1(i,3) >17 && ClassDataDS1(i,3) <21
    RunOrderfun(ClassDataDS1(i,1): ClassDataDS1(i,2),1)= 18;
    end
end 

for i=1:length(ClassDataDS2)
    if ClassDataDS2(i,3) >17 && ClassDataDS2(i,3) <21
    RunOrderfun(ClassDataDS2(i,1): ClassDataDS2(i,2),2)= 18;
    end
end



%Locate disagreement between two raters for plotting figures
% RunOrderpos = RunOrderpos(all(RunOrderpos(:,1:2),2),:);
RunOrderpos(:,3)=RunOrderpos(:,1)~=RunOrderpos(:,2);
%RunOrderpos(1:max2,3)=RunOrderpos(1:max2,1)~=RunOrderpos(1:max2,2);

% RunOrderfun = RunOrderfun(all(RunOrderfun(:,1:2),2),:);
RunOrderfun(:,3)=RunOrderfun(:,1)~=RunOrderfun(:,2);

% RunOrderact = RunOrderact(all(RunOrderact(:,1:2),2),:);
RunOrderact(:,3)=RunOrderact(:,1)~=RunOrderact(:,2);

% % RunOrdertrans = RunOrdertrans(all(RunOrdertrans(:,1:2),2),:);
% RunOrdertrans(1:max2,3)=RunOrdertrans(1:max2,1)~=RunOrdertrans(1:max2,2);


%MODIFICATION HERE 
% Remove occluded rows
RunOrderact(RunOrderact(:,1)==18,:) = [];
RunOrderact(RunOrderact(:,2)==18,:) = [];
RunOrderfun(RunOrderfun(:,1)==18,:) = [];
RunOrderfun(RunOrderfun(:,2)==18,:) = [];
RunOrderpos(RunOrderpos(:,1)==18,:) = [];
RunOrderpos(RunOrderpos(:,2)==18,:) = [];

% Posture preparation
%remove dispute rows, extract only the incidents agreed upon by 2 raters
RunOrderpos(RunOrderpos(:,3)==1,:) = [];
RunOrderact(RunOrderact(:,3)==1,:) = [];
RunOrderfun(RunOrderfun(:,3)==1,:) = [];

% 
% mat_pos_score_Apple(n).name = Patient;
mat_pos_score_Apple(n).lyingbed = sum(RunOrderpos(:,1) == 1);
mat_pos_score_Apple(n).sittingbed = sum(RunOrderpos(:,1) == 2);
mat_pos_score_Apple(n).sittingchair = sum(RunOrderpos(:,1) == 3);
mat_pos_score_Apple(n).standing = sum(RunOrderpos(:,1) == 4);
mat_pos_score_Apple(n).walking = sum(RunOrderpos(:,1) == 5);
mat_pos_score_Apple(n).notask = sum(RunOrderpos(:,1) == 0);

%clear current workspace
clear ClassDataDS* fn* funindex* i max1 max2 raters Patient maxfinal minfinal RunOrder* k

%Re-initialise with path details
pathEY ='D:\Box Sync\Box Sync\Elton Shared\All task classifications (E.Y.) V3\';
pathMA ='D:\Box Sync\Box Sync\Elton Shared\All task classifications (M.A.) V3\Renamed Apple\';
pathTW ='D:\Box Sync\Box Sync\Elton Shared\Natural Xsens classifications (T.W.) V3 csvformat\';

%load list of files in each rater's folder for data extraction
fileIDsEY =dir(strcat(pathEY,'*.csv'));
fileIDsEY = struct2cell(fileIDsEY)';
fileIDsEY(:,[2:6]) = [];

fileIDsMA =dir(strcat(pathMA,'*.csv'));
fileIDsMA = struct2cell(fileIDsMA)';
fileIDsMA(:,[2:6]) = [];

fileIDsTW = [dir(strcat(pathTW,'*.csv')); dir(strcat(pathTW,'*.xlsx'))];
fileIDsTW = struct2cell(fileIDsTW)';
fileIDsTW(:,[2:6]) = [];



end

% m= 9
% for n = 1:m
% x = sum([mat_pos_score_Apple(n).lyingbed mat_pos_score_Apple(n).sittingbed mat_pos_score_Apple(n).sittingchair mat_pos_score_Apple(n).standing mat_pos_score_Apple(n).walking mat_pos_score_Apple(n).notask])
% mat_pos_score_Apple(n).lyingbed = mat_pos_score_Apple(n).lyingbed ./x
% mat_pos_score_Apple(n).sittingbed = mat_pos_score_Apple(n).sittingbed ./x
% mat_pos_score_Apple(n).sittingchair = mat_pos_score_Apple(n).sittingchair ./x
% mat_pos_score_Apple(n).standing = mat_pos_score_Apple(n).standing ./x
% mat_pos_score_Apple(n).walking = mat_pos_score_Apple(n).walking ./x
% mat_pos_score_Apple(n).notask = mat_pos_score_Apple(n).notask ./x
% end 


clear m k n c t
% 

clear RunOrder* maxfinal minfinal 



%% Histogram figures 
%Generate figure displaying distribution
figure(16)
subplot(3,1,1)
hf1 = histfit(ALLRunOrderpos_XsensN(:,1),6,'normal')
title('Xsens Natural Posture Distribution')
xlim([-2 6.5])
hf1(1).FaceAlpha = 0.4
hf1(2).Color = 'blue'

subplot(3,1,2)
hf2 = histfit(ALLRunOrderpos_XsensC(:,1),6,'normal')
title('Xsens Control Posture Distribution')
xlim([-2 6.5])
hf2(1).FaceColor = 'red'
hf2(1).FaceAlpha = hf1(1).FaceAlpha
hf2(2).Color = 'red'

subplot(3,1,3)
hf3 = histfit(ALLRunOrderpos_Apple(:,1),6,'normal')
title('Apple Natural Posture Distribution')
xlim([-2 6.5])
hf3(1).FaceColor = 'green'
hf3(1).FaceAlpha = hf1(1).FaceAlpha
hf3(2).Color = 'green'

figure(17)
hf1 = histfit(ALLRunOrderpos_XsensN(:,1),6,'normal')
title('Posture Distribution - Overview')
xlim([-2 6.5])
hf1(1).FaceAlpha = 0.4
hf1(2).Color = 'blue'

hold on
hf2 = histfit(ALLRunOrderpos_XsensC(:,1),6,'normal')
hf2(1).FaceColor = 'red'
hf2(1).FaceAlpha = hf1(1).FaceAlpha
hf2(2).Color = 'red'

hold on
hf3 = histfit(ALLRunOrderpos_Apple(:,1),6,'normal')
hf3(1).FaceColor = 'green'
hf3(1).FaceAlpha = hf1(1).FaceAlpha
hf3(2).Color = 'green'

legend('Xsens Natural','-','Xsens Control','-','Apple Natural','-')

%% STATS
%import numbers 
mat_pos_score_Apple = struct2table(mat_pos_score_Apple);
mat_pos_score_XsensC = struct2table(mat_pos_score_XsensC);
mat_pos_score_XsensN = struct2table(mat_pos_score_XsensN);

%convert into arrays for statistical comparisons
mx_XsensN = mat_pos_score_XsensN(1:49,2:7);
mx_XsensN = table2array(mx_XsensN);
mx_XsensC = mat_pos_score_XsensC(1:18,2:7);
mx_XsensC = table2array(mx_XsensC);
mx_Apple = mat_pos_score_Apple;
mx_Apple = table2array(mx_Apple);

%Anova within each sensor
[p, anovatab, stats] = anova1(mx_XsensN)
multcompare(stats)
cd('D:\Box Sync\Box Sync\Elton Shared\KappaFigures\STAT\WIthin Sensors')
table = array2table(ans);
% writetable(table,'multiplecomparison_XsensN.xlsx');

[p, anovatab, stats] = anova1(mx_XsensC)
multcompare(stats)
cd('D:\Box Sync\Box Sync\Elton Shared\KappaFigures\STAT\WIthin Sensors')
table = array2table(ans);
% writetable(table,'multiplecomparison_XsensC.xlsx');

[p, anovatab, stats] = anova1(mx_Apple)
figure()
multcompare(stats)
table = array2table(ans);
% writetable(table,'multiplecomparison_Apple - Full Length.xlsx');





%% OLD FIGURES (CM)
% 
% %generate confusion matrix for posture, functional, and activities
figure(1)
ALLRunOrderpos_XsensN(ALLRunOrderpos_XsensN ==0)=99;  %label non-rated packages as 99 for cm
cm =confusionchart(ALLRunOrderpos_XsensN(:,1),ALLRunOrderpos_XsensN(:,2));
% cm.Normalization = 'total-normalized';
cm.XLabel = 'Rater 1';
cm.YLabel = 'Rater 2';
cm.Title =  'Xsens Natural Summated CM Postures';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
cmpos_XsensN = cm.NormalizedValues;
%
figure(2)
ALLRunOrderfun_XsensN(ALLRunOrderfun_XsensN ==0)=99;  %label non-rated packages as 99 for cm
cm =confusionchart(ALLRunOrderfun_XsensN(:,1),ALLRunOrderfun_XsensN(:,2));
cm.Normalization = 'total-normalized';
cm.XLabel = 'Rater 1';
cm.YLabel = 'Rater 2';
cm.Title = 'Xsens Natural Summated CM Functional';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
cmfun_XsensN = cm.NormalizedValues;

figure(3)
ALLRunOrderact_XsensN(ALLRunOrderact_XsensN ==0)=99;  %label non-rated packages as 99 for cm
cm =confusionchart(ALLRunOrderact_XsensN(:,1),ALLRunOrderact_XsensN(:,2));
cm.Normalization = 'total-normalized';
cm.XLabel = 'Rater 1';
cm.YLabel = 'Rater 2';
cm.Title = 'Xsens Natural Summated CM Activities';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
cmact_XsensN = cm.NormalizedValues;
% 

figure(4)
ALLRunOrderpos_XsensC(ALLRunOrderpos_XsensC ==0)=99;  %label non-rated packages as 99 for cm
cm =confusionchart(ALLRunOrderpos_XsensC(:,1),ALLRunOrderpos_XsensC(:,2));
% cm.Normalization = 'total-normalized';
cm.XLabel = 'Rater 1';
cm.YLabel = 'Rater 2';
cm.Title =  'Xsens Controlled Summated CM Postures';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
cmpos_XsensC = cm.NormalizedValues;

figure(5)
ALLRunOrderfun_XsensC(ALLRunOrderfun_XsensC ==0)=99;  %label non-rated packages as 99 for cm
cm =confusionchart(ALLRunOrderfun_XsensC(:,1),ALLRunOrderfun_XsensC(:,2));
cm.Normalization = 'total-normalized';
cm.XLabel = 'Rater 1';
cm.YLabel = 'Rater 2';
cm.Title = 'Xsens Controlled Summated CM Functional';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
cmfun_XsensC = cm.NormalizedValues;

figure(6)
ALLRunOrderact_XsensC(ALLRunOrderact_XsensC ==0)=99;  %label non-rated packages as 99 for cm
cm =confusionchart(ALLRunOrderact_XsensC(:,1),ALLRunOrderact_XsensC(:,2));
cm.Normalization = 'total-normalized';
cm.XLabel = 'Rater 1';
cm.YLabel = 'Rater 2';
cm.Title = 'Xsens Controlled Summated CM Activities';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
cmact_XsensC = cm.NormalizedValues;

figure(7)
ALLRunOrderpos_Apple(ALLRunOrderpos_Apple ==0)=99;  %label non-rated packages as 99 for cm
cm =confusionchart(ALLRunOrderpos_Apple(:,1),ALLRunOrderpos_Apple(:,2));
% cm.Normalization = 'total-normalized';
cm.XLabel = 'Rater 1';
cm.YLabel = 'Rater 2';
cm.Title =  'Apple Summated CM Postures';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
cmpos_Apple = cm.NormalizedValues;

figure(8)
ALLRunOrderfun_Apple(ALLRunOrderfun_Apple==0)=99;  %label non-rated packages as 99 for cm
cm =confusionchart(ALLRunOrderfun_Apple(:,1),ALLRunOrderfun_Apple(:,2));
cm.Normalization = 'total-normalized';
cm.XLabel = 'Rater 1';
cm.YLabel = 'Rater 2';
cm.Title = 'Apple Summated CM Functional';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
cmfun_Apple = cm.NormalizedValues;

figure(9)
ALLRunOrderact_Apple(ALLRunOrderact_Apple ==0)=99;  %label non-rated packages as 99 for cm
cm =confusionchart(ALLRunOrderact_Apple(:,1),ALLRunOrderact_Apple(:,2));
cm.Normalization = 'total-normalized';
cm.XLabel = 'Rater 1';
cm.YLabel = 'Rater 2';
cm.Title = 'Apple Summated CM Activities';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
cmact_Apple = cm.NormalizedValues;

clear pathEY pathMA pathTW fileIDs* cm



