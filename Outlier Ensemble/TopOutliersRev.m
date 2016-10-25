
%%read data
load('variable.mat')
appscores = load([pwd , '/CompreX_12_tbox/CT_apps10nmlbinsVar_avg.mat_scores.mat']);
appscores = appscores.scores;
userscores = load([pwd , '/CompreX_12_tbox/CT_users10nmlbinsVar_avg.mat_scores.mat']);
userscores = userscores.scores;
RevGivenscores = load([pwd , '/CompreX_12_tbox/CT_givenRevs10nmlbinsVar_avg.mat_scores.mat']);
RevGivenscores = RevGivenscores.scores;
RevNovelscores = load([pwd , '/CompreX_12_tbox/CT_novelRevs10nmlbinsVar_avg.mat_scores.mat']);
RevNovelscores = RevNovelscores.scores;

%% sort scores four lists
[val_RevGiven indx_RevGiven]= sort(RevGivenscores,'descend');
[val_RevNovel indx_RevNovel]= sort(RevNovelscores,'descend');
[val_app indx_app]= sort(appscores,'descend');
[val_user indx_user]= sort(userscores,'descend');

k = 400;
topRevGiven = RevGiven(indx_RevGiven(1:k),:);
topRevNovel = RevNovel(indx_RevNovel(1:k),:);
topapp = apps(indx_app(1:k),:);
topuser = users(indx_user(1:k),:);

%% Top 400 Outliers Reviews with thier scores

 rev = {'Text Review','Text Review Score', 'User Score' , 'App Score', 'ReferredApp Score' };
 threshold = 2;

badboth = 0;
for i =1:size(topRevNovel,1)
    t = (any(strcmp(topuser,topRevNovel(i,2) )) + any([any(strcmp(topapp, topRevNovel{i,4})) any(strcmp(topapp, topRevNovel{i,3})) ]) );
%     if t >= threshold
%         badboth=badboth+1;
%     end
    if strcmp(topRevNovel(i ,2) ,'')
        u = ' ';
    else
        u = find(indx_user == find(strcmp(users , topRevNovel(i ,2)))) ;
    end
    if strcmp(topRevNovel(i ,3) ,'NULL')
        p = ' ';
    else
        p = find(indx_app == find(strcmp(apps , topRevNovel(i,3))));
    end
    if strcmp(topRevNovel(i ,4) ,'NULL')
        pn = ' ';
    else
        pn = find(indx_app == find(strcmp(apps , topRevNovel(i,4))));
    end
   rev =  [rev; topRevNovel(i,1) i u p pn];

end
var = rev(2:401,2:5);

save('threeListscores400.mat','var'); 
save('Top400Review.mat','rev');
