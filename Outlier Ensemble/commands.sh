#!/bin/bash
# Outlier Ensemble

echo "Running the Script"
database=""
username=""
password=""
host=""
echo "Loading data to database"

mysql -u $username -p$password -h $host $database < Features.sql
echo "Generate features"

mysql --user="$username" --password="$password" --database="$database" --host="$host" --execute="alter table  features add column Novel_Code_Rev int; alter table  features add column Novel_Code_DRev int; alter table  features add column Novel_Code_RevRatio float; update features inner join (select  code,count(*) t1, count(distinct text_review) t2, count(distinct text_review)/count(*) t3 from features group by code ) as t on features.code = t.code set Novel_Code_Rev = t1, Novel_Code_DRev = t2,Novel_Code_RevRatio=t3;"

mysql --user="$username" --password="$password" --database="$database" --host="$host" --execute="alter table  features add column App_Dev_Reviews int; alter table  features add column App_Dev_Apps int; alter table  features add column App_Dev_DCode_Per_Reviews float; update features inner join (select  dev,count(*) t1, count(distinct appid) t2 ,count(distinct code)/count(*) t3 from features group by dev ) as t on features.dev = t.dev set App_Dev_Reviews = t1, App_Dev_Apps = t2,App_Dev_DCode_Per_Reviews=t3; "


mysql --user="$username" --password="$password" --database="$database" --host="$host" --execute="create table App_features as  select appid as App_ID, count(*) as App_Reviews, count(distinct userid) as App_DUsers ,  count(distinct code) as App_DCode, count(distinct ReferredApp) as App_DRefferedApps , count(distinct userid)/count(userid) as App_DistinctUser,   count(distinct ReferredApp)/ count(ReferredApp) as App_DRefferedApps_per_RefferedApps, count(code) , count(userid) as App_Users,count(ReferredApp) as App_ReferredApps, count(distinct code)/count(*) as App_DCode_Per_Review, count(distinct ReferredApp)/count(*) as App_DRefferedApps_Per_Rev, count(distinct userid)/count(*) as App_DUser_Per_Rev , count(distinct ReferredApp)/ count(distinct userid) as App_DReferredApp_Per_DUser,  count(distinct code)/ count(distinct userid) as App_Code_Per_DUser ,avg(title_Length) as App_Avg_Title_length, avg(Body_Length) as App_Avg_Body_length, avg(rating) as App_Avg_Rating, std(title_Length) as App_Std_Title_length, std(Body_Length) as App_Std_Body_length, std(rating) as App_Std_Rating, App_Dev_Reviews , App_Dev_Apps ,App_Dev_DCode_Per_Reviews from features where appid <>''  group by appid ;"
mysql --user="$username" --password="$password" --database="$database" --host="$host" --execute=" create table User_features as select  userid as User_ID, count(*) as User_Reviews, count(distinct appid) as User_DApps,  count(distinct code) as User_DCodes, count(distinct ReferredApp) as User_DReferredApps, count(distinct dev) as User_DDev , count(distinct ReferredApp)/ count(ReferredApp) as User_DReferredApps_Per_ReferredApps, count(appid) as User_Apps,  count(code) as User_Codes , count(ReferredApp) as User_ReferredApps, count(dev) as User_Dev , count(distinct appid)/count(*) as User_DApp_Per_Rev,  count(distinct code)/count(*) as User_DCode_Per_Rev, count(distinct ReferredApp)/count(*) as User_DReferredApps_Per_Rev, count(distinct dev)/count(*) as User_DDev_Per_Rev, count(distinct dev)/ count(distinct appid) as User_DDev_Per_DApps, count(distinct ReferredApp)/ count(distinct appid) as User_DReferredApp_Per_DApps,  count(distinct dev)/ count(distinct ReferredApp) as User_DDev_Per_DReferredApps , max(date_in_days)-min(date_in_days) as User_Days ,avg(title_Length) as User_Avg_Title_Length, avg(Body_Length) as User_Avg_Body_length, avg(rating) as User_Avg_Rating,std(title_Length) as User_Std_Title_Length, std(Body_Length) as User_Std_Body_Length , std(rating) as User_Std_Rating_Length from features where userid <>''  group by userid;"
mysql --user="$username" --password="$password" --database="$database" --host="$host" --execute=" create table RevGiven_features as select text_review as Rev_Text, userid as User_ID, appid as App_ID , rating as Rev_Rating, length(text_review)-1 as Rev_LenText, date_in_days as Rev_Date,   title_Length as Rev_LenTitle , Body_Length as Rev_LenBody from features ; "
mysql --user="$username" --password="$password" --database="$database" --host="$host" --execute="create table RevNovel_features as select text_review as Novel_Text, userid as User_ID, appid as App_ID, referredApp, avg(rating) as Novel_Avg_Rating, std(rating) as Novel_Std_Rating, length(text_review)-1 as Novel_Text_Length, count(distinct date_in_days) as Novel_DDays ,  count(distinct date_in_days)/count(*) as Novel_Days_Per_Rev,  title_Length as Novel_Title_Length , Body_Length as Novel_Body_Length , count(*) as Novel_Revs, count(distinct appid) as Novel_DistinctApps, count(distinct appid)/count(*) as Novel_DApps_Per_Rev, count(userid) as Novel_Users, count(distinct userid) as Novel_DUsers, count(distinct userid)/ count(*) as Novel_DUser_Per_Rev, count(distinct dev) as Novel_DDev, count(distinct dev)/count(*) as Novel_DDev_Per_Rev, count(distinct code) as Novel_DCodes, count(distinct code)/ count(*) as Novel_DCodes_Per_Rev, count(ReferredApp) as Novel_ReferredApps, count(distinct ReferredApp) as Novel_DReferredApps,  count(distinct ReferredApp)/ count(*) as Novel_DReferredApps_Per_Rev, Novel_Code_Rev, Novel_Code_DRev ,Novel_Code_RevRatio from features group by text_review ;"

mysql --user="$username" --password="$password" --database="$database" --host="$host" -e"select * from App_features" > "$PWD/Apps.csv"
mysql --user="$username" --password="$password" --database="$database" --host="$host" -e"select * from User_features" > "$PWD/User.csv"
mysql --user="$username" --password="$password" --database="$database" --host="$host" -e"select * from RevGiven_features" > "$PWD/RevGiven.csv"
mysql --user="$username" --password="$password" --database="$database" --host="$host" -e"select * from RevNovel_features" > "$PWD/RevNovel.csv"



matlab -r "preprocessing; exit"
echo "Finding Anomalous scores for each entity using Comprex"
cd CompreX_12_tbox
chmod +x run.bash
chmod +x NML_histogram
./run.bash
cd ..

echo "Finding top 400 outliers using Ensembling method and Report Accuracy"
matlab -r "TopOutliersRev; ComputeAccuracy; exit"




