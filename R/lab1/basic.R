library(colorspace)
library(seriation)
library(MASS)

bank=read.table("bank.csv",header=TRUE,sep=";")
yesBank=bank[bank$y=='yes',]
noBank=bank[bank$y=='no',]

#show the individual attribution in bar
# age for y == yes and y == no
#barplot(table(yesBank$age),main="age of the clients who subscribed",xlab="age",ylab="number",col=sequential_hcl(70));
#barplot(table(noBank$age),main="age of the clients who did not subscribe",xlab="age",ylab="number",col=sequential_hcl(60));
barplot(table(bank$y,bank$age),add=TRUE,main="age of the clients",xlab="balance",ylab="number",breaks=50,col=diverge_hcl(50));

#job
barplot(table(bank$y,bank$job),main="job of the clients",xlab="job",ylab="number",col=diverge_hcl(2),legend.text=c("no","subscribed"),args.legend = list(bty = "n",horiz = TRUE));

legend("topright", legend=c("no","subscribed"), fill=diverge_hcl(2),inset=c(0.1,0.1))
#marital
barplot(table(bank$marital),main="marital of the clients",xlab="marital",ylab="number",col=rainbow_hcl(3));
#education
barplot(table(bank$education),main="education of the clients",xlab="education",ylab="number",col=c("#EEB422","#FFC125","#EEDC82"));
#default
barplot(table(bank$default),main="the clients in creadit",xlab="in credit?",ylab="number",col=c("#EEB422","#FFC125","#EEDC82"));
#balance
#barplot(table(bank$balance),main="average yearly balance of the clients",xlab="balance",ylab="number",col=c("#EEB422","#FFC125","#EEDC82"));
hist(bank$balance,main="average yearly balance of the clients",xlab="balance",ylab="number",breaks=300,col="gray");
#house
barplot(table(bank$housing),main="the clients has housing loan",xlab="has housing loan?",ylab="number",col=c("#EEB422","#FFC125","#EEDC82"));
#loan
barplot(table(bank$loan),main="the clients has personal loan",xlab="has personal loan?",ylab="number",col=c("#EEB422","#FFC125","#EEDC82"));
#previous
barplot(table(bank$previous),main="number of contacts to the clients",xlab="contact times",ylab="number",col=diverge_hcl(10));
#poutcome
barplot(table(bank$poutcome),main="outcome of the last campaign",xlab="if outcome",ylab="number",col=c("#EEB422","#FFC125","#EEDC82"));



#Scatter Diagram
#scatter<-data.frame(bank$previous,bank$y);
#pairs(scatter, main = "the relation of the attributions of the clients", pch = 20, bg = c("light blue"))

#pairs(scatter, main = "the attributions of the clients who has been contacted ", pch = 20, bg = c("light blue"))

#Correlation Matrix
#balance cor duration
#pmatrix=data.frame(bank$duration,bank$age,bank$pdays)
#matrix=as.matrix(pmatrix[pmatrix$bank.pdays!=-1,]);
#cm <-cor(t(pmatrix));
#pimage(cm,main="Correlation matrix of attributions", 
#       colorkey=TRUE, range=c(-1,1), col=diverge_hcl(100));

#SVM
#x <- cbind(matrix(bank$age), matrix(factor(bank$job)));
#y <- matrix(bank$yy);
#svp <- ksvm(x, y, type = "C-svc", kernel = "rbfdot", kpar = list(sigma = 2));
#plot(svp);

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

ycorm <- corm[13,1:12];
barplot(ycorm,main="correlation of the attributes",col=diverge_hcl(12));

abs_ycorm <- abs(ycorm);
order_ycorm <- ycorm[order(abs_ycorm,decreasing=T)]
order_ycorm <- order_ycorm[1:6];
barplot(order_ycorm,main="main features",col=diverge_hcl(6));


matrix = as.matrix(data.frame(
  as.numeric(bank$housing), 
  as.numeric(bank$contact),
  bank$duration,
  bank$previous,
  as.numeric(bank$y)-1
));
#mcorm <-cor(t(matrix));
#pimage(mcorm, 
#       main="Correlation matrix of main features", 
       #c("age","job","marital","education","default","balance","housing","loan","contact","duration","campaign","previouse","y"),
#       colorkey=TRUE, range=c(-1,1), col=diverge_hcl(100));

# standard deviation
matrix = as.matrix(data.frame(
  as.numeric(bank$housing), 
  as.numeric(bank$contact),
  bank$duration,
  bank$previous,
  as.numeric(bank$y)-1
));
sd<-scale(matrix);
pimage(sd, ylab="", 
       main="Standard deviations from the feature mean", 
       range=c(-2,2), col=diverge_hcl(100), colorkey=TRUE)


#parallel coordinate plots
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
parcoord(matrix,col=c("red","blue"));
legend('topright',c('no','yes'),col=c("red","blue"));






