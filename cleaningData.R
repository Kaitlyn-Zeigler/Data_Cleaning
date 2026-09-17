#install.packages("rvest")
#install.packages("readr")
#install.packages("tidyverse")

library(rvest)
library(readr)
library(tidyverse)

url <- "https://en.wikipedia.org/wiki/Tony_Award_for_Best_Musical"

page <- read_html(url)

tables <- page %>% html_table(fill = TRUE)

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

