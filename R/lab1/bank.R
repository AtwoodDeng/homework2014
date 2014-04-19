library(ggplot2)
library(randomForest)
library(colorspace)
library(seriation)

bank=read.table("bank-full.csv",header=TRUE,sep=";")

###### distribution analysis ############
#age
p <- (data=bank,aes(x=age,fill=factor(y)))
p + geom_bar(position='dodge')+opts(title = "distrubution of ages of clients")
ageBank = bank[bank$age<51&bank$age>24,]
p <- ggplot(data=ageBank,aes(x=age,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of ages(between 25 and 50) on term deposit")

#job
p <- ggplot(data=bank,aes(x=job,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of jobs on term deposit")

#martial
p <- ggplot(data=bank,aes(x=marital,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of marital on term deposit")

#education
p <- ggplot(data=bank,aes(x=education,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of education on term deposit")

#default
p <- ggplot(data=bank,aes(x=default,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of credit in default on term deposit")

#house
p <- ggplot(data=bank,aes(x=housing,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of housing loan on term deposit")

#loan
p <- ggplot(data=bank,aes(x=loan,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of personal loan on term deposit")

#campaign
p <- ggplot(data=bank[bank$campaign<=20,],aes(x=campaign,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of contact times on term deposit")

#month
p <- ggplot(data=bank,aes(x=month,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of month on term deposit")

#duration
p <- (data=bank,aes(x=duration,fill=factor(y)))
p + geom_bar(position='dodge')+opts(title = "distrubution of duration of clients")
ageBank = bank[bank$age<51&bank$age>24,]
p <- ggplot(data=bank[bank$duration<1000,],aes(x=duration,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of durationon on term deposit")


########### scatter plot #############
# pdays and previous
p<-ggplot(data=bank[bank$previous<100,],mapping = aes(x=pdays,y=previous,colour=y))
p+geom_point()+opts(title="Influence of previous and pdays on y")

# balance and duration
p<-ggplot(data=bank,mapping = aes(x=duration,y=balance,colour=y))
p+geom_point()+opts(title="Influence of balance and duration on y")

# days
p<-ggplot(data=bank,mapping = aes(x=day,y=duration,colour=y))
p+geom_point()+opts(title="Influence of day on y")


########### correlation matrix #############
# correlation matrix
matrix = as.matrix(data.frame(
  bank$age,
  as.numeric(bank$job),
  as.numeric(bank$marital),
  as.numeric(bank$education),
  as.numeric(bank$default),
  bank$balance,
  as.numeric(bank$housing),
  as.numeric(bank$loan),
  as.numeric(bank$contact),
  bank$duration,
  bank$campaign,
  bank$previous,
  as.numeric(bank$y)
));
corm <-cor(matrix);
pimage(corm, 
       main="Correlation matrix", 
       #c("age","job","marital","education","default","balance","housing","loan","contact","duration","campaign","previouse","y"),
       colorkey=TRUE, range=c(-1,1), col=diverge_hcl(100));

# correlation
ycorm <- corm[13,1:12];
barplot(ycorm,main="correlation of the attributes",col=diverge_hcl(12));

# in order 
abs_ycorm <- abs(ycorm);
order_ycorm <- ycorm[order(abs_ycorm,decreasing=T)]
barplot(order_ycorm[1:6],main="Main Features",col=diverge_hcl(6));
show(order_ycorm)

######## Random Tree #############
bank=read.table("bank.csv",header=TRUE,sep=";")
RandomForest <- randomForest(y ~ ., data=bank, ntree=30, nPerm=10,mtry=3,proximity=TRUE,importance=TRUE)
show(RandomForest)

plot(RandomForest)

# predict contact
bankContact = bank[bank$contact!="unknown",];
rfContact<- randomForest(contact ~ ., data=bank, ntree=30, nPerm=10,mtry=3,proximity=TRUE,importance=TRUE)
preContact <-predict(rfContact)
