clf
clearvars

%% declare data
load('judgement.mat');
    precision_and = []
    precision_or = []
    recall_and = []
    recall_or= []

%% lopp over ourliers reviews
for k=50:50:400

    rev = review4001 ;
    m_and_P = 0;
    m_and_R = 0;
    m_or_P = 0;
    m_or_R = 0;
    n_and_P = 0;
    n_and_R = 0;
    n_or_P = 0;
    n_or_R = 0;


    rev = rev(1:k,:);
    for i =1:size(rev,1)
        if (rev(i,3) <= k && (rev(i,4) <= k || rev(i,5) <= k))
            rev(i,7)=1;
        else 
            rev(i,7)=0;
        end

        if (rev(i,3) <= k || (rev(i,4) <= k || rev(i,5) <= k))
            rev(i,8)=1;
        else 
            rev(i,8)=0;
        end
    end
    Tand = sum(rev(:,7));
    Tor = sum(rev(:,8));

    for i=1:size(rev,1)
        % and
        if rev(i,7) == 1 && rev(i,6) == 1 %precision
            n_and_P = n_and_P +1;
        end
        if rev(i,7) == 0 && rev(i,6) == 0 %recall
            n_and_R = n_and_R +1;
        end

        if rev(i,7) == 1 && rev(i,1) == 1 %precision
            m_and_P = m_and_P +1;
        end
        if rev(i,7) == 0 && rev(i,1) == 0 %recall
            m_and_R = m_and_R +1;
        end

        %or
        if rev(i,8) == 1 && rev(i,6) == 1 %precision
            n_or_P = n_or_P +1;
        end
        if rev(i,8) == 0 && rev(i,6) == 0 %recall
            n_or_R = n_or_R +1;
        end

        if rev(i,8) == 1 && rev(i,1) == 1 %precision
            m_or_P = m_or_P +1;
        end
        if rev(i,8) == 0 && rev(i,1) == 0 %recall
            m_or_R = m_or_R +1;
        end
    end

    %% compute recall and precision
    m_and_P = m_and_P/Tand;
    m_and_R = m_and_R/(k-Tand);
    m_or_P = m_or_P/Tor;
    m_or_R = m_or_R/(k-Tor);
    n_and_P = n_and_P/Tand;
    n_and_R = n_and_R/(k-Tand);
    n_or_P = n_or_P/Tor;
    n_or_R = n_or_R/(k-Tor);

%     precision_and = ( m_and_P+n_and_P)/2
%     precision_or =  (m_or_P+n_or_P)/2
%     recall_and = (m_and_R+n_and_R)/2
%     recall_or= (n_or_R+m_or_R)/2
    
    
    precision_and =[ precision_and ( m_and_P+n_and_P)/2]
    precision_or = [precision_or (m_or_P+n_or_P)/2]
    recall_and = [recall_and (m_and_R+n_and_R)/2]
    recall_or= [ recall_or (n_or_R+m_or_R)/2]

end

%% plot
f = figure
plot(precision_and,'r')
hold on
plot(precision_or,'b')
hold on
plot(recall_and,'k')
hold on
plot(recall_or,'c')
ax = gca;
ax.XTickLabel = (50:50:400);


ylabel({'Percentages'});
xlabel({'k-Top Outlier Reviews'});
% Create legend
legend1 = legend('Perfect Agreement - Precision','Partial Agreement - Precision','Perfect Agreement - Recall','Partial Agreement - Recall')
set(legend1,...
    'Position',[0.427976196809182 0.128688290326037 0.469642846126641 0.218813900079708]);

saveas(f,'Accuracy.jpeg')
