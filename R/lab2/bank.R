library(rminer)
library(DMwR)
library(gdata)
library(rpart)
library(randomForest)
library(ROCR)
library(MASS)
library(mda)
library(randomForest)

bank_ori=read.table("bank.csv",header=TRUE,sep=";")

# replace the 'unknown' with NA
bankNA = unknownToNA( bank_ori , "unknown")

# remove the entry with too many NAs 
bank<-bankNA[-manyNAs(bankNA,nORp = 0.1),]

# delete poutcome列
bank$poutcome <- NULL

# complete the bank with knn
clean.bank <- knnImputation(bank, k = 10)

# 回归树

# CART
rt.y <- rpart(y ~ .,data=clean.bank[,1:16])

# set random seed
set.seed(1234)

# get the tree and prune with cp = 0.01
rt2.y <- rpartXse(y ~.,data=clean.bank,cp=0.01)
rt2.y 

# get rediction
rt2.pred.y <- predict(rt2.y,clean.bank)


table(rt.pred.y[,2] > 0.5 , clean.bank$y )

t <- table( p , test$y)
tp <- t[2,2]
fp <- t[2,1]
fn <- t[1,2]

prediction = tp / ( tp+fp)
recall = tp / (tp+fn)
f1 = 2 * prediction * recall/ ( prediction + recall)

#交互式剪枝
# snip.bank <- rpart(y ~ .,data=clean.bank)
# snip.rpart(snip.bank)


## glm 

# get the model from linear model
glm.y <- glm(y ~., data = clean.bank, family = binomial,
        control = glm.control(maxit = 50))

# get prediction from the model
glm.pred.y <-predict(glm.y, type="response")

table( glm.pred.y > 0.5, bank$y)

###svm

# get the svm model 
svm.y = fit(y ~., data = clean.bank, model="svm", task="class")
summary(svm.y)

# get the prediction from the svm model
svm.pred.y = predict(svm.y , clean.bank)

table( svm.pred.y , bank$y)



###random forest
# get the random forest model 
rf.y = randomForest(y ~., data = clean.bank,ntree=500)

# get the prediction from the random forest model
rf.pred.y = predict(rf.y , clean.bank)

table( rf.pred.y , bank$y)

###
# different models
# get the model
M = fit( y~., data = clean.bank, model="svm",task="class")

# make the prediction
P = predict(M,clean.bank)

I=Importance(M,clean.bank,method="1D-SA")
print(round(I$imp,digits=2))


table( P , clean.bank$y)

## verification 

f.fit <- function(form,train,test,res,...) {
  m <- fit(form,train,task="class",...)
  p <- predict(m,test)

  t <- table( p , test$y)
  print(t)
  tp <- t[2,2]
  fp <- t[2,1]
  fn <- t[1,2]
  if (tp==0)
    return(0)
  
  prediction = tp / ( tp+fp)
  print("prediction is ")
  print(prediction)
  recall = tp / (tp+fn)
  print("recall is ")
  print(recall)
  f1 = 2 * prediction * recall/ ( prediction + recall)
  print("f1 is ")
  print( f1)
  
  if (res=="pred")
    c(prediction)
  else if(res == "reca")
    c(recall)
  else
    c(f1)
}


pred <- experimentalComparison(
  c(dataset(y ~ .,clean.bank,'y')),
  c( variants('f.fit'
              ,model=c("svm")
              ,res="reca")),
  cvSettings(1,10,1234))


pred <- experimentalComparison(
  c(dataset(y ~ .,clean.bank,'y')),
  c( variants('f.fit'
              ,model=c("lr","naivebayes","lda","dt","svm","randomforest")
              ,res="pred")),
  cvSettings(3,10,1234))

summary(pred)

reca <- experimentalComparison(
  c(dataset(y ~ .,clean.bank,'y')),
  c( variants('f.fit'
              ,model=c("lr","naivebayes","lda","dt","svm","randomforest")
              ,res="reca")),
  cvSettings(3,10,1234))

summary(reca)

f1 <- experimentalComparison(
  c(dataset(y ~ .,clean.bank,'y')),
  c( variants('f.fit'
              ,model=c("naive","lr","naivebayes","lda","qda"
                       ,"dt","mr","svm","randomforest")
              ,res="f1")),
  cvSettings(3,10,1234))

summary(f1)