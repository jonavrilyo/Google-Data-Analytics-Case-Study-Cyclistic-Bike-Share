# Google Data Analytics Capstone Project   
## Cyclistic Bike-Share Analysis: Converting Casual Riders into Members
I am a junior data analyst working for Cyclistic, a fictional company based on the Divvy bike-share system in Chicago. My task is to identify the differences between casual riders and members and use my analysis to formulate recommendations that could help motivate casual riders to become members.
## Tools Used
Excel, DAX Studio, and RStudio
## Ask Phase
- Understand both the business question(s) and task.
- Questions:
  - What are the differences between casual riders and members?
  - Why should casual riders commit to a membership?
  - How can digital media influence casual riders in considering a membership?
- Identify stakeholders:
  - Lily Moreno, director of marketing
  - Cyclistic marketing analytics team
  - Cyclistic executive team
- **Business task**: Maximize the number of annual memberships by converting casual riders into members.
## Prepare Phase
- Downloaded the previous 12 months of Cyclistic trip data, in this case, all of 2023. Each month has its dedicated CSV file.
- The data is reliable, original, current, and cited.
- The data is open under a [license](https://divvybikes.com/data-license-agreement) made available by Motivate International Inc.
- I used Notepad ++ to quickly inspect each file and determine any initial issues.
  - 10 of the 12 CSV files used text qualifiers, although this appeared to be unnecessary.
## Process Phase
- I used Excel Power Query to transform and combine the 12 months of data.
- To avoid the limitations of Excel, the dataset was loaded into the data model as a connection. Then, using DAX Studio—which detects the data model—to export the dataset as a new CSV file named *'cyclistic_full_year.csv.'*
- Further data manipulation and cleaning were done in R Studio. Please see the [Markdown](https://github.com/jonavrilyo/Google-Data-Analytics-Case-Study-Cyclistic-Bike-Share/blob/main/cyclistic_2023.md) file.
## Key Findings
- Although the number of members nearly doubles that of casual riders, the total ride length between the two groups isn’t as significant as expected.
- Casual riders had a much longer average ride length than members, which helps explain the rather close difference in the total ride length.
  - Casual riders using classic bikes had an average ride length twice as long as that of members using classic bikes.
  - Day passes provide casual riders with unlimited 3-hour classic bike rides within a 24-hour period, which helps explain the large discrepancy.
- Casual riders were more active during quarters 2 and 3 of 2023.
  - Casual riders were more active on the weekends, possibly committing their time to leisure or exercise.
## Top Recommendations
- Allocate resources towards increasing marketing campaigns to convert casual riders into members during the spring and summer months.
- After every unlock and dock of a bike at a top starting and ending station, post an ad within the app highlighting the membership and its benefits.
- Earn points towards an annual membership by allowing casual riders to complete certain tasks every weekend. Similar to the “Bike Angels” perk, casual riders can find opportunities to help them purchase a membership.
- Add a second-tier membership, where riders have an hour free with classic bikes, rather than just 45 minutes. This may entice casual riders who regularly use day passes to consider a membership that meets their daily needs.
- Use TikTok and YouTube shorts to highlight the benefits of memberships quickly. In addition, allow content creators to provide discount codes and free trials. 

