library(ggplot2)

bank=read.table("bank-full.csv",header=TRUE,sep=";")
yesBank=bank[bank$y=='yes',]
noBank=bank[bank$y=='no',]

#age
#with(bank,table(job,y))
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
p + geom_bar(position='fill')+opts(title = "Influence of marital on term deposit")

#default
p <- ggplot(data=bank,aes(x=default,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of credit in default on term deposit")

#balance
#p <- ggplot(data=bank,aes(x=balance,fill=factor(y)))
#p + geom_bar(position='dodge')+opts(title = "Influence of average yearly balance on term deposit")

#house
p <- ggplot(data=bank,aes(x=housing,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of housing loan on term deposit")

#loan
p <- ggplot(data=bank,aes(x=loan,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of personal loan on term deposit")

#campaign
p <- ggplot(data=bank,aes(x=campaign,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of contact times on term deposit")

#duration
p <- (data=bank,aes(x=duration,fill=factor(y)))
p + geom_bar(position='dodge')+opts(title = "distrubution of duration of clients")
ageBank = bank[bank$age<51&bank$age>24,]
p <- ggplot(data=bank[bank$duration<1000,],aes(x=duration,fill=factor(y)))
p + geom_bar(position='fill')+opts(title = "Influence of durationon on term deposit")

