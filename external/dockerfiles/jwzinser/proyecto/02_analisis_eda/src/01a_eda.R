# 19/02/2017

library(tidyverse)
library(stringr)
library(lubridate)
library(reshape2)


# EDA inicial con 20 paginas


# 1. preparar datos ------------------------------------------------------------

df.listas <- read.csv("../datos/listverse_20pags.csv", stringsAsFactors = F)%>%
  dplyr::select(-page) %>% 
  mutate_each(funs(gsub("u'|'|,| \\]", "", .)) ) %>%
  mutate_each(funs(str_trim(.))) %>% 
  unique %>%
  mutate(author = ifelse(author == "u\"Bridget ORyan\"", "Bridget ORyan", author))

head(df.list %>% arrange(title) %>% data.frame())

df.list %>% dim
df.list$author %>% n_distinct() # 43 autores
df.list$date %>% n_distinct() # 46 días


# 2. Graficas ------------------------------------------------------------------
df.listas %>% 
  group_by(title.category, author) %>% 
  tally %>% 
  ggplot(aes(x = title.category, y = author, fill = n)) + 
  geom_tile() + 
  ylab("author") + 
  xlab("title category") +
  theme_bw() +
  theme(axis.text.x  = element_text(angle = 90, hjust = 1, vjust = 0)) +
  labs(title = "Frequency of lists by author and category")

df.listas %>%
  group_by(author) %>%
  tally %>%
  mutate(aux = "Number of lists") %>% 
  ggplot(aes(x = aux, y = n)) +
  geom_boxplot(fill = 'blue', alpha = 0.5) +
  theme_bw() +
  coord_flip() +
  xlab('') +
  ylab('') +
  labs(title = "Number of lists by author")
