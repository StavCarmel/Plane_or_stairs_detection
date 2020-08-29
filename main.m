num_feat=10; % the amount of features. change if needed
cd 'C:\MATLAB\project'; % the folder you are working from
pathname = 'C:\MATLAB\project';
fileList = dir('*.csv*');
numberOfFiles = length(fileList);
count=0;

% parameters for the loop:
filetype='csv';
window=10; %[sec]
overlap=0; %[sec]
amount_par=4; %the amount of parameters
signaltime=60; %sec
f_A=50; %[Hz] 
f_G=50; %[Hz]
f_P= round(0.99); %[Hz]
f_T= 1; %[sec]

feature_mat=[];
for filenum= 1:amount_par:numberOfFiles
    filenum
    isfirst=1;
    A=[];G=[];P=[];T=[];
    for row=1:window:signaltime-window %change
        feature_vec=[];
        if isfirst==1
            [vec_A,vec_G,vec_P,vec_T,label,A,G,P,T] = load_data(pathname,filetype,window,filenum,row,f_A,f_G,f_P,f_T,isfirst,A,G,P,T);
        else
            [vec_A,vec_G,vec_P,vec_T,label,~,~,~,~] = load_data(pathname,filetype,window,filenum,row,f_A,f_G,f_P,f_T,isfirst,A,G,P,T);    
        end
        isfirst=0;        
       
        %creating the features for one window:
        wind_mat={vec_A,vec_G,vec_P,vec_T}; % cell because the vectors doesn't have the same length
        feature_vec=Extract_Features(wind_mat,label,50,50,0.99,1);
        count=count+1;
        feature_mat(count,:)=feature_vec;
        labels(count,1)=label;        
    end
end

%features normalization
min_vec=min(feature_mat);
max_vec=max(feature_mat);
range_vec=max_vec-min_vec;
feature_mat=(feature_mat-min_vec)./range_vec;

% compliting the missing values:
trans_feature_mat_complete=knnimpute(feature_mat',3); 
feature_mat_complete=trans_feature_mat_complete';

%shuffling
accuracy_val=[];
accuracy_test=[];
max_feat_vec=[];
for iter=1:100
    am_w=length(feature_mat_complete)/(numberOfFiles/4); %amount windows
    ind_vec=1:am_w:length(feature_mat_complete);
    shuffle_ind=ind_vec(randperm(length(ind_vec)));
    shuffle_vec=[];
    for i=1:length(shuffle_ind)
        shuffle_vec=[shuffle_vec shuffle_ind(i):shuffle_ind(i)+am_w-1];
    end
      
    shuffle_feature_mat_complete=feature_mat_complete(shuffle_vec,:);
    shuffle_labels=labels(shuffle_vec);
    [trainInd,valInd,testInd]=divideblock(length(feature_mat_complete),0.6,0.2,0.2);

    %featuer deviding
    X_train=shuffle_feature_mat_complete(trainInd,:);

    %label deviding
    Y_train=shuffle_labels(trainInd,:);
    if length(unique(Y_train))<3 % means that the train set doesn't include all three labels
        break
    end
    
    %find max correlation between features, be sure it's less than 0.7,
    %else change feature
    feat_feat_corr=corr(X_train);
    feat_feat_corr=feat_feat_corr-eye(num_feat);
    max_feat=max(abs(feat_feat_corr(:)));
    disp(['Maximum correlation between features is: ',num2str(max_feat)])
    max_feat_vec=[max_feat_vec,max_feat];
    
    %find the wheits of influence of the features and take the top best 6
    k=3;
    [idx_feature, ~]=relieff(X_train,Y_train,k);
    X_train=X_train(:,idx_feature(1:6));

    best_6_features=idx_feature(1:6);
    disp(['Best 6 features columns indices are: ',num2str(best_6_features)]);

    %featuer deviding
    X_test=shuffle_feature_mat_complete(testInd,best_6_features);
    X_val=shuffle_feature_mat_complete(valInd,best_6_features);

    %label deviding
    Y_test=shuffle_labels(testInd,:);
    Y_val=shuffle_labels(valInd,:);

    %creating the model
    splits=4;
    model_tree=fitctree(X_train,Y_train,'MaxNumSplits',splits);
    % view(model_tree,'Mode','graph')

    % Performance estimation: 
    CV_pred = predict(model_tree, X_val); %Predict labels using classification tree
    Tree_perf = classperf(Y_val, CV_pred); %Evaluate classifier performance
    tree_acc_val = Tree_perf.CorrectRate  ;
    disp(['Decision Tree accuracy: ', num2str(tree_acc_val)])

    CV_pred = predict(model_tree, X_test); %Predict labels using classification tree
    Tree_perf = classperf(Y_test, CV_pred); %Evaluate classifier performance
    tree_acc_test = Tree_perf.CorrectRate  ;
    disp(['Decision Tree accuracy: ', num2str(tree_acc_test)])
    
    accuracy_val=[accuracy_val,tree_acc_val];
    accuracy_test=[accuracy_test,tree_acc_test];
end

mean_accuracy_val=mean(accuracy_val);
mean_accuracy_test=mean(accuracy_test);
max_feat_corr=max(max_feat_vec);
mean(max_feat_vec)
