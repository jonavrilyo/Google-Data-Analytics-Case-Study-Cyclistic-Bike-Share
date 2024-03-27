---
title: "Cyclistic Bike-Share"
subtitle: "The Differences Between Members and Casual Riders"
author: "Jonathan Avril"
date: "2024-03-16"
output: 
  html_document: 
    theme: readable
    keep_md: true
    toc: true
    toc_float: true
---



## Install & Load Packages


```r
install.packages("tidyverse")
install.packages("skimr")
install.packages("here")
install.packages("hms")
```

*tidyverse* for core packages like dplyr and ggplot2 for analysis and visualizations.  
*skimr* for additional summary statistics.  
*here* for easy file referencing.  
*hms* to ease the processes involving date times and duration.  


```r
library(tidyverse)
library(skimr)
library(here)
library(hms)
```

## Import & Inspect CSV

Import the *cyclistic_full_year.csv* file that consists of Cyclistic's trip data in 2023.  
`cyclistic_2023 <- read_csv("cyclistic_full_year.csv")`  




```r
# Data summarization:
skim_without_charts(cyclistic_2023)
```


Table: Data summary

|                         |               |
|:------------------------|:--------------|
|Name                     |cyclistic_2023 |
|Number of rows           |5719877        |
|Number of columns        |7              |
|_______________________  |               |
|Column type frequency:   |               |
|character                |5              |
|POSIXct                  |2              |
|________________________ |               |
|Group variables          |None           |


**Variable type: character**

|skim_variable    | n_missing| complete_rate| min| max| empty| n_unique| whitespace|
|:----------------|---------:|-------------:|---:|---:|-----:|--------:|----------:|
|ride_id          |         0|          1.00|  16|  16|     0|  5719877|          0|
|bike_type        |         0|          1.00|  11|  13|     0|        3|          0|
|starting_station |    875716|          0.85|   3|  64|     0|     1592|          0|
|ending_station   |    929202|          0.84|   3|  64|     0|     1597|          0|
|user_type        |         0|          1.00|   6|   6|     0|        2|          0|


**Variable type: POSIXct**

|skim_variable | n_missing| complete_rate|min                 |max                 |median              | n_unique|
|:-------------|---------:|-------------:|:-------------------|:-------------------|:-------------------|--------:|
|start_time    |         0|             1|2023-01-01 00:01:00 |2023-12-31 23:59:38 |2023-07-20 18:02:50 |  4396985|
|end_time      |         0|             1|2023-01-01 00:02:00 |2024-01-01 23:50:51 |2023-07-20 18:19:47 |  4408323|

## Manipulate

Since Cyclistic is a fictional company based on the Divvy bike share system, Divvy's policy and rules will be used to determine the importance of certain records compared to others.  
This section will also focus on removing data that may be ineffective in the analysis as well as address NA/missing values.  


```r
# Adding ride_length and day_of_week as new columns to help with the analysis.
# The month of January and November had no additional seconds in the start time
# and end time, but the rest did.  As a result, calculating ride_length for the
# month of January and November resulted in no decimal places. However, the
# other months did.  Upon further inspection, the format for datetime in the
# January and November CSV files were not consistent with the rest.  Utilizing
# Power Query beforehand to check and fix data types proved useful.  Using
# as_hms() to return 'hours, minutes, and seconds' as the format for ride
# length.

cyclistic_2023_v2 <- cyclistic_2023 %>%
    mutate(ride_length = as_hms(end_time - start_time), day_of_week = weekdays(start_time)) %>%
    arrange(start_time)  # Adding ride length, day of week, and sorting the data frame by start time
```


```r
# Filter for rows where the ride length is less than or equal to 0 and then
# sort the results in ascending order.  Includes over 200 rows with negative
# time values, which is likely due to incorrect data entry; it appears that the
# end times and start times may have been entered in reverse.  These records
# will be removed.

cyclistic_2023_v2 %>%
    filter(ride_length <= parse_hms("00:00:00")) %>%
    arrange(ride_length)  # 9,213 rows returned
```

```
# A tibble: 9,213 × 9
   ride_id          bike_type     start_time          end_time           
   <chr>            <chr>         <dttm>              <dttm>             
 1 F584D47AE67FD388 classic_bike  2023-11-05 21:08:00 2023-10-25 07:31:00
 2 AE046C379C20B7CA classic_bike  2023-11-05 20:46:00 2023-10-25 07:31:00
 3 A21D6507DA3C5AD4 classic_bike  2023-11-05 16:41:00 2023-10-25 07:31:00
 4 DEC5EF8DE27398A0 classic_bike  2023-11-05 11:56:00 2023-10-25 07:31:00
 5 7850F6E2343BF766 classic_bike  2023-11-01 16:38:00 2023-10-25 07:31:00
 6 5A5DDAFFF234FB69 classic_bike  2023-11-01 14:07:00 2023-10-25 07:31:00
 7 D8D9D4D695F852EA electric_bike 2023-09-01 19:16:25 2023-09-01 17:54:44
 8 8B6E5BA70093AAB7 electric_bike 2023-06-02 19:29:06 2023-06-02 18:28:51
 9 5C5FCC49C148635F classic_bike  2023-11-05 01:55:00 2023-11-05 01:01:00
10 AF517DF24EAE7E4A electric_bike 2023-11-19 20:10:00 2023-11-19 19:16:00
   starting_station                ending_station         user_type ride_length
   <chr>                           <chr>                  <chr>     <time>     
 1 Sheffield Ave & Waveland Ave    <NA>                   casual    -277:37:00 
 2 Sheridan Rd & Irving Park Rd    <NA>                   member    -277:15:00 
 3 Pine Grove Ave & Irving Park Rd <NA>                   member    -273:10:00 
 4 Pine Grove Ave & Irving Park Rd <NA>                   casual    -268:25:00 
 5 Clark St & Drummond Pl          <NA>                   casual    -177:07:00 
 6 Clark St & Drummond Pl          <NA>                   member    -174:36:00 
 7 Elizabeth St & Randolph St      <NA>                   member    - 01:21:41 
 8 <NA>                            Calumet Ave & 18th St  casual    - 01:00:15 
 9 Halsted St & Wrightwood Ave     Halsted St & Roscoe St member    - 00:54:00 
10 Wabash Ave & 9th St             <NA>                   member    - 00:54:00 
   day_of_week
   <chr>      
 1 Sunday     
 2 Sunday     
 3 Sunday     
 4 Sunday     
 5 Wednesday  
 6 Wednesday  
 7 Friday     
 8 Friday     
 9 Sunday     
10 Sunday     
# ℹ 9,203 more rows
```

```r
# Filter for rows where ride length is greater than 0 but less than or equal to
# 1 minute, and starting and ending stations are different.  This is done to
# understand the context of certain trips and if ride length makes sense.
# Google Maps was used to determine the estimated time for certain trips.  Some
# trips that last for a few seconds or less did not match the eye test or come
# close to the time estimates on Google Maps.  Trips that were a minute did
# match the eye test, and the distance made sense. In some cases, the ride
# length could have been less.

cyclistic_2023_v2 %>%
    filter(ride_length >= parse_hms("00:00:00") & ride_length <= parse_hms("00:01:00"),
        starting_station != ending_station) %>%
    arrange(ride_length)  # 6,248 rows returned
```

```
# A tibble: 6,248 × 9
   ride_id          bike_type     start_time          end_time           
   <chr>            <chr>         <dttm>              <dttm>             
 1 73D52AF8598BA131 electric_bike 2023-01-07 23:20:00 2023-01-07 23:20:00
 2 11C1E2D3C6D11456 classic_bike  2023-01-10 17:05:00 2023-01-10 17:05:00
 3 91997358346A2648 electric_bike 2023-01-11 08:36:00 2023-01-11 08:36:00
 4 9FA3BBF522C862D9 classic_bike  2023-01-12 22:33:00 2023-01-12 22:33:00
 5 04DA968DB23CF3F7 classic_bike  2023-01-13 19:05:00 2023-01-13 19:05:00
 6 E03E950E13377FAB electric_bike 2023-01-14 23:23:00 2023-01-14 23:23:00
 7 C2C096F619149346 classic_bike  2023-01-15 16:07:00 2023-01-15 16:07:00
 8 C2282B4E7771E769 electric_bike 2023-01-15 18:18:00 2023-01-15 18:18:00
 9 7A71E7E0B69F0ECD classic_bike  2023-01-16 07:51:00 2023-01-16 07:51:00
10 432D37B2215DE4C4 classic_bike  2023-01-16 20:10:00 2023-01-16 20:10:00
   starting_station              ending_station                          
   <chr>                         <chr>                                   
 1 Southport Ave & Roscoe St     N Southport Ave & W Newport Ave         
 2 Franklin St & Adams St (Temp) Franklin St & Monroe St                 
 3 California Ave & Cortez St    Public Rack - California Ave & Cortez St
 4 Clinton St & Jackson Blvd     Canal St & Adams St                     
 5 Wilton Ave & Diversey Pkwy*   Wilton Ave & Diversey Pkwy              
 6 Larrabee St & Kingsbury St    Larrabee St & Oak St                    
 7 Wells St & Hubbard St         Orleans St & Hubbard St                 
 8 Clark St & Elm St             N Clark St & W Elm St                   
 9 Clinton St & Jackson Blvd     Canal St & Adams St                     
10 Canal St & Monroe St          Canal St & Madison St                   
   user_type ride_length day_of_week
   <chr>     <time>      <chr>      
 1 member    00'00"      Saturday   
 2 member    00'00"      Tuesday    
 3 member    00'00"      Wednesday  
 4 member    00'00"      Thursday   
 5 member    00'00"      Friday     
 6 member    00'00"      Saturday   
 7 member    00'00"      Sunday     
 8 member    00'00"      Sunday     
 9 member    00'00"      Monday     
10 member    00'00"      Monday     
# ℹ 6,238 more rows
```

```r
# Filter for rows where ride length is greater than or equal to 0, and starting
# and ending stations are the same.  Why are users ending at the same station,
# especially trips that last for seconds?  Are users trying out a bike, getting
# the wrong type and placing it back, or trying out the docking feature?  Are
# users completing a round trip? Additionally, consideration must be given to
# rides that last for hours. Bikes not in use should be docked.  Are users
# exercising? For leisure?

cyclistic_2023_v2 %>%
    filter(ride_length >= parse_hms("00:00:00"), starting_station == ending_station) %>%
    arrange(ride_length)  # 276,004 rows returned
```

```
# A tibble: 276,004 × 9
   ride_id          bike_type     start_time          end_time           
   <chr>            <chr>         <dttm>              <dttm>             
 1 C56965D2AE5D234E electric_bike 2023-01-01 00:22:00 2023-01-01 00:22:00
 2 BAC999B11574C4FE classic_bike  2023-01-01 00:31:00 2023-01-01 00:31:00
 3 B429DA4976E3859C classic_bike  2023-01-01 00:47:00 2023-01-01 00:47:00
 4 4259FDA946A26352 classic_bike  2023-01-01 00:56:00 2023-01-01 00:56:00
 5 4F28A430382131D6 classic_bike  2023-01-01 01:21:00 2023-01-01 01:21:00
 6 B4321D71C1489037 electric_bike 2023-01-01 01:55:00 2023-01-01 01:55:00
 7 9AC8CBEFAC3F50EA classic_bike  2023-01-01 02:11:00 2023-01-01 02:11:00
 8 7EE76882219DB0F9 classic_bike  2023-01-01 02:14:00 2023-01-01 02:14:00
 9 C628C24A859126C3 electric_bike 2023-01-01 02:21:00 2023-01-01 02:21:00
10 9B0DD77D39A47F6E electric_bike 2023-01-01 02:30:00 2023-01-01 02:30:00
   starting_station            ending_station              user_type ride_length
   <chr>                       <chr>                       <chr>     <time>     
 1 Winthrop Ave & Lawrence Ave Winthrop Ave & Lawrence Ave member    00'00"     
 2 Streeter Dr & Grand Ave     Streeter Dr & Grand Ave     member    00'00"     
 3 Clark St & Newport St       Clark St & Newport St       member    00'00"     
 4 Stave St & Armitage Ave     Stave St & Armitage Ave     casual    00'00"     
 5 State St & 33rd St          State St & 33rd St          member    00'00"     
 6 Long & Irving Park          Long & Irving Park          casual    00'00"     
 7 Franklin St & Chicago Ave   Franklin St & Chicago Ave   casual    00'00"     
 8 Bosworth Ave & Howard St    Bosworth Ave & Howard St    member    00'00"     
 9 Seeley Ave & Roscoe St      Seeley Ave & Roscoe St      casual    00'00"     
10 Albany Ave & Montrose Ave   Albany Ave & Montrose Ave   member    00'00"     
   day_of_week
   <chr>      
 1 Sunday     
 2 Sunday     
 3 Sunday     
 4 Sunday     
 5 Sunday     
 6 Sunday     
 7 Sunday     
 8 Sunday     
 9 Sunday     
10 Sunday     
# ℹ 275,994 more rows
```

```r
# Filter for rows where ride length greater than or equal to 24 hours and then
# sort the results by ascending order.  Includes trips lasting more than a day;
# some even lasting months.  According to Divvy, bikes not returned within a
# 24-hour period will be deemed lost or stolen until they have been found or
# returned to a docking station.  Rides over 24 hours will be removed.

cyclistic_2023_v2 %>%
    filter(ride_length >= parse_hms("24:00:00")) %>%
    arrange(ride_length)  # 6,439 rows returned
```

```
# A tibble: 6,439 × 9
   ride_id          bike_type    start_time          end_time           
   <chr>            <chr>        <dttm>              <dttm>             
 1 47B35ED4AB9309D6 classic_bike 2023-11-04 04:23:00 2023-11-05 04:23:00
 2 7432DB9AC2EE6C81 classic_bike 2023-11-04 07:37:00 2023-11-05 07:37:00
 3 1DC0B7072A47AA93 classic_bike 2023-11-04 09:20:00 2023-11-05 09:20:00
 4 F0D6F077D7C8BADA classic_bike 2023-11-04 09:54:00 2023-11-05 09:54:00
 5 92D979D502AE0573 classic_bike 2023-11-04 09:56:00 2023-11-05 09:56:00
 6 6B0693D384F86B78 classic_bike 2023-11-04 09:57:00 2023-11-05 09:57:00
 7 4FACA5E6A6D0854B classic_bike 2023-11-04 09:59:00 2023-11-05 09:59:00
 8 2F758C7E396BEE73 classic_bike 2023-11-04 11:51:00 2023-11-05 11:51:00
 9 FD085A4FAC4C3F39 classic_bike 2023-11-04 12:26:00 2023-11-05 12:26:00
10 35BCE327DADC5300 classic_bike 2023-11-04 12:33:00 2023-11-05 12:33:00
   starting_station                        ending_station user_type ride_length
   <chr>                                   <chr>          <chr>     <time>     
 1 Wolcott (Ravenswood) Ave & Montrose Ave <NA>           casual    24:00      
 2 Wabash Ave & Wacker Pl                  <NA>           casual    24:00      
 3 Michigan Ave & 8th St                   <NA>           casual    24:00      
 4 Sheffield Ave & Wellington Ave          <NA>           casual    24:00      
 5 Sheffield Ave & Wellington Ave          <NA>           casual    24:00      
 6 Sheffield Ave & Wellington Ave          <NA>           member    24:00      
 7 Sheffield Ave & Wellington Ave          <NA>           casual    24:00      
 8 Michigan Ave & 8th St                   <NA>           member    24:00      
 9 Greenview Ave & Fullerton Ave           <NA>           member    24:00      
10 Aberdeen St & Monroe St                 <NA>           casual    24:00      
   day_of_week
   <chr>      
 1 Saturday   
 2 Saturday   
 3 Saturday   
 4 Saturday   
 5 Saturday   
 6 Saturday   
 7 Saturday   
 8 Saturday   
 9 Saturday   
10 Saturday   
# ℹ 6,429 more rows
```


```r
# How many starting stations are missing?

cyclistic_2023_v2 %>%
    filter(is.na(starting_station)) %>%
    arrange(bike_type)  # 875,716 rows returned
```

```
# A tibble: 875,716 × 9
   ride_id          bike_type    start_time          end_time           
   <chr>            <chr>        <dttm>              <dttm>             
 1 921487B795A9E163 classic_bike 2023-10-26 12:14:19 2023-10-26 12:36:00
 2 5685FB0E8547AD9E classic_bike 2023-10-27 16:14:14 2023-10-27 16:27:02
 3 A4F8B87B8F8DB9FE classic_bike 2023-10-27 16:23:25 2023-10-27 16:30:47
 4 9D6A7C67EFB688FD classic_bike 2023-10-28 15:29:02 2023-10-28 15:40:51
 5 62F2649E24950EED classic_bike 2023-10-28 22:02:07 2023-10-28 22:16:04
 6 3EF4D90398872AEA classic_bike 2023-10-30 11:23:26 2023-10-30 11:39:30
 7 39198CFA2C5DC07F classic_bike 2023-10-30 16:35:23 2023-10-30 16:55:57
 8 5B5D9FB427DACE1E classic_bike 2023-10-30 17:50:23 2023-10-30 18:06:32
 9 41107B0A9FBDDAD2 classic_bike 2023-10-31 08:48:35 2023-10-31 09:04:41
10 AB271CA8E90C67C3 classic_bike 2023-10-31 10:16:08 2023-10-31 10:33:54
   starting_station ending_station             user_type ride_length day_of_week
   <chr>            <chr>                      <chr>     <time>      <chr>      
 1 <NA>             <NA>                       casual    21'41"      Thursday   
 2 <NA>             Halsted St & Clybourn Ave  member    12'48"      Friday     
 3 <NA>             Leavitt St & Armitage Ave  casual    07'22"      Friday     
 4 <NA>             Morgan St & Lake St*       member    11'49"      Saturday   
 5 <NA>             LaSalle St & Washington St casual    13'57"      Saturday   
 6 <NA>             <NA>                       casual    16'04"      Monday     
 7 <NA>             <NA>                       member    20'34"      Monday     
 8 <NA>             <NA>                       member    16'09"      Monday     
 9 <NA>             <NA>                       member    16'06"      Tuesday    
10 <NA>             <NA>                       casual    17'46"      Tuesday    
# ℹ 875,706 more rows
```

```r
# How many ending stations are missing?

cyclistic_2023_v2 %>%
    filter(is.na(ending_station)) %>%
    arrange(bike_type)  # 929,202 rows returned
```

```
# A tibble: 929,202 × 9
   ride_id          bike_type    start_time          end_time           
   <chr>            <chr>        <dttm>              <dttm>             
 1 7B43D6AB35E4E86D classic_bike 2023-01-01 01:06:00 2023-01-02 02:06:00
 2 BCFD032B3A6B0297 classic_bike 2023-01-01 01:13:00 2023-01-02 02:12:00
 3 97CA6CFF379DBCBD classic_bike 2023-01-01 01:26:00 2023-01-02 02:26:00
 4 1FB8FE3600279846 classic_bike 2023-01-01 04:45:00 2023-01-02 05:45:00
 5 F2185E23A7BB45C6 classic_bike 2023-01-01 15:02:00 2023-01-02 16:01:00
 6 F238900D8A2B80A5 classic_bike 2023-01-02 10:57:00 2023-01-03 11:56:00
 7 D49128E772E11CBE classic_bike 2023-01-02 11:03:00 2023-01-03 12:03:00
 8 7AB8D6F4E33866B0 classic_bike 2023-01-02 13:27:00 2023-01-03 14:27:00
 9 0A9054244220600A classic_bike 2023-01-02 15:14:00 2023-01-03 16:14:00
10 F2743A167F49378F classic_bike 2023-01-02 15:58:00 2023-01-03 16:57:00
   starting_station                ending_station user_type ride_length
   <chr>                           <chr>          <chr>     <time>     
 1 Greenview Ave & Fullerton Ave   <NA>           casual    25:00      
 2 Clark St & Grace St             <NA>           casual    24:59      
 3 Wilton Ave & Belmont Ave        <NA>           casual    25:00      
 4 State St & Van Buren St         <NA>           casual    25:00      
 5 State St & Kinzie St            <NA>           casual    24:59      
 6 Fairbanks Ct & Grand Ave        <NA>           member    24:59      
 7 Blackstone Ave & Hyde Park Blvd <NA>           casual    25:00      
 8 Clark St & Jarvis Ave           <NA>           casual    25:00      
 9 Clark St & Elm St               <NA>           casual    25:00      
10 Benson Ave & Church St          <NA>           casual    24:59      
   day_of_week
   <chr>      
 1 Sunday     
 2 Sunday     
 3 Sunday     
 4 Sunday     
 5 Sunday     
 6 Monday     
 7 Monday     
 8 Monday     
 9 Monday     
10 Monday     
# ℹ 929,192 more rows
```

```r
# Classic bikes should start from and end at a docking station.

cyclistic_2023_v2 %>%
    filter(is.na(starting_station), bike_type == "classic_bike") %>%
    arrange(ride_length)  # 34 rows returned
```

```
# A tibble: 34 × 9
   ride_id          bike_type    start_time          end_time           
   <chr>            <chr>        <dttm>              <dttm>             
 1 A4F8B87B8F8DB9FE classic_bike 2023-10-27 16:23:25 2023-10-27 16:30:47
 2 66661D737DFC2B72 classic_bike 2023-11-05 12:06:00 2023-11-05 12:15:00
 3 938CB5BE37B0378E classic_bike 2023-11-05 09:00:00 2023-11-05 09:10:00
 4 9D6A7C67EFB688FD classic_bike 2023-10-28 15:29:02 2023-10-28 15:40:51
 5 5685FB0E8547AD9E classic_bike 2023-10-27 16:14:14 2023-10-27 16:27:02
 6 62F2649E24950EED classic_bike 2023-10-28 22:02:07 2023-10-28 22:16:04
 7 5C416968B1AF58C6 classic_bike 2023-11-01 09:24:00 2023-11-01 09:40:00
 8 2FE722850C2C22E6 classic_bike 2023-11-01 12:57:00 2023-11-01 13:13:00
 9 33860DD1A1DDFA32 classic_bike 2023-11-01 15:19:00 2023-11-01 15:35:00
10 AEF9B8894E7870A7 classic_bike 2023-11-01 18:11:00 2023-11-01 18:27:00
   starting_station ending_station                user_type ride_length
   <chr>            <chr>                         <chr>     <time>     
 1 <NA>             Leavitt St & Armitage Ave     casual    07'22"     
 2 <NA>             Lakeview Ave & Fullerton Pkwy casual    09'00"     
 3 <NA>             Peoria St & Jackson Blvd      member    10'00"     
 4 <NA>             Morgan St & Lake St*          member    11'49"     
 5 <NA>             Halsted St & Clybourn Ave     member    12'48"     
 6 <NA>             LaSalle St & Washington St    casual    13'57"     
 7 <NA>             <NA>                          member    16'00"     
 8 <NA>             <NA>                          member    16'00"     
 9 <NA>             <NA>                          casual    16'00"     
10 <NA>             <NA>                          member    16'00"     
   day_of_week
   <chr>      
 1 Friday     
 2 Sunday     
 3 Sunday     
 4 Saturday   
 5 Friday     
 6 Saturday   
 7 Wednesday  
 8 Wednesday  
 9 Wednesday  
10 Wednesday  
# ℹ 24 more rows
```

```r
cyclistic_2023_v2 %>%
    filter(is.na(ending_station), bike_type == "classic_bike") %>%
    arrange(ride_length)  # 5,116 rows returned
```

```
# A tibble: 5,116 × 9
   ride_id          bike_type    start_time          end_time           
   <chr>            <chr>        <dttm>              <dttm>             
 1 F584D47AE67FD388 classic_bike 2023-11-05 21:08:00 2023-10-25 07:31:00
 2 AE046C379C20B7CA classic_bike 2023-11-05 20:46:00 2023-10-25 07:31:00
 3 A21D6507DA3C5AD4 classic_bike 2023-11-05 16:41:00 2023-10-25 07:31:00
 4 DEC5EF8DE27398A0 classic_bike 2023-11-05 11:56:00 2023-10-25 07:31:00
 5 7850F6E2343BF766 classic_bike 2023-11-01 16:38:00 2023-10-25 07:31:00
 6 5A5DDAFFF234FB69 classic_bike 2023-11-01 14:07:00 2023-10-25 07:31:00
 7 04B3D218D5E7C4FD classic_bike 2023-11-02 09:30:00 2023-11-02 09:33:00
 8 62BCD926C0CAA606 classic_bike 2023-11-02 16:22:00 2023-11-02 16:28:00
 9 65F798170A8B1102 classic_bike 2023-10-28 13:37:11 2023-10-28 13:43:19
10 BE0F9DC7D68F8563 classic_bike 2023-11-06 15:28:00 2023-11-06 15:36:00
   starting_station                ending_station user_type ride_length
   <chr>                           <chr>          <chr>     <time>     
 1 Sheffield Ave & Waveland Ave    <NA>           casual    -277:37:00 
 2 Sheridan Rd & Irving Park Rd    <NA>           member    -277:15:00 
 3 Pine Grove Ave & Irving Park Rd <NA>           member    -273:10:00 
 4 Pine Grove Ave & Irving Park Rd <NA>           casual    -268:25:00 
 5 Clark St & Drummond Pl          <NA>           casual    -177:07:00 
 6 Clark St & Drummond Pl          <NA>           member    -174:36:00 
 7 Woodlawn Ave & 55th St          <NA>           member      00:03:00 
 8 Halsted St & Roscoe St          <NA>           member      00:06:00 
 9 Wilton Ave & Belmont Ave        <NA>           casual      00:06:08 
10 Desplaines St & Kinzie St       <NA>           member      00:08:00 
   day_of_week
   <chr>      
 1 Sunday     
 2 Sunday     
 3 Sunday     
 4 Sunday     
 5 Wednesday  
 6 Wednesday  
 7 Thursday   
 8 Thursday   
 9 Saturday   
10 Monday     
# ℹ 5,106 more rows
```

```r
# Electric bikes do not have to start from and/or end at a station or an
# approved public bike rack.

cyclistic_2023_v2 %>%
    filter(is.na(starting_station), bike_type == "electric_bike") %>%
    arrange(ride_length)  # 875,682 rows returned
```

```
# A tibble: 875,682 × 9
   ride_id          bike_type     start_time          end_time           
   <chr>            <chr>         <dttm>              <dttm>             
 1 8B6E5BA70093AAB7 electric_bike 2023-06-02 19:29:06 2023-06-02 18:28:51
 2 F152040F707513F8 electric_bike 2023-11-05 01:57:00 2023-11-05 01:05:00
 3 1D345E6119C7A70F electric_bike 2023-11-05 01:53:00 2023-11-05 01:02:00
 4 4C5F9055282D516D electric_bike 2023-11-05 01:52:00 2023-11-05 01:02:00
 5 DC4C145C46A1C4B2 electric_bike 2023-08-12 15:15:32 2023-08-12 14:26:00
 6 D12C3767DC204369 electric_bike 2023-06-02 19:29:42 2023-06-02 18:40:44
 7 93BE6ED18893BEDF electric_bike 2023-11-05 01:50:00 2023-11-05 01:05:00
 8 224F89E21A390D45 electric_bike 2023-11-05 01:53:00 2023-11-05 01:12:00
 9 0F18F7290DC8A5BC electric_bike 2023-11-05 01:51:00 2023-11-05 01:18:00
10 ABB6B0F56CAD19B4 electric_bike 2023-08-12 14:30:04 2023-08-12 14:08:15
   starting_station ending_station            user_type ride_length day_of_week
   <chr>            <chr>                     <chr>     <time>      <chr>      
 1 <NA>             Calumet Ave & 18th St     casual    -01:00:15   Friday     
 2 <NA>             Clark St & Elm St         member    -00:52:00   Sunday     
 3 <NA>             Franklin St & Chicago Ave casual    -00:51:00   Sunday     
 4 <NA>             Ashland Ave & Division St member    -00:50:00   Sunday     
 5 <NA>             Shedd Aquarium            casual    -00:49:32   Saturday   
 6 <NA>             Calumet Ave & 18th St     casual    -00:48:58   Friday     
 7 <NA>             Clark St & Wrightwood Ave member    -00:45:00   Sunday     
 8 <NA>             <NA>                      casual    -00:41:00   Sunday     
 9 <NA>             <NA>                      member    -00:33:00   Sunday     
10 <NA>             Shedd Aquarium            member    -00:21:49   Saturday   
# ℹ 875,672 more rows
```

```r
cyclistic_2023_v2 %>%
    filter(is.na(ending_station), bike_type == "electric_bike") %>%
    arrange(ride_length)  # 922,039 rows returned
```

```
# A tibble: 922,039 × 9
   ride_id          bike_type     start_time          end_time           
   <chr>            <chr>         <dttm>              <dttm>             
 1 D8D9D4D695F852EA electric_bike 2023-09-01 19:16:25 2023-09-01 17:54:44
 2 AF517DF24EAE7E4A electric_bike 2023-11-19 20:10:00 2023-11-19 19:16:00
 3 EB53842F17F73958 electric_bike 2023-11-05 01:52:00 2023-11-05 01:00:00
 4 8ADAD4C495D80A3C electric_bike 2023-11-05 01:55:00 2023-11-05 01:03:00
 5 AFAE2ACA12524D1A electric_bike 2023-11-05 01:56:00 2023-11-05 01:08:00
 6 A4C89D792F20A0DD electric_bike 2023-11-05 01:59:00 2023-11-05 01:12:00
 7 F4E0FC9C8D9E41AF electric_bike 2023-11-05 01:43:00 2023-11-05 01:00:00
 8 224F89E21A390D45 electric_bike 2023-11-05 01:53:00 2023-11-05 01:12:00
 9 343400C6D4F9B4F5 electric_bike 2023-11-05 01:35:00 2023-11-05 01:02:00
10 0F18F7290DC8A5BC electric_bike 2023-11-05 01:51:00 2023-11-05 01:18:00
   starting_station                        ending_station user_type ride_length
   <chr>                                   <chr>          <chr>     <time>     
 1 Elizabeth St & Randolph St              <NA>           member    -01:21:41  
 2 Wabash Ave & 9th St                     <NA>           member    -00:54:00  
 3 Wolcott (Ravenswood) Ave & Montrose Ave <NA>           member    -00:52:00  
 4 Larrabee St & North Ave                 <NA>           member    -00:52:00  
 5 Damen Ave & Cortland St                 <NA>           casual    -00:48:00  
 6 Millennium Park                         <NA>           casual    -00:47:00  
 7 DuSable Lake Shore Dr & Wellington Ave  <NA>           member    -00:43:00  
 8 <NA>                                    <NA>           casual    -00:41:00  
 9 Prairie Ave & 43rd St                   <NA>           casual    -00:33:00  
10 <NA>                                    <NA>           member    -00:33:00  
   day_of_week
   <chr>      
 1 Friday     
 2 Sunday     
 3 Sunday     
 4 Sunday     
 5 Sunday     
 6 Sunday     
 7 Sunday     
 8 Sunday     
 9 Sunday     
10 Sunday     
# ℹ 922,029 more rows
```


```r
# Docked bikes?  According to past trip data, classic bikes were introduced in
# December of 2020. An improved version of the same 'docked' bike. They both
# start from and end at a docking station.  Since then, classic bikes have
# outnumbered docked bikes.  The last month of recorded data on docked bikes
# was in August of 2023. Phased out.

cyclistic_2023_v2 %>%
    filter(bike_type == "docked_bike") %>%
    arrange(start_time)  # 78,287 rows returned
```

```
# A tibble: 78,287 × 9
   ride_id          bike_type   start_time          end_time           
   <chr>            <chr>       <dttm>              <dttm>             
 1 D8CA60CB9D968FBA docked_bike 2023-01-01 00:15:00 2023-01-01 00:37:00
 2 454214BA380A6E60 docked_bike 2023-01-01 00:23:00 2023-01-11 06:36:00
 3 98F7647A5AD484DC docked_bike 2023-01-01 00:24:00 2023-01-11 06:36:00
 4 818CE39CB3293130 docked_bike 2023-01-01 00:51:00 2023-01-01 01:07:00
 5 010A20E6BADB0B3A docked_bike 2023-01-01 00:58:00 2023-01-01 01:11:00
 6 D9DA83F19FEA2F52 docked_bike 2023-01-01 01:03:00 2023-01-01 01:24:00
 7 5D8583AEF114BE5E docked_bike 2023-01-01 01:04:00 2023-01-01 01:24:00
 8 9DD64FCCA3C54146 docked_bike 2023-01-01 01:16:00 2023-01-01 01:27:00
 9 8ECC80DC7031EE53 docked_bike 2023-01-01 01:32:00 2023-01-01 01:39:00
10 3D2E8BC3F6F7A411 docked_bike 2023-01-01 01:47:00 2023-01-01 01:52:00
   starting_station            ending_station                user_type
   <chr>                       <chr>                         <chr>    
 1 Streeter Dr & Grand Ave     Lakeview Ave & Fullerton Pkwy casual   
 2 LaSalle St & Washington St  <NA>                          casual   
 3 LaSalle St & Washington St  <NA>                          casual   
 4 Michigan Ave & Jackson Blvd McClurg Ct & Ohio St          casual   
 5 Marine Dr & Ainslie St      Clark St & Winnemac Ave       casual   
 6 Daley Center Plaza          Franklin St & Monroe St       casual   
 7 Daley Center Plaza          Franklin St & Monroe St       casual   
 8 Michigan Ave & Oak St       Clark St & Lincoln Ave        casual   
 9 Damen Ave & Pierce Ave      Damen Ave & Chicago Ave       casual   
10 Clark St & Elm St           Clark St & Elm St             casual   
   ride_length day_of_week
   <time>      <chr>      
 1  00:22      Sunday     
 2 246:13      Sunday     
 3 246:12      Sunday     
 4  00:16      Sunday     
 5  00:13      Sunday     
 6  00:21      Sunday     
 7  00:20      Sunday     
 8  00:11      Sunday     
 9  00:07      Sunday     
10  00:05      Sunday     
# ℹ 78,277 more rows
```

```r
cyclistic_2023_v2 %>%
    filter(is.na(starting_station), bike_type == "docked_bike") %>%
    arrange(ride_length)  # None returned
```

```
# A tibble: 0 × 9
# ℹ 9 variables: ride_id <chr>, bike_type <chr>, start_time <dttm>, end_time <dttm>, starting_station <chr>, ending_station <chr>, user_type <chr>, ride_length <time>, day_of_week <chr>
```

```r
cyclistic_2023_v2 %>%
    filter(is.na(ending_station), bike_type == "docked_bike") %>%
    arrange(ride_length)  # 2,047 rows returned
```

```
# A tibble: 2,047 × 9
   ride_id          bike_type   start_time          end_time           
   <chr>            <chr>       <dttm>              <dttm>             
 1 4F5362895C51E27B docked_bike 2023-04-04 08:17:22 2023-04-04 08:17:41
 2 D7F9248E0F264A53 docked_bike 2023-05-29 19:26:20 2023-05-29 19:27:34
 3 E0B19F1B7FDDE208 docked_bike 2023-05-17 19:07:19 2023-05-17 19:08:46
 4 00134E65A9C67731 docked_bike 2023-02-28 11:56:09 2023-02-28 11:57:39
 5 734933E4B0A69AF4 docked_bike 2023-06-02 18:47:34 2023-06-02 18:49:37
 6 5A04D936F2B4BF05 docked_bike 2023-05-16 19:29:46 2023-05-16 19:32:48
 7 182917D5051479E4 docked_bike 2023-07-09 16:20:59 2023-07-09 16:25:44
 8 DFCE0C92BAB5F253 docked_bike 2023-07-02 18:30:46 2023-07-02 18:35:36
 9 F190276192A41D05 docked_bike 2023-08-17 18:23:03 2023-08-17 18:27:54
10 A3D213108680C18F docked_bike 2023-06-03 15:29:13 2023-06-03 15:34:08
   starting_station             ending_station user_type ride_length day_of_week
   <chr>                        <chr>          <chr>     <time>      <chr>      
 1 Cottage Grove Ave & 63rd St  <NA>           casual    00'19"      Tuesday    
 2 Michigan Ave & Washington St <NA>           casual    01'14"      Monday     
 3 Michigan Ave & Lake St       <NA>           casual    01'27"      Wednesday  
 4 St. Clair St & Erie St       <NA>           casual    01'30"      Tuesday    
 5 Wells St & Evergreen Ave     <NA>           casual    02'03"      Friday     
 6 Desplaines St & Jackson Blvd <NA>           casual    03'02"      Tuesday    
 7 Larrabee St & Armitage Ave   <NA>           casual    04'45"      Sunday     
 8 Michigan Ave & 18th St       <NA>           casual    04'50"      Sunday     
 9 Larrabee St & Webster Ave    <NA>           casual    04'51"      Thursday   
10 Dusable Harbor               <NA>           casual    04'55"      Saturday   
# ℹ 2,037 more rows
```

```r
# Interestingly, no members have used docked bikes.

cyclistic_2023_v2 %>%
    filter(bike_type == "docked_bike", user_type == "member")  # None returned
```

```
# A tibble: 0 × 9
# ℹ 9 variables: ride_id <chr>, bike_type <chr>, start_time <dttm>, end_time <dttm>, starting_station <chr>, ending_station <chr>, user_type <chr>, ride_length <time>, day_of_week <chr>
```

```r
# Docked bikes will be renamed as classic bikes.

cyclistic_2023_v3 <- cyclistic_2023_v2 %>%
    mutate(bike_type = if_else(bike_type == "docked_bike", "classic_bike", bike_type))

# Confirming the change:

cyclistic_2023_v3 %>%
    group_by(bike_type) %>%
    summarize(num_of_bikes = n())
```

```
# A tibble: 2 × 2
  bike_type     num_of_bikes
  <chr>                <int>
1 classic_bike       2774298
2 electric_bike      2945579
```

## The Final Dataset


```r
# Removing rows where ride length is less than a minute and 24 hours or more.

cyclistic_2023_final <- cyclistic_2023_v3 %>%
    filter(ride_length >= parse_hms("00:01:00"), ride_length < parse_hms("24:00:00"))

# Only 857 rows remaining where classic bikes have a missing starting and/or
# ending station.

cyclistic_2023_final %>%
    filter(bike_type == "classic_bike" & (is.na(starting_station) | is.na(ending_station)))
```

```
# A tibble: 857 × 9
   ride_id          bike_type    start_time          end_time           
   <chr>            <chr>        <dttm>              <dttm>             
 1 764A7F33254E39C6 classic_bike 2023-01-01 11:20:00 2023-01-01 14:40:00
 2 1C220AC3234553CA classic_bike 2023-01-01 11:21:00 2023-01-01 14:40:00
 3 B57B2B65E931483F classic_bike 2023-01-03 17:09:00 2023-01-03 20:57:00
 4 E29AE1D251BB583E classic_bike 2023-01-04 23:21:00 2023-01-04 23:35:00
 5 5B949D71B23CFB54 classic_bike 2023-01-06 16:26:00 2023-01-07 13:07:00
 6 45125F6E88AD0535 classic_bike 2023-01-07 12:52:00 2023-01-08 06:47:00
 7 4C5586EE1FB9A955 classic_bike 2023-01-13 16:11:00 2023-01-14 04:42:00
 8 E5B3EFE7DB345F17 classic_bike 2023-01-14 11:33:00 2023-01-15 04:14:00
 9 7EDC5BC916EBE57D classic_bike 2023-01-14 12:44:00 2023-01-15 04:34:00
10 0ED544A10640673E classic_bike 2023-01-14 12:47:00 2023-01-14 13:18:00
   starting_station            ending_station user_type ride_length day_of_week
   <chr>                       <chr>          <chr>     <time>      <chr>      
 1 Millennium Park             <NA>           casual    03:20       Sunday     
 2 Millennium Park             <NA>           casual    03:19       Sunday     
 3 Fairbanks Ct & Grand Ave    <NA>           casual    03:48       Tuesday    
 4 Damen Ave & Melrose Ave     <NA>           casual    00:14       Wednesday  
 5 Field Museum                <NA>           casual    20:41       Friday     
 6 New St & Illinois St        <NA>           casual    17:55       Saturday   
 7 State St & Chicago Ave      <NA>           casual    12:31       Friday     
 8 Streeter Dr & Grand Ave     <NA>           casual    16:41       Saturday   
 9 Field Blvd & South Water St <NA>           casual    15:50       Saturday   
10 Millennium Park             <NA>           casual    00:31       Saturday   
# ℹ 847 more rows
```

```r
# Removing the 857 rows.

cyclistic_2023_final <- cyclistic_2023_final %>%
    filter(!(bike_type == "classic_bike" & (is.na(starting_station) | is.na(ending_station))))

# Extracted the month from the start time to prevent issues and simplify coding
# during the analysis and visualization process.

cyclistic_2023_final <- cyclistic_2023_final %>%
    mutate(month = month(start_time, label = TRUE))

# Inspecting final dataset:

skim_without_charts(cyclistic_2023_final)
```


Table: Data summary

|                         |                     |
|:------------------------|:--------------------|
|Name                     |cyclistic_2023_final |
|Number of rows           |5568457              |
|Number of columns        |10                   |
|_______________________  |                     |
|Column type frequency:   |                     |
|character                |6                    |
|difftime                 |1                    |
|factor                   |1                    |
|POSIXct                  |2                    |
|________________________ |                     |
|Group variables          |None                 |


**Variable type: character**

|skim_variable    | n_missing| complete_rate| min| max| empty| n_unique| whitespace|
|:----------------|---------:|-------------:|---:|---:|-----:|--------:|----------:|
|ride_id          |         0|          1.00|  16|  16|     0|  5568457|          0|
|bike_type        |         0|          1.00|  12|  13|     0|        2|          0|
|starting_station |    832813|          0.85|   3|  64|     0|     1585|          0|
|ending_station   |    864899|          0.84|   3|  64|     0|     1589|          0|
|user_type        |         0|          1.00|   6|   6|     0|        2|          0|
|day_of_week      |         0|          1.00|   6|   9|     0|        7|          0|


**Variable type: difftime**

|skim_variable | n_missing| complete_rate|min     |max        |median   | n_unique|
|:-------------|---------:|-------------:|:-------|:----------|:--------|--------:|
|ride_length   |         0|             1|60 secs |86355 secs |00:09:48 |    20953|


**Variable type: factor**

|skim_variable | n_missing| complete_rate|ordered | n_unique|top_counts                                         |
|:-------------|---------:|-------------:|:-------|--------:|:--------------------------------------------------|
|month         |         0|             1|TRUE    |       12|Aug: 752073, Jul: 746274, Jun: 699930, Sep: 651194 |


**Variable type: POSIXct**

|skim_variable | n_missing| complete_rate|min                 |max                 |median              | n_unique|
|:-------------|---------:|-------------:|:-------------------|:-------------------|:-------------------|--------:|
|start_time    |         0|             1|2023-01-01 00:01:00 |2023-12-31 23:58:55 |2023-07-21 06:38:06 |  4295837|
|end_time      |         0|             1|2023-01-01 00:02:00 |2024-01-01 14:20:23 |2023-07-21 06:56:58 |  4306813|
Save the final dataset:  
`write_csv(cyclistic_2023_final, "cyclistic_2023_final.csv")`

## Analysis

### Number of users


```r
cyclistic_2023_final %>%
    group_by(user_type) %>%
    summarize(Count = n())
```

```
# A tibble: 2 × 2
  user_type   Count
  <chr>       <int>
1 casual    2001176
2 member    3567281
```

```r
cyclistic_2023_final %>%
    group_by(user_type) %>%
    summarize(Percentage = n()/nrow(cyclistic_2023_final) * 100)
```

```
# A tibble: 2 × 2
  user_type Percentage
  <chr>          <dbl>
1 casual          35.9
2 member          64.1
```

In 2023, members nearly doubled casual riders.

### Number of bikes used


```r
cyclistic_2023_final %>%
    group_by(bike_type) %>%
    summarize(count = n())
```

```
# A tibble: 2 × 2
  bike_type       count
  <chr>           <int>
1 classic_bike  2726630
2 electric_bike 2841827
```

```r
cyclistic_2023_final %>%
    group_by(bike_type) %>%
    summarize(Percentage = n()/nrow(cyclistic_2023_final) * 100)
```

```
# A tibble: 2 × 2
  bike_type     Percentage
  <chr>              <dbl>
1 classic_bike        49.0
2 electric_bike       51.0
```

Nearly a 50/50 split. Electric bikes were slightly more popular.

### How many members and casual riders used a specific bike


```r
cyclistic_2023_final %>%
    filter(user_type == "casual" | user_type == "member") %>%
    group_by(user_type, bike_type) %>%
    summarize(bike_count = n())
```

```
# A tibble: 4 × 3
# Groups:   user_type [2]
  user_type bike_type     bike_count
  <chr>     <chr>              <int>
1 casual    classic_bike      936486
2 casual    electric_bike    1064690
3 member    classic_bike     1790144
4 member    electric_bike    1777137
```

### The distribution of bikes among casual riders by percentage


```r
cyclistic_2023_final_casual <- cyclistic_2023_final %>%
    filter(user_type == "casual")

cyclistic_2023_final_casual %>%
    group_by(bike_type) %>%
    summarize(bike_count = n(), percentage = n()/nrow(cyclistic_2023_final_casual) *
        100)
```

```
# A tibble: 2 × 3
  bike_type     bike_count percentage
  <chr>              <int>      <dbl>
1 classic_bike      936486       46.8
2 electric_bike    1064690       53.2
```

Casual riders used more electric bikes in 2023. Electric bikes accounted for 53.2% of all trips, while classic bikes accounted for 46.8%.

### The distribution of bikes among members by percentage


```r
cyclistic_2023_final_member <- cyclistic_2023_final %>%
    filter(user_type == "member")

cyclistic_2023_final_member %>%
    group_by(bike_type) %>%
    summarize(bike_count = n(), Percentage = n()/nrow(cyclistic_2023_final_member) *
        100)
```

```
# A tibble: 2 × 3
  bike_type     bike_count Percentage
  <chr>              <int>      <dbl>
1 classic_bike     1790144       50.2
2 electric_bike    1777137       49.8
```

Members used either classic or electric bikes. Classic bikes accounted for 50.2% of all trips, while electric bikes accounted for 49.8%.

### Install and load DescTools to use the Mode() function


```r
install.packages("DescTools")
```


```r
library(DescTools)
```

### The most active day for all users


```r
Mode(cyclistic_2023_final$day_of_week)
```

```
[1] "Saturday"
attr(,"freq")
[1] 858885
```

Saturday was the most popular day in 2023, with a total of 858,885 rides.

### Most active day by user type


```r
cyclistic_2023_final %>%
    group_by(user_type) %>%
    summarize(day = Mode(day_of_week))
```

```
# A tibble: 2 × 2
  user_type day     
  <chr>     <chr>   
1 casual    Saturday
2 member    Thursday
```

Saturday was the most active day for casual riders, while members were most active on Thursday.

### Total rides for each day by user type


```r
cyclistic_2023_final %>%
    group_by(user_type, factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday",
        "Thursday", "Friday", "Saturday", "Sunday"))) %>%
    summarize(count = n())
```

```
# A tibble: 14 × 3
# Groups:   user_type [2]
   user_type `factor(...)`  count
   <chr>     <fct>          <int>
 1 casual    Monday        228372
 2 casual    Tuesday       239478
 3 casual    Wednesday     242340
 4 casual    Thursday      263180
 5 casual    Friday        303158
 6 casual    Saturday      398814
 7 casual    Sunday        325834
 8 member    Monday        482404
 9 member    Tuesday       562483
10 member    Wednesday     572036
11 member    Thursday      574427
12 member    Friday        517577
13 member    Saturday      460071
14 member    Sunday        398283
```

Members are much more active during the weekdays, while casual riders become more active during the weekends. 

### Most active month by user type


```r
cyclistic_2023_final %>%
    group_by(user_type) %>%
    summarize(Mode(month))
```

```
# A tibble: 2 × 2
  user_type `Mode(month)`
  <chr>     <ord>        
1 casual    Jul          
2 member    Aug          
```

The most active month for casual riders was July, while August was the most active month for members.

### Total rides each month


```r
cyclistic_2023_final %>%
    group_by(month) %>%
    summarize(rides = n())
```

```
# A tibble: 12 × 2
   month  rides
   <ord>  <int>
 1 Jan   186354
 2 Feb   184323
 3 Mar   249414
 4 Apr   411159
 5 May   586230
 6 Jun   699930
 7 Jul   746274
 8 Aug   752073
 9 Sep   651194
10 Oct   524715
11 Nov   357744
12 Dec   219047
```

The month of August had the most rides, totaling 752,073.

### Total rides each month by user type


```r
cyclistic_2023_final %>%
    group_by(month, user_type) %>%
    summarize(rides = n())
```

```
# A tibble: 24 × 3
# Groups:   month [12]
   month user_type  rides
   <ord> <chr>      <int>
 1 Jan   casual     39203
 2 Jan   member    147151
 3 Feb   casual     41723
 4 Feb   member    142600
 5 Mar   casual     60125
 6 Mar   member    189289
 7 Apr   casual    142118
 8 Apr   member    269041
 9 May   casual    226771
10 May   member    359459
# ℹ 14 more rows
```

Casual riders become significantly more active during quarters 2 and 3, then drastically fall off in quarter 4.  
Members show the same trend.

### Total ride duration


```r
cyclistic_2023_final %>%
    group_by(user_type) %>%
    summarize(total = as_hms(sum(ride_length)))
```

```
# A tibble: 2 × 2
  user_type total       
  <chr>     <time>      
1 casual    701986:06:23
2 member    734285:03:07
```

In 2023, casual riders logged 701,986 hours, 6 minutes, and 23 seconds, while members recorded 734,285 hours, 3 minutes, and 7 seconds.  
Despite the membership count being nearly double that of casual riders, the difference in total ride duration was not significantly higher in 2023.

### Average ride length


```r
mean(cyclistic_2023_final$ride_length)
```

```
Time difference of 928.5474 secs
```

```r
as_hms(mean(cyclistic_2023_final$ride_length))
```

```
00:15:28.547382
```

```r
round_hms(as_hms(mean(cyclistic_2023_final$ride_length)), 1)
```

```
00:15:29
```

15 minutes and 29 seconds was the average ride length for all users.

### Average ride length by month


```r
cyclistic_2023_final %>%
    group_by(month) %>%
    summarize(average_duration = as_hms(mean(ride_length)))
```

```
# A tibble: 12 × 2
   month average_duration
   <ord> <time>          
 1 Jan   11'00.153901"   
 2 Feb   12'03.368359"   
 3 Mar   11'46.872437"   
 4 Apr   15'01.011380"   
 5 May   16'38.270611"   
 6 Jun   16'54.903799"   
 7 Jul   17'42.826494"   
 8 Aug   17'02.554719"   
 9 Sep   16'18.086383"   
10 Oct   14'17.485303"   
11 Nov   12'24.690729"   
12 Dec   11'54.076016"   
```

In 2023, the average ride length showed a notable increase in quarters 2 and 3, with July recording the highest average ride duration of 17 minutes and 43 seconds.

### Average ride length by user type


```r
cyclistic_2023_final %>%
    group_by(user_type) %>%
    summarize(average_duration = as_hms(mean(ride_length)))
```

```
# A tibble: 2 × 2
  user_type average_duration
  <chr>     <time>          
1 casual    21'02.832446"   
2 member    12'21.019894"   
```

Casual riders had an average ride length of 21 minutes and 3 seconds, the highest among all groups, while members averaged 12 minutes and 21 seconds per ride.   
This significant difference in average ride length accounts for the unexpectedly narrow gap in total ride duration between members and casual riders.

### Average ride length per month by bike type and user type


```r
cyclistic_2023_final %>%
    group_by(bike_type, user_type) %>%
    summarize(average_duration = as_hms(mean(ride_length)))
```

```
# A tibble: 4 × 3
# Groups:   bike_type [2]
  bike_type     user_type average_duration
  <chr>         <chr>     <time>          
1 classic_bike  casual    28'11.262783"   
2 classic_bike  member    13'10.088269"   
3 electric_bike casual    14'45.991288"   
4 electric_bike member    11'31.592383"   
```

Casual riders on classic bikes typically ride nearly twice as long as members. Day passes and memberships grant free access to bikes for limited times within 24 hours, with day passes offering unique unlimited 3-hour rides.

### Average ride length per month by user type


```r
cyclistic_2023_final %>%
    group_by(month, user_type) %>%
    summarize(average_duration = as_hms(mean(ride_length)))
```

```
# A tibble: 24 × 3
# Groups:   month [12]
   month user_type average_duration
   <ord> <chr>     <time>          
 1 Jan   casual    13'43.355866"   
 2 Jan   member    10'16.674708"   
 3 Feb   casual    16'20.762865"   
 4 Feb   member    10'48.057903"   
 5 Mar   casual    15'36.949222"   
 6 Mar   member    10'33.791768"   
 7 Apr   casual    20'57.359807"   
 8 Apr   member    11'52.774176"   
 9 May   casual    22'30.585070"   
10 May   member    12'56.006869"   
# ℹ 14 more rows
```

The month of July recorded the highest averages for both members and casual riders.  
In general, the average ride length by month follows a similar trend to the total number of rides by month.

### Top 10 starting stations


```r
cyclistic_2023_final %>%
    group_by(starting_stations = starting_station) %>%
    summarize(number_of_starts = n()) %>%
    drop_na() %>%
    top_n(10) %>%
    arrange(desc(number_of_starts))
```

```
# A tibble: 10 × 2
   starting_stations                  number_of_starts
   <chr>                                         <int>
 1 Streeter Dr & Grand Ave                       61707
 2 DuSable Lake Shore Dr & Monroe St             39319
 3 Michigan Ave & Oak St                         36517
 4 Clark St & Elm St                             35147
 5 DuSable Lake Shore Dr & North Blvd            35068
 6 Kingsbury St & Kinzie St                      34284
 7 Wells St & Concord Ln                         32958
 8 Clinton St & Washington Blvd                  32007
 9 Wells St & Elm St                             29916
10 Theater on the Lake                           29406
```

Streeter Dr & Grand Ave was the most active starting station in 2023.

### Top 10 ending stations


```r
cyclistic_2023_final %>%
    group_by(ending_stations = ending_station) %>%
    summarize(number_of_stops = n()) %>%
    drop_na() %>%
    top_n(10) %>%
    arrange(desc(number_of_stops))
```

```
# A tibble: 10 × 2
   ending_stations                    number_of_stops
   <chr>                                        <int>
 1 Streeter Dr & Grand Ave                      63079
 2 DuSable Lake Shore Dr & North Blvd           38704
 3 Michigan Ave & Oak St                        37305
 4 DuSable Lake Shore Dr & Monroe St            37272
 5 Clark St & Elm St                            34401
 6 Kingsbury St & Kinzie St                     33722
 7 Wells St & Concord Ln                        33638
 8 Clinton St & Washington Blvd                 32745
 9 Millennium Park                              30454
10 Theater on the Lake                          30098
```

Streeter Dr & Grand Ave was the top destination to end rides in 2023.

### Top 10 starting stations for casual riders


```r
cyclistic_2023_final %>%
    filter(user_type == "casual") %>%
    group_by(starting_station) %>%
    summarize(casual_riders = n()) %>%
    drop_na() %>%
    top_n(10) %>%
    arrange(desc(casual_riders))
```

```
# A tibble: 10 × 2
   starting_station                   casual_riders
   <chr>                                      <int>
 1 Streeter Dr & Grand Ave                    44899
 2 DuSable Lake Shore Dr & Monroe St          29785
 3 Michigan Ave & Oak St                      22154
 4 DuSable Lake Shore Dr & North Blvd         19872
 5 Millennium Park                            19683
 6 Shedd Aquarium                             17381
 7 Theater on the Lake                        15990
 8 Dusable Harbor                             15129
 9 Wells St & Concord Ln                      11967
10 Adler Planetarium                          11644
```

Streeter Dr & Grand Ave was the most active starting station for casual riders in 2023.

### Top 10 starting stations for members


```r
cyclistic_2023_final %>%
    filter(user_type == "member") %>%
    group_by(starting_station) %>%
    summarize(members = n()) %>%
    drop_na() %>%
    top_n(10) %>%
    arrange(desc(members))
```

```
# A tibble: 10 × 2
   starting_station             members
   <chr>                          <int>
 1 Kingsbury St & Kinzie St       25632
 2 Clinton St & Washington Blvd   25621
 3 Clark St & Elm St              24520
 4 Wells St & Concord Ln          20991
 5 Clinton St & Madison St        20080
 6 Wells St & Elm St              20063
 7 University Ave & 57th St       19606
 8 Broadway & Barry Ave           18608
 9 Loomis St & Lexington St       18391
10 Ellis Ave & 60th St            17861
```

Kingsbury St & Kinzie St was the most active starting station for members in 2023.

### Top 10 ending stations for casual riders


```r
cyclistic_2023_final %>%
    filter(user_type == "casual") %>%
    group_by(ending_station) %>%
    summarize(casual_riders = n()) %>%
    drop_na() %>%
    top_n(10) %>%
    arrange(desc(casual_riders))
```

```
# A tibble: 10 × 2
   ending_station                     casual_riders
   <chr>                                      <int>
 1 Streeter Dr & Grand Ave                    48566
 2 DuSable Lake Shore Dr & Monroe St          27040
 3 Michigan Ave & Oak St                      23317
 4 DuSable Lake Shore Dr & North Blvd         22987
 5 Millennium Park                            21861
 6 Theater on the Lake                        17324
 7 Shedd Aquarium                             15373
 8 Dusable Harbor                             13315
 9 Wells St & Concord Ln                      11772
10 Montrose Harbor                            11437
```

Streeter Dr & Grand Ave tops the ranks once again as the top destination for casual riders in 2023.

### Top 10 ending stations for members


```r
cyclistic_2023_final %>%
    filter(user_type == "member") %>%
    group_by(ending_station) %>%
    summarize(members = n()) %>%
    drop_na() %>%
    top_n(10) %>%
    arrange(desc(members))
```

```
# A tibble: 10 × 2
   ending_station               members
   <chr>                          <int>
 1 Clinton St & Washington Blvd   26878
 2 Kingsbury St & Kinzie St       25930
 3 Clark St & Elm St              24425
 4 Wells St & Concord Ln          21866
 5 Clinton St & Madison St        21692
 6 Wells St & Elm St              19942
 7 University Ave & 57th St       19837
 8 Broadway & Barry Ave           19082
 9 State St & Chicago Ave         18682
10 Loomis St & Lexington St       18162
```

Clinton St & Washington Blvd was the top destination for members in 2023.

## Visualizations


```r
install.packages("scales")
```


```r
library(scales)  # To adjust axes, labels, legends, and breaks.
```

### The number of members and casual riders


```r
num_casuals_members <- cyclistic_2023_final %>%
    group_by(user_type) %>%
    summarize(count = n()) %>%
    ggplot(aes(user_type, count, fill = user_type, width = 0.4)) + geom_col() + scale_y_continuous(labels = label_comma()) +
    geom_text(aes(label = scales::comma(count), vjust = -0.5)) + guides(fill = "none") +
    labs(title = "Number of Casual Riders and Members in 2023", x = "", y = "Number of Users") +
    theme_minimal() + theme(panel.grid.major.x = element_blank())
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

### The distribution of classic and electric bikes among members and casual riders


```r
distribution_bikes <- cyclistic_2023_final %>%
    group_by(user_type, bike_type) %>%
    summarize(count = n()) %>%
    ggplot(aes(user_type, count, fill = bike_type)) + geom_col(position = "fill",
    aes(fill = bike_type), width = 0.5) + geom_text(aes(label = scales::comma(count)),
    position = position_fill(vjust = 0.5), size = 4) + geom_hline(yintercept = 0.5,
    lty = 2) + scale_fill_brewer() + scale_y_continuous(labels = percent_format()) +
    labs(title = "Classic or Electric", subtitle = "The Distribution of Bikes Among Casual Riders and Members in 2023",
        x = "", y = "Percentage", fill = "Bike Type") + theme_minimal() + theme(panel.grid.major.x = element_blank())
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

### The total rides for each month by user type


```r
total_rides_month <- cyclistic_2023_final %>%
    group_by(month, user_type) %>%
    summarize(total_rides = n()) %>%
    ggplot(aes(month, total_rides, fill = user_type)) + geom_col() + scale_y_continuous(labels = label_comma()) +
    labs(title = "Total Rides by Month in 2023", subtitle = "Casual Riders vs Members",
        x = "", y = "Total Rides", fill = "User Type") + theme_minimal()
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

### The total rides for each day by user type


```r
total_rides_day <- cyclistic_2023_final %>%
    group_by(user_type, day_of_week) %>%
    summarize(count = n()) %>%
    ggplot(aes(factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday",
        "Friday", "Saturday", "Sunday")), count, fill = user_type)) + geom_col(position = "dodge2") +
    coord_flip() + geom_text(aes(label = scales::comma(count)), position = position_dodge(width = 0.9),
    hjust = -0.1, color = "black", size = 3.5) + scale_y_continuous(labels = label_comma()) +
    labs(title = "Total Rides by Day in 2023", subtitle = "Casual Riders vs Members",
        y = "Number of Rides", x = "", fill = "User Type") + theme_minimal()
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

### The total ride length for each month by user type


```r
# Creating a new dataset to change the ride length values to numeric
cyclistic_2023_final_v2 <- cyclistic_2023_final %>%
    mutate(ride_length = as.numeric(end_time - start_time, units = "mins"))
```


```r
total_ride_length_month <- cyclistic_2023_final_v2 %>%
    group_by(month, user_type) %>%
    summarize(total_ride_length = sum(ride_length), .groups = "drop") %>%
    ggplot(aes(x = month, y = total_ride_length, color = user_type, group = user_type)) +
    geom_point() + geom_line() + scale_y_continuous(labels = label_comma()) + labs(title = "Total Ride Length (Minutes) by Month in 2023",
    subtitle = "Casual Riders vs Members", x = "", y = "Ride Length", color = "User Type") +
    theme_minimal()
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-29-1.png)<!-- -->

### The average ride length by user type


```r
avg_ride_length_users <- cyclistic_2023_final %>%
    group_by(user_type) %>%
    summarize(average_Duration = as_hms(mean(ride_length))) %>%
    ggplot(aes(user_type, average_Duration, fill = user_type, width = 0.4)) + geom_col() +
    geom_hline(yintercept = mean(cyclistic_2023_final$ride_length), lty = 2) + geom_text(aes(0,
    mean(cyclistic_2023_final$ride_length), label = paste0("Average Ride Duration for All Users:",
        " ", round_hms(as_hms(mean(cyclistic_2023_final$ride_length)), 1))), hjust = -1.7,
    vjust = -0.5, check_overlap = T) + geom_text(aes(label = round_hms(average_Duration,
    1), vjust = -0.5)) + theme_minimal() + labs(title = "Average Ride Length by User Type in 2023",
    x = "", y = "Ride Length") + guides(fill = "none") + theme(panel.grid.major.x = element_blank())
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-30-1.png)<!-- -->

### The average ride length by bike type and user type


```r
avg_ride_length_bike <- cyclistic_2023_final %>%
    group_by(bike_type, user_type) %>%
    summarize(average_duration = as_hms(mean(ride_length))) %>%
    ggplot(aes(bike_type, average_duration, fill = user_type)) + geom_col(position = "dodge2") +
    geom_text(aes(label = round_hms(average_duration, 1)), position = position_dodge(width = 0.9),
        vjust = -0.4) + labs(title = "Average Ride Length by Bike Type in 2023",
    subtitle = "Casual Riders vs Members", x = "", y = "Ride Length", fill = "User Type") +
    theme_minimal() + theme(panel.grid.major.x = element_blank())
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-31-1.png)<!-- -->

### The average ride length each month by user type


```r
avg_ride_length_month <- cyclistic_2023_final %>%
    group_by(month, user_type) %>%
    summarize(average_ride_length = as_hms(mean(ride_length))) %>%
    ggplot(aes(month, average_ride_length, fill = user_type)) + geom_col(position = "dodge2") +
    geom_text(aes(label = round_hms(as_hms(average_ride_length), 1)), position = position_dodge(width = 0.9),
        hjust = -0.05, size = 3) + coord_flip() + labs(title = "Average Ride Length by Month in 2023",
    subtitle = "Casual Riders vs Members", x = "", y = "Ride Length", fill = "User Type") +
    theme_minimal() + theme(panel.grid.major.x = element_blank())
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-32-1.png)<!-- -->

### The top 10 starting  stations for casual riders


```r
top_10_starts_casuals <- cyclistic_2023_final %>%
    filter(user_type == "casual") %>%
    group_by(starting_station) %>%
    summarize(starts = n()) %>%
    drop_na() %>%
    top_n(10) %>%
    arrange(desc(starts)) %>%
    ggplot(aes(reorder(starting_station, starts), starts, fill = starts)) + geom_col() +
    geom_text(aes(label = scales::comma(starts)), hjust = -0.2) + coord_flip() +
    scale_fill_distiller(palette = "Blues", direction = 1) + labs(title = "Top 10 Starting Stations for Casual Riders",
    x = "", y = "Number of Casual Riders") + theme_classic() + theme(axis.text.x = element_blank(),
    axis.ticks.x = element_blank()) + guides(fill = "none")
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-33-1.png)<!-- -->

### The top 10 ending stations for casual riders


```r
top_10_ends_casuals <- cyclistic_2023_final %>%
    filter(user_type == "casual") %>%
    group_by(ending_station) %>%
    summarize(ends = n()) %>%
    drop_na() %>%
    top_n(10) %>%
    arrange(desc(ends)) %>%
    ggplot(aes(reorder(ending_station, ends), ends, fill = ends)) + geom_col() +
    geom_text(aes(label = scales::comma(ends)), hjust = -0.2) + coord_flip() + scale_fill_distiller(palette = "Blues",
    direction = 1) + labs(title = "Top 10 Ending Stations for Casual Riders", x = "",
    y = "Number of Casual Riders") + theme_classic() + theme(axis.text.x = element_blank(),
    axis.ticks.x = element_blank()) + guides(fill = "none")
```

![](cyclistic_2023_files/figure-html/unnamed-chunk-34-1.png)<!-- -->
