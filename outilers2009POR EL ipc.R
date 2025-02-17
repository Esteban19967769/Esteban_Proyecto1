#Para limpiar
rm(list=ls())

#Llamamos la base
library(haven)
casen2009 <- read_dta("C:/Users/ESTEBAN/Downloads/An�lisis exploratorios/segovia/casen2009stata.dta")
write_rds(casen2009stata, file="Casen2009.rds")
View(casen2009)


dimnames(casen2009)
#Para saber d�nde est�n las variables

##########################################################
#Agrego al jefe de hogar
casen_arbol09 <- casen2009[ , c(9,15, 18,19,20,24,297,300,304,342,344,354)]
#Me quedo con las variables:  zona, factor_expr, pco1, sexo, edad, numper, escolaridad, 
#actividad, decil, yataj autonomo, ytotaj total, allanamiento interno iai

########################################################
names(casen_arbol09) <-c("Zona","Factor_expansi�nr","Parentesco_jefehogar","Sexo","Edad"
                       ,"N�meros_per_hogar", "Escolaridad", "Condici�n_actividad","Decil", 
                       "Ingreso_aut�nomo", "Ingreso_total",
                       "Asigna_interno")
View(casen_arbol09)

#Sexo a variable cualitativa
casen_arbol09$Sexo = factor(casen_arbol09$Sexo, levels = c(1,2), labels = c("Hombre", "Mujer"))

#Reviso NA y los elimino
summary(casen_arbol09)
casen_arbol09na <- na.omit(casen_arbol09)
summary(casen_arbol09na)

#Boto bases que me estorban


rm(casen_arbol09)
rm(casen2009)


###############################################################

#Solo filtrar por decil 10
CASEN_ARBOLdecilm�srico09 <- casen_arbol09na[casen_arbol09na$Decil==10,]
summary(CASEN_ARBOLdecilm�srico09)

#Filtrar solo por jefe de hogar parentesco
CASEN_ARBOLdecilm�sricojefe09 <- CASEN_ARBOLdecilm�srico09[CASEN_ARBOLdecilm�srico09$Parentesco_jefehogar==1,] 
summary(CASEN_ARBOLdecilm�sricojefe09)

####################################################################

#Dejar entre 18 y 65 a�os, debo instalar paquete tidyverse y usar filter
install.packages("tidyverse")
library(tidyverse)
casen_decilyedad09 <- CASEN_ARBOLdecilm�sricojefe09 %>%  filter(Edad>=18 & Edad<=65) 
summary(casen_decilyedad09)


######################################################
#Crear variable IPC OCTUBRE 2009 A OCTUBRE 2020
#VARIACI�N DEL 27,7% https://calculadoraipc.ine.cl/
casen_decilyedad09 <- casen_decilyedad09%>%mutate(ing_total_IPC = Ingreso_total)

#A la base con la variable la escojo y de ah� <- multiplico 1,277
#Si no pongo $ing_total_IPC el comando elimina todo y me deja solo la transformaci�n
casen_decilyedad09$ing_total_IPC <- casen_decilyedad09$ing_total_IPC*1.277


rm(casen_arbol09na)
rm(CASEN_ARBOLdecilm�srico09)
rm(CASEN_ARBOLdecilm�sricojefe09)

#################################################################

#AN�LISIS EXPLORATORIO DE DATOS**********************
# analisis descriptivo de tablas de frecuencias, histogramas, correlaci�n , etc

library(dplyr)
library(ggplot2) 
library(readxl)
library(gmodels)
library(Hmisc)
library(ggthemes)
library(PerformanceAnalytics)

# eliminacion de valores at�picos
casen_decilyedad0 <- casen_decilyedad09 %>%  filter(Ingreso_aut�nomo>=750000) 

summary(casen_decilyedad0)

correlacion_base1 <- casen_decilyedad0[,-1]
correlacion_base2 <- correlacion_base1[,-1]
correlacion_base3 <- correlacion_base2[,-1]
correlacion_base4 <- correlacion_base3[,-1]
correlacion_base5 <- correlacion_base4[,-4]
correlacion_base6 <- correlacion_base5[,-4]
correlacion_base7 <- correlacion_base6[,-6]
correlacion_base8 <- correlacion_base7[,-4]
correlacion_base9 <- correlacion_base8[,-4]


#borrar
rm(correlacion_base1)
rm(correlacion_base2)
rm(correlacion_base3)
rm(correlacion_base4)
rm(correlacion_base5)
rm(correlacion_base6)
rm(correlacion_base7)
rm(correlacion_base8)

#chart de correlacion, se activa con dataanalytics paquete
chart.Correlation(correlacion_base9, method = "pearson")

summary(correlacion_base9)

#ver los cuantiles del ingreso
quantile(casen_decilyedad0$ing_total_IPC, prob=seq(0, 1, length = 11))



#Los cargo, SINO SIRVE EL C�DIGO SE DEBEN INSTALAR PREVIAMENTE CON INSTALL.PACKAGEsomg

library(rattle)
library(rpart.plot) 
library(rpart)                #Implementaci�n de cart
library(dplyr)
install.packages("caret")
install.packages("rsample")
library(rsample)
library(caret)                #Para dividir dataset
library(lattice)
library(ggplot2)
install.packages("survey")
library(survey)


###############################################################3

#Creo la semilla
set.seed(1000)

#Usamos la funci�n sample_frac() de dplyr para obtener un subconjunto de nuestros datos, que consiste en 70% del total de ellos. 
#Usamos tambi�n set.seed() para que este ejemplo sea reproducible.
#split_arbol <- initial_split(casen_decilyedad, prop = .8)
#datos_trainEscenario2 <- training(split_arbol)

#Con setdiff() de dplyr, obtenemos el subconjunto de datos complementario al de entrenamiento 
#para nuestro set de prueba, esto es, el 20% restante.
#datos_testEscenario2  <- testing(split_arbol)

#Con setdiff() de dplyr, obtenemos el subconjunto de datos complementario al de entrenamiento 
#para nuestro set de prueba, esto es, el 20% restante.


#########################################

split_arbol <- sample_frac(casen_decilyedad0, .8)

#Con setdiff() de dplyr, obtenemos el subconjunto de datos complementario al de entrenamiento 
#para nuestro set de prueba, esto es, el 20% restante.
arbol_prueba <- setdiff(casen_decilyedad0, split_arbol)

################################################################3

#Ahora revisamos �rbol con ingreso sin subsidios del Estado
arbol_yaut_anova09 <- rpart(formula = Ingreso_aut�nomo ~ Sexo+Edad+Escolaridad+N�meros_per_hogar+
                              Condici�n_actividad+Zona+Asigna_interno,
                            data = split_arbol, weights = Factor_expansi�nr,
                            method = "anova",  
               #minsplit #N�mero de observaciones m�nimas en nodo
               #minbucket #N�mero m�nimo de observaciones en nodo terminal, es la 1/3 de minsplit
               #maxdepth #n�mero m�ximo de observaciones que tendr� el �rbol
               
               #A menor maxdepth con muchas frecuencias, menos nodos
               #Y a mayor depth con muchas frecuencias, saldr�n miles de nodos
               
               #cp = complejidad de un �rbol, tama�o del �rbol para separar variables objetivos, un cp (-)
               #nos asegura un �rbol completamente crecido
               control = rpart.control(minsplit = 100, minbucket = 33, maxdepth = 2.5, cp = 0,01))

######################################################################

#modelo_multiple <- lm(formula = Ingreso_aut�nomo ~ Sexo+Escolaridad+N�meros_per_hogar, data = split_arbol)


#summary(modelo_multiple)
#Edad no es relevante porque se trabaja con la poblaci�n laboral activa entre 18-65 a�os

##################################################################

arbol_yaut_anova09
#Rel error=numero de elementos mal etiquetados en iteraci�n en relaci�n a los elementos mal etiquetados en la ra�z
#como regla general es mejor podar un �rbol usando el cp del �rbol m�s peque�o que est� dentro de una sd del arbol con xerror m�s peque�o


rpart.plot(arbol_yaut_anova09)

#gr�fica
#par(mfrow=c(2,2)); plotcp(arbol_yaut_class);  plotcp(arbol_yaut_anova); rpart.plot(arbol_yaut_class);rpart.plot(arbol_yaut_anova)
par(mfrow=c(1,2)); plotcp(arbol_yaut_anova09);rpart.plot(arbol_yaut_anova09)

#Ahora veremos el error del modelo
printcp(arbol_yaut_anova09)
#Segun los resultados de mi arbol, el mejor modelo a cp usar es 0.0013126



##################################################este no se USA

arbol_ytot_anova09 <- rpart(formula = Ingreso_total ~ Sexo+Edad+Escolaridad+N�meros_per_hogar+
                              Condici�n_actividad+Zona+Asigna_interno,
                            data = split_arbol, weights = Factor_expansi�nr,
                            method = "anova",  
                          control = rpart.control(minsplit = 100, minbucket = 33, maxdepth = 2.5, cp = 0,01))


#gr�fica
par(mfrow=c(1,2)); plotcp(arbol_ytot_anova09);rpart.plot(arbol_ytot_anova09)

######################################################3

#Ahora veremos el error del modelo
printcp(arbol_ytot_anova09)
#Segun los resultados de mi �rbol, el mejor modelo a cp usar es 0.001312


######################################################################
##ESTE SE USA###

arbol_ytotIPC_anova09 <- rpart(formula = ing_total_IPC ~ Sexo+Edad+Escolaridad+N�meros_per_hogar
                              ,
                            data = split_arbol, weights = Factor_expansi�nr,
                            method = "anova",  
                            control = rpart.control(minsplit = 100, minbucket = 33, maxdepth = 3, cp = 0,01))


#gr�fica
par(mfrow=c(1,2)); plotcp(arbol_ytotIPC_anova09);rpart.plot(arbol_ytotIPC_anova09)

######################################################3

#Ahora veremos el error del modelo
printcp(arbol_ytotIPC_anova09)
#Segun los resultados de mi �rbol, el mejor modelo a cp usar es 0











###############################################################################

#PREGUNTAS:
#Si minsplit supera la mitad del n�mero de observaciones se genera solo el tallo del �rbol
#Si minbucket supera la mitad de observaciones no se generan divisiones
#Todos los comandos de rpart.control nos permite un control del �rbol, sino ser�a 100% preciso

######################################################################

#La base llevarla a texto y en excel pasarla
write.csv(casen_decilyedad09, file="Casen_2009_Filtrada.txt")
write_rds(casen2009, file="Casen2009.rds")

quantile(casen_decilyedad0$Ing_aut�nomo, prob=seq(0, 1, length = 11))

quantile(casen_decilyedad0$ing_total_IPC, prob=seq(0, 1, length = 11))
