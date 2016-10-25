clf
clearvars

%% read data

load('variable.mat')
appscores = load([pwd , '\CompreX_12_tbox\CT_apps10nmlbinsVar_avg.mat_scores.mat']);
appscores = appscores.scores;
userscores = load([pwd , '\CompreX_12_tbox\CT_users10nmlbinsVar_avg.mat_scores.mat']);
userscores = userscores.scores;
RevGivenscores = load([pwd , '\CompreX_12_tbox\CT_givenRevs10nmlbinsVar_avg.mat_scores.mat']);
RevGivenscores = RevGivenscores.scores;
RevNovelscores = load([pwd , '\CompreX_12_tbox\CT_novelRevs10nmlbinsVar_avg.mat_scores.mat']);
RevNovelscores = RevNovelscores.scores;


%% sort scores four lists
[val_RevGiven indx_RevGiven]= sort(RevGivenscores,'descend');
[val_RevNovel indx_RevNovel]= sort(RevNovelscores,'descend');
[val_app indx_app]= sort(appscores,'descend');
[val_user indx_user]= sort(userscores,'descend');


%%  Perfect Agreement

threshold = 2;
badGivenT=[];
badNovelT=[];
kT=[];


for k =1:400
    k
    topRevGiven = RevGiven(indx_RevGiven(1:k),:);
    topRevNovel = RevNovel(indx_RevNovel(1:k),:);
    topapp = apps(indx_app(1:k),:);
    topuser = users(indx_user(1:k),:);

    badindiv = 0;
    badboth = 0;
    for i =1:size(topRevGiven,1)
        if (any(strcmp(topuser,topRevGiven(i,2) )) + any([any(strcmp(topapp, topRevGiven{i,3}))  any(strcmp(topapp, topRevGiven{i,3}))])) >= threshold
            badindiv=badindiv+1;
        end
         if (any(strcmp(topuser,topRevNovel(i,2) )) + any([any(strcmp(topapp, topRevNovel{i,4})) any(strcmp(topapp, topRevNovel{i,3})) ]) ) >= threshold
            badboth=badboth+1;
         end
    end
    
    badGivenT = [badGivenT badindiv];
    badNovelT = [badNovelT badboth];
    kT=[kT k];
    

end
f = figure()
plot(kT,badGivenT,'r')
hold on 
plot(kT,badNovelT,'b')

hold on
%% Partial Agreement


threshold = 1;
badGivenT=[];
badNovelT=[];
kT=[];


for k =1:400
    k
    topRevGiven = RevGiven(indx_RevGiven(1:k),:);
    topRevNovel = RevNovel(indx_RevNovel(1:k),:);
    topapp = apps(indx_app(1:k),:);
    topuser = users(indx_user(1:k),:);

    badindiv = 0;
    badboth = 0;
    for i =1:size(topRevGiven,1)
        if (any(strcmp(topuser,topRevGiven(i,2) )) + any([any(strcmp(topapp, topRevGiven{i,3}))  any(strcmp(topapp, topRevGiven{i,3}))])) >= threshold
            badindiv=badindiv+1;
        end
         if (any(strcmp(topuser,topRevNovel(i,2) )) + any([any(strcmp(topapp, topRevNovel{i,4})) any(strcmp(topapp, topRevNovel{i,3})) ]) ) >= threshold
            badboth=badboth+1;
         end
    end
    
    badGivenT = [badGivenT badindiv];
    badNovelT = [badNovelT badboth];
    kT=[kT k];
    

end

plot(kT,badGivenT,'y')
hold on 
plot(kT,badNovelT,'c')

ylabel({'Number of Reviews'});
xlabel({'k-Top Outliers from the Three Lists of Outliers'});
% Create legend
legend1 = legend('Perfect Agreement - Given Features','Perfect Agreement - Novel Features','Partial Agreement - Given Features','Partial Agreement - Novel Features')
set(legend1,...
    'Position',[0.272270898901101 0.688212099849847 0.259624870514234 0.218813900079708]);
saveas(f,'Perfect vs Partial Agreement.jpeg')