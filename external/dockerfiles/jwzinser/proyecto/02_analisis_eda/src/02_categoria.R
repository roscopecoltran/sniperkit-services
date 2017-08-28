# 20/03/2017

library(tidyverse)
library(magrittr)
library(stringr)
library(lubridate)
library(reshape2)
library(forcats)

library(tidytext)
library(tm)
library(tokenizers)
library(wordcloud)

library(ape)
library(ggdendro)

theme_set(theme_minimal())
data("stop_words")
stopwords.man <- stopwords() %>% 
  as_tibble() %>% 
  mutate(lexicon = "TM") %>% 
  rename(word = value) %>% 
  rbind(stop_words)

mypal <- c("#556270", "#4ECDC4", "#1B676B", "#FF6B6B", "#C44D58",
           "#c6f2e1", "#c6e1f2", "#ffc14c", "#c6d2f2", "#ff7e52",
           "#f69640", "#205090", "#f8c080", "#585060")



# conexión a la base de datos
my_db <- src_sqlite("../datos/listverse.db", create = T)
my_db

# tabla articles
articles <- tbl(my_db, sql("SELECT * FROM articles")) %>% 
  collect() 

df.articles <- articles %>% 
  dplyr::select(-url) %>% 
  mutate_at(.funs = tolower, .cols = c("author", "body")) %>% 
  mutate_at(.funs = str_trim, .cols = c("author", "body")) %>% 
  mutate(author = gsub("[[:punct:]]", "", author),
         date = gsub("[[:punct:]]", "", date)) %>% 
  separate(date, c("month", 'day', 'year'), sep = " ") %>% 
  mutate_at(.funs = parse_number, .cols = c('day', 'year')) %>% 
  mutate(month = factor(month, levels = month.name), 
         month.num = as.numeric(month), 
         date.f = mdy(paste(month.num, day, year))) %>% 
  arrange(date.f) %>% 
  mutate(id.lista = rownames(.))

apply(is.na(df.articles), 2, sum)
n_distinct(df.articles$author) # 1165 autores diferentes
length(unique(df.articles$category)) # 29 categorías
summary(df.articles$date.f) # 01 julio 2007 a 28 febrero 2017

df.articles %>% 
  dplyr::select(-body)


# categoria
tab.cat <- df.articles %>% 
  dplyr::select(category, body) %>%
  unnest_tokens(word, body) #%>%
  # anti_join(stopwords.man, by = "word")
dim(tab.cat)
tab.cat

Lump_words <- function(sub){
  sub %>% 
    group_by(category, word) %>% 
    tally %>% 
    arrange(desc(n)) %>% 
    .[1:100, ]
}

tab.freq <- tab.cat %>% 
  group_by(category) %>%
  do(sub = Lump_words(.))

tab.spread <- tab.freq$sub %>% 
  bind_rows() %>% 
  ungroup %>% 
  spread(word, n, fill = 0) 

hc.mat <- tab.spread[, -1] %>% 
  as.matrix()
row.names(hc.mat) <- tab.spread$category

dist.mat <- dist(hc.mat, method = "manhattan")
hc.cats <- hclust(dist.mat, method = "ward.D2")

plot(hc.cats, labels=tt.mat$category,
     col = "#487AA1", col.main = "#45ADA8", col.lab = "#7C8071", 
     col.axis = "#F38630", sub = "", axes = FALSE)#, hang = -1)
rect.hclust(hc.cats, k = 13, border="#f69640")

clus5 <- cutree(hc.cats, 13)
plot(as.phylo(hc.cats), type = "fan", cex = 1.5,
     tip.color = mypal[clus5], label.offset = 1, 
     col = "#487AA1")


