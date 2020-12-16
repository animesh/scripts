#https://github.com/animesh/wisecreator
install.packages("epubr")
x <- epubr::epub("C:\Users\animeshs\GD\Kindle\My Kindle Content\B08FJ55GFG_EBOK\B08FJ55GFG_EBOK.epub")
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

