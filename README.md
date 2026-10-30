# Data_Cleaning

Data from: https://en.wikipedia.org/wiki/Tony_Award_for_Best_Musical

My goal in using this dataset was three-fold: to determine the composer with the most
Best Musical nominations, to determine the composer with the most wins, and to calculate the highest win-ratio. 
In order to complete this task, the dataset would require much cleaning.

The dataset itself comes from Wikipedia and lists every musical that was nominated for the Best Musical 
award each year at the Tony Awards. This information is divided into separate tables by decade and spans
from the 1940s to present day, which results in 9 separate tables. I then used bind_rows to combine each decade's 
information into one single dataframe, which I called "df". The table had three columns: Year, Musical (which 
contained the title as well as creator, composer, lyricist, choreographer, etc.), and Producer(s). 

When read in from Wikipedia, each year had a row of only N/A values so I began with dropping all n/a
rows. Additionally, many of the years had additional information that wasn't useful so I shortened the
string to only include the first 4 characters (leaving just the numeric year). The next issue was that 
there was no column to indicate the winner for each year--in Wikipedia, the winner was simply the first listed
for the given year and was highlighted in blue. Thus, I grouped the musicals by year and checked for the first
row in each group. In a mutated "Win" column, these would be indicated with a 1, while the losers would be indicated
with a 0. I also had to take into account one exception in 1960 when there was a tie (this was done with an
ifelse statement to check for and extract the string "TIE" from the Musical column). Finally, in order to 
establish some consistency in the Producer(s) column, I replaced all "and"s and "&" with commas so that each
name in the column used the same delimiter.

After cleaning Year and Producer(s) and adding the Win column, I next focused on the Musical column, which would require
a lot of work to clean. The Musical column contained a lot of different information so I had to decide
which information to keep, which to drop, and how to arrange it. I knew that I would keep the musical name as
its own column, and since most rows also included "Book by", "Music by", and "Lyrics by" information, I decided
to make those each their own column as well. Some of the other information like "Choreographed by" and "Directed by" was
included for just a few of the musicals so I dropped it (as the vast majority of musicals would have n/a for that column). 
Finally, there were a few musicals that didn't indicate book, music, or lyrics but simply stated "Conceived By". In this special 
case, I allowed for N/A values in the other columns but didn't make a "Conceived by" column. In order to actually separate
the data, I had to layer several str_split_i() functions together and check for several different keywords. 
This was because the information was stored very inconsistently. While some stored "Book by ..., Music by..., 
Lyrics by..." others stored things like "Book & Lyrics by ..., Music by ...", and there were many other formats as well.
So to pull out "Music by" for example, I would have to split every string by one of the "Music by" keywords, then take 
the section after that keyword and split it by any other keyword (like lyrics), and take the first section of that split.
This is how I was able to get the three different columns. For each of these, I also kept the comma delimiter to establish
consistency in columns with several names. 

I decided to maintain several names in a column for my clean data since I didn't want to have multiple repeated Musicals in 
the dataset. So, in order to answer my initial questions, I created a new dataset where I did split the Music_By column by comma
in order to get one composer per row. I could then group by composer to easily calculate wins, nominations, and win-ratio for each
composer (using my added win column) and plot the top scores on a graph. Some minor choices I made when doing so: I filtered out any composer that
was "Various Artists" and I only calculated win-ratio for composers who had more than one musical nominated (there were several composers
that only had one musical and won so would technically have a 100% win-rate, I wasn't focusing on this subset of the data). In the end, 
I found that Stephen Sondheim had the most wins at 5 but the second-most nominations at 9, meaning that his win-ratio was only about
55.5%, lower than several other composers. And while John Kander had the most nominations, he wasn't even in the top 20 for wins or win-ratio.
I wouldn't have been able to come to any of these conclusions or create these graphs before cleaning the data.

There were a few notable limitations to my process:
* Since the data in the musical column was so inconsistent, I can't guarentee that the data was split the correct way every single time and for
every possible format (though I'm pretty confident that I was successful overall).
* There are some instances in which a full name is given for one column but only the last name for another column due to the way that the
information was stored initially; For example: "Juan DarienBook by Elliot Goldenthal and Julie Taymor, Music & Lyrics by Goldenthal" was 
correctly split into Book as "Elliot Goldenthal, Julie Taymor" but Music_By and Lyrics_By only had "Goldenthal". It was difficult to attempt to replace
the surname with the full name.
