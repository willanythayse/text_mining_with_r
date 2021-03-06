## ESPM - MBA Big Data Aplicado ao Marketing - 1S2018
## An�lise de Redes Sociais e Text Mining - WC 6
## Prof. Gustavo Corr�a Mirapalheta

######################################################
# 6.1 - Ajuste de dados com tidyr
# 6.2 - Manipula��o de strings com stringr e detec��o 
#      de padr�es com regexps
######################################################

######################################################
######################################################
# - Aula 06 - 1a Parte
# - Ajuste de dados 
# - com tidyr
######################################################
######################################################

######################################################
#Dados tidy: uma observa��o por linha,
#            uma vari�vel por coluna
#            um valor por c�lula
######################################################
library(tidyr)

#Este data set est� "tidy"
View(table1)

#Este tem vari�veis nos valores de uma coluna
View(table2)

#Vamos ajusta-lo por uma opera��o de spread
spread(table2, key=type, value=count) -> table2a
View(table2a)

#Este tem valores diferentes em uma mesma coluna
View(table3)

#Vamos ajusta-lo por uma opera��o de separate
separate(table3, rate, 
         into = c("cases","population"), sep="/") -> table3a
View(table3a)

#Este tem valores similares em duas colunas
View(table5)

#Vamos ajusta-lo pela opera��o de unite
unite(table5, new, century, year) -> table5a
View(table5a)

unite(table5, new, century, year, sep="") -> table5b
View(table5b)

#Estes tem a mesma vari�vel dividida em duas colunas
#O nome da vari�vel � "year", por�m o significado � distinto
# por dataframe
View(table4a)
View(table4b)

#Vamos ajustar cada um deles por uma opera��o de gather
gather(table4a, "1999", "2000", 
       key="year", value="cases") -> table4a2
View(table4a2)

gather(table4b, "1999", "2000", 
       key="year", value="population") -> table4b2
View(table4b2)

#Vamos agora unir os dataframes por um left_join
left_join(table4a2, table4b2,  
          "country"="country", "year"="year") -> table5
View(table5)

#Wickham, Hadley R for Data Science, O'Reilly, 2016, cap.9
#pags 151, 156, 160, 163, 168
# OU
#Arquivo: 2.3-tidyr.docx

###########################################################
###########################################################
# - Aula 06 - 2a Parte
# - Manipula��o de strings com stringr 
# - e detec��o de padr�es com regexps
###########################################################
###########################################################

#Bibliotecas j� carregadas no script anterior:
library(tidytext)
library(dplyr)
library(stringr)

#Vamos agora introduzir o assunto regexps de maneira mais 
# extensa. Como pode ser visto, determinar um padr�o a ser 
# localizado em um texto � essencial para qualquer an�lise 
# do tipo Text Mining.

#Vamos ver agora exemplos de manipula��o de strings e seus
# caracteres especiais. As strings podem ser inseridas tanto
# com aspas duplas quanto simples.
string1 <- "This is a string"
string1

string1 <- 'This is a string'
string1

#Inser��o de aspas em uma string. Se a string for definida
# com aspas simples coloque aspas duplas e vice-versa
string2 <- 'Para colocar "entre aspas" dentro de uma string, use aspas simples'

#No terminal aparecem os caracteres de escape (as "\") 
string2

#No View() n�o
View(string2)

#Caso queira inserir aspas duplas como caracter dentro de uma
# string definida tamb�m com aspas duplas, as aspas duplas do
# tipo caracter dever�o ser "escapadas". Observe a seguir:
string3 <- "Esta string tem \"esta palavra\" entre aspas"

string3

View(string3)

#O mesmo crit�rio se aplica a uma string definida com aspas
# simples na qual se deseja inserir uma aspa simples como
# caracter
string4 <- 'Esta string tem \'esta palavra\' entre aspas'

string4

View(string4)

#De maneira similar para inserir uma barra invertida, a qual
# normalmente � um caracter de controle, precisamos escapa-la.
string5 <- "Esta string tem aqui \\ uma barra invertida"

string5

View(string5)

#Para apresentar no terminal do R apenas as strings sem os 
# seus caracteres de controle podemos utilizar a fun��o
# writeLines
writeLines(string1)
writeLines(string2)
writeLines(string3)
writeLines(string4)
writeLines(string5)

#A lista de caracteres de controle pode ser obtida 
# utilizando-se ?"'" ou ?'"'
?"'"

#Por exemplo para apresentar uma string "quebrada" em duas
# linhas podemos fazer:
nova_linha <- "Em uma linha \n Na outra linha"
writeLines(nova_linha)

#Ou para inserir uma tabula��o:
tabulacao <- "Texto antes \t Texto depois da tabula��o"
writeLines(tabulacao)

#Vamos agora conhecer algumas fun��es do pacote stringr

#Para obter comprimentos de string
str_length(c("a", "Minera��o de Texto", NA))

#Para combinar strings
str_c("x", "y", "z")

#Para combinar strings com um separador especial
str_c("x", "y", "z", sep=",")

#Observe o efeito de NA nas strings a seguir:
x <- c("abc", NA)
str_c("|-", x, "-|") #N�o � executada a opera��o de 
# concatena��o no 2o elemento de
# x pois o mesmo � um NA

#Para tratar NA como string use str_replace_na():
str_c("|-", str_replace_na(x), "-|")

#Para unir vetores de strings em uma �nica string
# utilize collapse = ","
str_c(c("x", "y", "z")) #Continua-se com 3 strings
str_c(c("x", "y", "z"), collapse=",") #Uma �nica string
#com os elementos separados por ,

#Para extrair partes de uma string use str_sub()
x <- c("Ma��", "Banana", "P�ssego")
str_sub(x, 1, 3)

#Observe uma forma de tornar as primeiras letras de cada
# uma das strings de x em letras min�sculas:
str_sub(x,1,1) -> x2 #Produz as primeiras letras das strings
x2

str_to_lower(x2) -> x3 #Transforma os caracteres de x2 em 
# letras min�sculas
x3

str_sub(x,1,1) <- x3 #Substitui o 1o caracter de cada string
# do vetor x pelo caracter em x3

#####################################################
#Regexps
#####################################################

#Para determinar onde um padr�o aparece em uma string
# utilize st_view()
x <- c("Ma��", "Banana", "P�ssego")
str_view(x, "an")

#Para detectar padr�es com coringas (similar ao *) da
# linha de comando do Windows, usamos o "."
str_view(x, ".a.")

#Para determinar o pr�prio "." como uma string ele
# precisa ser escapado. Portanto precisamos de "\.".
# Por�m para que a barra seja usada em combina��o com 
# o "." e n�o escapada, ela pr�pria precisa ser escapada
# portanto a sequ�ncia a ser utilizada � "\\.". Observe
# as diferen�as a seguir:

#Este detecta qualquer caracter entre a e c
str_view(c("abc", "a.c", "bef"), "a.c") 

#Este d� erro
str_view(c("abc", "a.c", "bef"), "a\.c")

#Este detecta a.c como string
str_view(c("abc", "a.c", "bef"), "a\\.c")

#Suponha que voc� quer uma string com a barra invertida 
# como caracter.

#Isto n�o ir� funcionar pois a barra simples � um escape
barra <- "Isto � uma \ barra"
barra
writeLines(barra)

#Precisamos escapar a pr�pria barra, portanto precisamos
# da barra dupla
barra2 <- "Isto � uma \\ barra"
barra2
writeLines(barra2)

#Para detectar a barra precisaremos escapar duas barras
# portanto precisamos de quatro barras

#str_view(barra2,"\") #Nem funciona pois estamos mandando
# escapar a segunda aspa

str_view(barra2,"\\") #ERRO

#str_view(barra2,"\\\") #Nem funciona!

str_view(barra2,"\\\\")

#Procuras a partir da esquerda:
x <- c("abacate", "banana", "p�ssego"); str_view(x, "^a")

#Procuras a partir da direita:
x <- c("abacate", "banana", "p�ssego"); str_view(x, "a$")

#Para detectar a palavra "Ma��" em qualquer posi��o
# de uma string
x <- c("Bolo de Ma��", "Ma��", "Torta de Ma��") 
str_view(x, "Ma��")

#Para detectar apenas palavra "Ma��":
x <- c("Bolo de Ma��", "Ma��", "Torta de Ma��")
str_view(x,"^Ma��$")

x <- c("Bolo de Ma��", "Ma�� Forte", "Torta de Ma��")
str_view(x,"^Ma��$")

#Outros caracteres especiais:
# "\d" encontra qualquer n�mero.
# "\s" encontra qualquer espa�o em branco 
#      (espa�o, tabula��o, nova linha).
# [abc] encontra a, b, ou c.
# [^abc] encontra qualquer string menos a, b, ou c.

#Operadores l�gicos: &=E, |=OU, !=N�O
# Este exemplo detecta Sao ou S�o
str_view(c("Sao Paulo", "S�o Paulo"), "S(a|�)o")

#Detec��o de repeti��es
x <- "1888 em romanos �: MDCCCLXXXVIII"

str_view(x,"CC+") #+: CC, 1 vez ou mais

str_view(x,"C[LX]+") #+: C e L ou X, 1 vez ou mais

str_view(x,"C{2}") # C exatamente 2 vezes 

str_view(x,"C{2,3}") # C 2 a 3 vezes

#Este script fez uma pequena introdu��o as regexps em R.
# Para estudo recomenda-se o site: https://regexr.com
