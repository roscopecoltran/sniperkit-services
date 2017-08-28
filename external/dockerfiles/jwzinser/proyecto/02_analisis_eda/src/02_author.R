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


# autor
tab.aut <- df.articles %>% 
  unnest_tokens(word, body)
dim(tab.aut)
tab.aut


Lump_words <- function(sub){
  sub %>% 
    group_by(author, word) %>% 
    tally %>% 
    arrange(desc(n)) %>% 
    .[1:100, ]
}
tab.freq <- tab.aut %>% 
  group_by(author) %>%
  do(sub = Lump_words(.))

tab.spread <- tab.freq$sub %>% 
  bind_rows() %>% 
  ungroup %>% 
  filter(word != "", 
         !is.na(word)) %>% 
  spread(word, n, fill = 0) 
names(tab.spread)
dim(tab.spread) # 1165 10885
tab.spread$autor <- tab.spread$author

tab.measures <- tab.aut %>% 
  group_by(author, id.lista, category, date.f) %>% 
  summarise(words.num = n(),
            words.unique = length(unique(word)),
            type.token.r = words.unique/words.num) %>% 
  group_by(author) %>% 
  summarise(cats.num = n_distinct(category)/29,
            words.num = mean(words.num),
            type.token.r = mean(type.token.r),
            min.date = min(date.f), 
            max.date = max(date.f),
            time.writing =  (max.date-min.date)+1,
            listas.num = n_distinct(id.lista)
            ) %>% 
  dplyr::select(-min.date, -max.date) %>% 
  ungroup() 
tab.measures$autor <- tab.measures$author

tt <- tab.spread %>% 
  left_join(tab.measures, by = "autor")

mat.cent <- tab.measures %>% 
  dplyr::select(-author, -autor) %>% 
  scale(.) %>% 
  as.matrix

row.names(mat.cent) <- tt$autor

dist.mat <- dist(mat.cent, method = "euclidean")
hc.aut <- hclust(dist.mat, method = "ward.D2")

cutree(hc.aut, k = 10) %>% table()
plot(hc.aut, cex = .3,
     col = "#487AA1", col.main = "#45ADA8", col.lab = "#7C8071", 
     col.axis = "#F38630", sub = "", axes = FALSE)#, hang = -1)
rect.hclust(hc.aut, k = 13, border="#f69640")

# ggdendrogram(hc.aut, rotate = TRUE, size = 4, theme_dendro = FALSE, color = "tomato")
gpos.vec <- cutree(hc.aut, k = 10)
tab.gpos <- data.frame(
    clust.g10 = gpos.vec,
    autor = names(gpos.vec)
  ) %>% 
  as_tibble() %>% 
  mutate(autor = as.character(autor))

tab.measures.gpos <- tab.measures %>% 
  left_join(tab.gpos, by = 'autor')
filter(tab.measures.gpos, clust.g10 == 10)

tab.summ <- tab.measures.gpos %>% 
  group_by(clust.g10) %>% 
  summarise_at(.funs = mean, .cols = c("cats.num", "words.num",
                                       "type.token.r",
                                       "time.writing", "listas.num"))
tab.summ %>% 
  round(2) %>% 
  write.table(sep = ";", row.names = F)

pc.gpos <- princomp(tab.summ[, -1], cor = T)
ggbiplot(pc.gpos, labels = 1:10, labels.size = 6, varname.size = 5)  + 
  ylim(-3, 3)






