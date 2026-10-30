#install.packages("rvest")
#install.packages("readr")
#install.packages("tidyverse")

#Read in libraries
library(rvest)
library(readr)
library(tidyverse)

#Webscrape data from wikipedia
url <- "https://en.wikipedia.org/wiki/Tony_Award_for_Best_Musical"
page <- read_html(url)
tables <- page %>% html_table(fill = TRUE)

#Create tables for each decade and combine into one large table
df40 <- tables[[2]]
df50 <- tables[[3]]
df60 <- tables[[4]]
df70 <- tables[[5]]
df80 <- tables[[6]]
df90 <- tables[[7]]
df00 <- tables[[8]]
df10 <- tables[[9]]
df20 <- tables[[10]]

df <- bind_rows(df40, df50, df60, df70, df80, df90, df00, df10, df20)

df

clean_df <- df |> 
  #Drop empty rows
  drop_na() |> 
  
  #Clean Year Column
  mutate(Year = str_sub(clean_df$`Year`, 1, 4)) |> 
  
  #Create a win column by indicating first listed musical for each year
  group_by(Year) |> 
  mutate(Win=if_else(row_number() == 1, 1, if_else(str_detect(Musical,"TIE"),1,0))) |> 
  ungroup() |> 
  
  #Establish comma as name delimiter in Producer(s)
  mutate(`Producer(s)` = str_replace_all(`Producer(s)`, ",? and|,? &", ", ")) |> 
  
  #
  mutate(Musical_Name=str_split_i(Musical, "(\\(TIE|Book,|Based|Book &|Book by|Book and|Story|Directed|Conceived|Music by|Music &|Choreography)",1)) |> 
  mutate(Book_By = str_replace_all(str_split_i(Musical, "(Book by|Book and Lyrics by|Book & Music by|Book & Lyrics by| ?Book, Music,? & Lyrics by|Book & New Lyrics by)", 2) |> 
           str_split_i("(, Music|, Based|, New|, Lyrics|; Music)",1), ",? and|,? &", ", ")) |> 
  mutate(Music_By= str_replace_all(str_split_i(Musical,"(Music by|Music & lyrics by|Music & Lyrics by| ?Book, Music,? & Lyrics by)",2) |> 
           str_split_i("(, Lyrics by|, Adaptation|, English|English|, Additional|, Revised|, New)",1),",? and|,? &", ", ")) |> 
  mutate(Lyrics_By = str_replace_all(str_split_i(Musical, "(Music & lyrics by|Music & Lyrics by| ?Book, Music,? & Lyrics by|Lyrics by)", 2) |> 
           str_split_i("(, Music|, Additional|, New|, Revised|; Music)",1), ",? and|,? &", ", ")) |> 
  select(Year, Win, Musical_Name, Book_By, Music_By, Lyrics_By, `Producer(s)`)

clean_df

new_dat <- clean_df |> 
  drop_na() |> 
  separate_longer_delim(Music_By, delim=regex(", ", ignore_case=TRUE))

winner_dat <- new_dat |> 
  group_by(Music_By) |> 
  drop_na() |> 
  filter(Music_By!=" Various Artists") |> 
  summarize(wins=sum(Win)) |> 
  arrange(desc(wins)) 

winner_dat

winner_dat |> 
  slice(1:20) |> 
  ggplot(aes(wins, fct_reorder(Music_By, wins))) + geom_point() + labs(y="Composer", x="Total Wins")

nom_dat <- new_dat |> 
  filter(Music_By !=" Various Artists") |> 
  group_by(Music_By) |> 
  drop_na() |> 
  summarize(noms=n()) |> 
  arrange(desc(noms)) 

nom_dat 

nom_dat |> 
  slice(1:20) |> 
  ggplot(aes(noms, fct_reorder(Music_By, noms))) + geom_point() + labs(y="Composer", x="Total Nominations") + scale_x_continuous(limits=c(2,12), breaks = seq(2, 12, by = 1))

ratio_dat <- new_dat |> 
  group_by(Music_By) |> 
  drop_na() |> 
  summarize(win_ratio=ifelse(n()>1,sum(Win)/n(),0)) |> 
  arrange(desc(win_ratio))

ratio_dat

ratio_dat |> 
  slice(1:20) |> 
  ggplot(aes(win_ratio, fct_reorder(Music_By, win_ratio))) + geom_point() + labs(y="Composer", x="Win Ratio")

