#https://github.com/animesh/love-actually-network
library(dplyr)
library(stringr)
library(tidyr)
raw <- readLines("matrix_97_draft.txt")
lines <- data_frame(raw = raw) %>%
  filter(raw != "", !str_detect(raw, "(song)")) %>%
  mutate(is_scene = str_detect(raw, " Scene "),
         scene = cumsum(is_scene)) %>%
  filter(!is_scene) %>%
  separate(raw, c("speaker", "dialogue"), sep = ":", fill = "left") %>%
  group_by(scene, line = cumsum(!is.na(speaker))) %>%
  summarize(speaker = speaker[1], dialogue = str_c(dialogue, collapse = " "))
cast <- read.csv(url("http://varianceexplained.org/files/love_actually_cast.csv"))
lines <- lines %>%
  inner_join(cast) %>%
  mutate(character = paste0(speaker, " (", actor, ")"))
by_speaker_scene <- lines %>%
  count(scene, character)
by_speaker_scene
norm <- speaker_scene_matrix / rowSums(speaker_scene_matrix)
h <- hclust(dist(norm, method = "manhattan"))
plot(h)
ordering <- h$labels[h$order]
ordering
scenes <- by_speaker_scene %>%
  filter(n() > 1) %>%        # scenes with > 1 character
  ungroup() %>%
  mutate(scene = as.numeric(factor(scene)),
         character = factor(character, levels = ordering))

ggplot(scenes, aes(scene, character)) +
  geom_point() +
  geom_path(aes(group = scene))
non_airport_scenes <- speaker_scene_matrix[, colSums(speaker_scene_matrix) < 10]

cooccur <- non_airport_scenes %*% t(non_airport_scenes)

heatmap(cooccur)

final_reviews <- data.frame(comments = x$data)
ds <- final_reviews$comments.text
dst<-paste(ds,collapse=" ")
dstc<-strsplit(dst," ")
dstcT<-table(dstc)
#https://cran.r-project.org/web/packages/tm/vignettes/tm.pdf
docs <- VCorpus(VectorSource(dstc))
#https://towardsdatascience.com/create-a-word-cloud-with-r-bde3e7422e8a
install.packages("tm")
install.packages("wordcloud")
install.packages("RColorBrewer")
library(tm)
library(wordcloud)
library(RColorBrewer)
docs <- docs %>% tm_map(removePunctuation) %>%  tm_map(stripWhitespace)
docs <- tm_map(docs, content_transformer(tolower))
#myWords=c("format", "paperback", "kindle", "edit", "hardcov", "book", "read", "will", "just", "can", "much")
#sapiens_corpus <- tm_map(sapiens_corpus, removeWords, c(stopwords("english"), myWords))
#sapiens_corpus = tm_map(sapiens_corpus, removeNumbers)
docs <- tm_map(docs, removeWords, stopwords("english"))
dtm <- TermDocumentMatrix(docs)
matrix <- as.matrix(dtm)
words <- sort(rowSums(matrix),decreasing=TRUE)
df <- data.frame(word = names(words),freq=words)
write.csv(df,"wordCloud.csv")
wordcloud(words = dstc, min.freq = 1, max.words=200, random.order=FALSE, rot.per=0.35,colors=brewer.pal(8, "Dark2"))
wordcloud(words = dstc, freq = dstcT, min.freq = 1, max.words=200, random.order=FALSE, rot.per=0.35,colors=brewer.pal(8, "Dark2"))
set.seed(42) # for reproducibility
wordcloud(words = df$word, freq = df$freq, min.freq = 1,           max.words=200, random.order=FALSE, rot.per=0.35,            colors=brewer.pal(8, "Dark2"))
#https://r-tastic.co.uk/post/amazon-reviews-word-cloud/
## treat pre-processed documents as text documents
#sapiens_corpus <- tm_map(sapiens_corpus, PlainTextDocument)
df2<-read.csv("wordCloud.csv",header = T, row.names = 1)
pal=RColorBrewer::brewer.pal(9, "Set1")
wordcloud::wordcloud(words = df2$word, freq = df2$freq, max.words=1000,colors=pal,random.order=FALSE)

