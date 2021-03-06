#### CRIANDO Dicionário De STOPWORD  ####
library(tidyverse)
library(data.table)
library(tidytext)
library(glue)
library(stringr)
library(stringi)
library(rvest)
library(ptstem)
library(wordcloud2)
library(tm)
library(ggplot2)
library(RColorBrewer)
library(wordcloud)

#Dicionário de Entrada
stopwordsArq <- read.csv(file.choose(), head=F, encoding = "UTF-8", sep="\t")
stopwordsArq_vet <- factor(stopwordsArq$V1)

#transformaando em um array de dicionário
stpW <- unlist(str_split(stopwordsArq_vet, '\\n'))
glimpse(stpW)
View(stpW)

#carregando o stopwords da tm
stpW2 <- stopwords('portuguese')
glimpse(stpW2)

#fazendo um merge
str(stpW)

#Unindo os dois dicionários, entrada(file) e tm
stpW_merged <- union(stpW,stpW2) 
summary(stpW_merged)

#Validando o merge para não haver duplicidade
tibble(word = stpW_merged) %>% 
  group_by(word) %>% 
  filter(n()>1)

#Removendo arquivos desnecessários...
rm(stopwordsArq)
rm(stopwordsArq_vet)
rm(stpW)
rm(stpW2)


#Carregando arquivo com palavras de sentimento https://www.kaggle.com/rtatman/sentiment-lexicons-for-81-languages/data
posW <- read.csv(file.choose(), header = F, sep = "\t", strip.white = F, 
                      stringsAsFactors = F, encoding="UTF-8")
View(posW)
negW <- read.csv(file.choose(), header = F, sep = "\t", strip.white = F, 
                      stringsAsFactors = F, encoding="UTF-8")
View(negW)

##Criando um dataframe que salvarei os termos começando pelos adjetivos negativos
dfPolaridades <- negW %>% 
  mutate(word = V1, polaridade = -1, tipo='adjetivo', sentimento='negativo') %>%
  select(word,polaridade,tipo,sentimento) %>%
  arrange(word)
head(dfPolaridades,2)


###aqui faço um count para poder adicionar os dados corretamente
#icount <-  length(exn$V1)
#dfPolaridades <- bind_rows(dfPolaridades,list(word = exn$V1, polaridade=rep(-1,icount),tipo=rep('expressao',icount),sentimento=rep('negativo',icount)))
#dfPolaridades %>% arrange(desc(word)) %>% head(3)

icount <-  length(posW$V1)
dfPolaridades <- bind_rows(dfPolaridades,list(word = posW$V1, polaridade=rep(1,icount),tipo=rep('noclass',icount),sentimento=rep('positivo',icount)))


#visualizando como está nosso dataframe
dfPolaridades %>% group_by(word) %>% filter(n() == 1) %>% summarize(n=n())

#Fazendo um contador na quantidade total de adjetivos negativos
dfPolaridades %>% count()


#Removendo adjetivo repetidos
dfPolaridadesUnique <- dfPolaridades[!duplicated(dfPolaridades$word),]
dfPolaridadesUnique %>% count()


#Importando arquivo para análise de sentimento 
arq_dom <- read.csv(file.choose(), head=F, encoding = "UTF-*", sep="\t")
View(arq_dom)

arq_dom_v <- VectorSource(arq_dom$V1)
################################################################
arq_dom_v_c <- Corpus(arq_dom_v)
arq_dom_v_c <- tm_map(arq_dom_v_c, tolower) #Se nao for UTF-8
##arq_dom_v_c <- tm_map(arq_dom_v_c, to_lower = TRUE) #Se nao for UTF-8
arq_dom_v_c <- tm_map(arq_dom_v_c, removePunctuation)
arq_dom_v_c <- tm_map(arq_dom_v_c, removeNumbers)
arq_dom_v_c <- tm_map(arq_dom_v_c, removeWords, stpW_merged)
arq_dom_v_c <- tm_map(arq_dom_v_c, removeWords, c('título','capítulo','copyright'))
View(arq_dom_v_c)

arq_dom_v_c <- sapply(arq_dom_v, function(x) stri_trans_tolower(x,'pt'))
arq_dom_v_c <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", " ",  arq_dom_v_c);
arq_dom_v_c <- str_replace(arq_dom_v_c,"RT @[a-z,A-Z]*: ","")
arq_dom_v_c <- gsub("@\\w+", "", arq_dom_v_c)
arq_dom_v_c <- str_replace_all(arq_dom_v_c,"@[a-z,A-Z]*","")  
arq_dom_v_c <- gsub("[^[:alnum:][:blank:]!?]", " ", arq_dom_v_c)
arq_dom_v_c <- gsub("[[:digit:]]", "", arq_dom_v_c)

length(arq_dom_v_c)
tibble(arq_dom_v_c) %>% unique() %>% count()
arq_dom_v_unique <- arq_dom_v_c %>% unique() 
length(arq_dom_v_unique)
arq_dom_v_uniqueSw <- tm::removeWords(arq_dom_v_unique,c(stpW_merged,'rt'))
tibble(arq_dom_v_uniqueSw)
ttokens <- data_frame(word = arq_dom_v_uniqueSw) %>% unnest_tokens(word,word)
ttplens1 <- ttokens %>% count(word, sort = T) 
View(ttokens_freq)

ttokens_filter <- ttplens1 %>% filter(nchar(word) > 2)
ttokens_filter1 <- ttokens_filter %>% count(word, sort=T)

ttokens_freq <- ttokens_filter1 %>% count(word, sort = T) %>% select(word, freq=n) 


wordcloud2(ttokens_freq , minSize = 1, size = 1, backgroundColor = 'black')

pal2 <- brewer.pal(8,"Dark2")

wordcloud(words =  ttokens_freq$word, freq = ttokens_freq$freq , min.freq = 8,  random.color = T, max.word = 200, random.order = T, colors = pal2)
#################################################################
dom_Unique <- arq_dom_v_c %>% unique(arq_dom_v_c) 
length(dom_Unique)
View(dom_Unique)
#dom_Unique_stpW <- tm::removeWords(dom_Unique,c(stpw_merged,'rt'))
#dados_arq_fil <- tm_map(dom_Unique, stpw_merged)
tibble(dom_Unique)

td_mtx <- TermDocumentMatrix(arq_dom_v_c, control = list(minWordLength = 3))
View(df)
v <- sort(rowSums(as.matrix(td_mtx)), decreasing=TRUE) #ordena as palavras
df <- data.frame(word=names(v), freq=v) #organiza um novo banco
df_total <- df %>%  summarize(total = sum(df$freq))
df
df_total
View(df_total)
temple.sorted.dom<-paste(names(v), v, sep=";")
cat("Palavras - FREQUencias", temple.sorted.dom, file="anuncio.txt", sep="\n")

ggplot(df)
pal1 <- brewer.pal(12,"Paired")
pal3 <- brewer.pal(12,"Set3")

WC<- wordcloud(df$word, df$freq, min.freq=100,
               max.words=Inf, random.order=FALSE, 
               rot.per=.34,colors=pal1)
#count_df <- count(df)
df_fil <- filter(df, df$freq>100)
hist(df$freq)
plot(df$freq, df$word fill = (df$freq>100)
View(df_fil)
cbind(names(df),as.integer(df$word))


ggplot(df$word, aes(df$freq/df_total) +
  geom_histogram())

  +
  facet_wrap(~word, ncol = 2))


ttokens <- data_frame(word = df) %>% unnest_tokens(word,word)
df %>% count(word, sort = T) 
View(df)
