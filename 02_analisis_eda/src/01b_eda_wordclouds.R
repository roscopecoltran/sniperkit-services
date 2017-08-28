# 24/02/2017


library(tidyverse)
library(stringr)
library(lubridate)
library(reshape2)
library(forcats)

library(tm)
library(wordcloud)
library(tokenizers)
library(tidytext)

theme_set(theme_minimal())

# conexión a la base de datos
my_db <- src_sqlite("../datos/listverse.db", create = T)
my_db

# tabla articles
articles <- tbl(my_db, sql("SELECT * FROM articles"))


# Número de categorías
tbl(my_db, sql("select category, count(*) as cnt from articles group by category")) %>% 
  collect() %>% 
  ggplot(aes(x = fct_reorder(category, cnt, mean), y = cnt)) + 
  geom_bar(stat = 'identity', fill = "red") + 
  geom_label(aes(y = cnt + 90, label = cnt), size = 3) + 
  coord_flip()  + 
  ylab("Número de listas") + 
  xlab(NULL)

tbl(my_db, sql("select author, count(*) as cnt from articles group by author")) %>% 
  collect() %>% 
  mutate(author = str_replace(tolower(author), " ", "" )) %>% 
  group_by(author) %>% 
  tally


# base de artículos con modificaciones
df.articles <- articles %>% 
  collect() %>% 
  mutate(author = str_trim(tolower(author)),
         body = str_trim(tolower(body)) )
dim(df.articles)
head(df.articles)
str(df.articles)

df.articles$date %>% head

nrow(df.articles) # 6589 listas
tt <- df.articles %>% 
  rowwise() %>% 
  summarise(len = str_length(body)) 
mean(tt$len)
median(tt$len)


tt <- df.articles %>% 
  rowwise() %>% 
  mutate(len = str_length(body)) %>% 
  ungroup %>% 
  group_by(category) %>% 
  summarise(prom = mean(len), 
            num = n())


saveRDS(df.articles, "cache/df.articles.RDS")
# df.articles <- read_rds("cache/df.articles.RDS")

# Wordcloud

body <- head(df.articles$body, 30)


words.excluded <- c('one', 'ones', 'also', 'any', 'anything',
                    'many', 'can', 'even', 'per', 'either', 'neither',
                    'thats', 'futher', 'futhermore', 'too', 'besides',
                    'however', 'meanwhile', 'must') 

Collapse_Body <- function(sub){
  body <- sub$body
  text.body <- paste(body, collapse = " ") 
  str_length(text.body)
  
  text.corpus <- Corpus(VectorSource(text.body))
  text.mod <- tm_map(text.corpus, stripWhitespace) %>% 
    tm_map(stemDocument, language = "english")  %>% 
    tm_map(removePunctuation) %>% 
    tm_map(removeWords, stopwords('english')) %>% 
    tm_map(removeWords, words.excluded)
  
  dtm <- TermDocumentMatrix(text.mod)
  m <- as.matrix(dtm)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)  
  d
}


# Collapse_Body(head(df.articles))
tab.freq <- df.articles %>% 
  filter(category == "Facts") %>% 
  do(fun = Collapse_Body(.))

tab.freq$fun[[1]] %>% head
tab.freq$fun[[1]]$freq %>% summary()
filter(tab.freq$fun[[1]], freq > 100) %>% dim
wordcloud(tab.freq$fun[[1]]$word, tab.freq$fun[[1]]$freq, min.freq = 400)


# Frecuencias por categorías
freqs.cat <- df.articles %>%
  group_by(category) %>%
  do(fun = Collapse_Body(.))



# Token


df.articles <- read_rds("cache/df.articles.RDS")
data("stop_words")

df.articles.row <- df.articles %>% 
  mutate(id.row = rownames(.)) 

stopwords.man <- stopwords() %>% 
  as_tibble() %>% 
  mutate(lexicon = "TM") %>% 
  rename(word = value) %>% 
  rbind(stop_words)

tab.cleaned <- df.articles.row %>% 
  dplyr::select(id.row, category, body) %>%
  # filter(category == "Crime") %>%
  unnest_tokens(word, body) %>%
  anti_join(stopwords.man, by = "word")

tab.cleaned %>% 
  count(word, sort = T)  %>% 
  with( wordcloud(word, n, max.words = 100))

WCSubset <- function(sub){
  png(file = paste0("graphs/wordclouds/",
                   unique(sub$category), ".png"))
  sub %>% 
    count(word, sort = T)  %>% 
    with( wordcloud(word, n, max.words = 100))
  dev.off()
  "."
}


tab.cleaned %>% 
  group_by(category) %>% 
  do(wc = WCSubset(.))

tab.cleaned %>% 
  full_join(get_sentiments("bin"))
get_sentiments("nrc") %>%
  filter(sentiment == "joy")
df.articles.row %>% filter(id.row == 4169) %>%  .$body