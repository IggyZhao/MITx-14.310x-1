# Preliminaries
#-------------------------------------------------
#install.packages('perm')
install.packages("perm")
library(perm)
rm(list = ls())
setwd("/Users/nguyetanh/Documents/MITx-14.310x/week7/")

schools <- read.csv("C://Users//nguyetanh//Documents//MITx-14.310x//week7//teachers_final.csv")

# Questions 1 - 4
#-------------------------------------------------

#*change information here for students
perms <- chooseMatrix(8,4)
A <- matrix(c(0.462, 0.731, 0.571, 0.923, 0.333, 0.750, 0.893, 0.692), nrow=8, ncol=1, byrow=TRUE)

#Define average of treatment and control group. %*% implies matrix multiplication
treatment_avg <- (1/4)*perms%*%A
control_avg <- (1/4)*(1-perms)%*%A
test_statistic <- abs(treatment_avg-control_avg)

#Apply logic test to perms so that to compare with the treatment/control group of interest
logic_test <- apply(perms, 1,function(x) (x == c(0, 1, 0, 0, 0, 1, 1, 1)))

#Find the set of treatment/control that fits the empirics. Pick the one that best fits the group of interest.
rownumber <- apply(logic_test, 2, sum)
rownumber <- (rownumber == 8)
observed_test <- test_statistic[rownumber == TRUE]

#*change information here for students
larger_than_observed <- (test_statistic >= observed_test)
#numbers in which the statistic exceeds the value in the observed date
sum(larger_than_observed)
df <- data.frame(perms,control_avg,treatment_avg,test_statistic)

# Question 5 - 6
#-------------------------------------------------
simul_stat <- as.vector(NULL) #Initialise an empty vector

#Set seed to get a reproducible random result. The random numbers are the same, and they would continue to be the same no matter how far out in the sequence we went.
set.seed(1001)


for(i in 1:100) {
  print(i)
  schools$rand <- runif(100,min=0,max=1) #randomly generate 100 numbers under uniform distribution
  schools$treatment_rand <- as.numeric(rank(schools$rand)<=49) #pick the first 49 numbers/ randomly assigned to treatment group
  schools$control_rand = 1-schools$treatment_rand #Define control group
  simul_stat <-append(simul_stat,sum(schools$treatment_rand*schools$open)/sum(schools$treatment_rand) - sum(schools$control_rand*schools$open)/sum(schools$control_rand)) #iterate 100 times and merge the empty vector with the vector which contains 100 results of mean difference
}

schools$control = 1-schools$treatment

#Average treatment effect from the data
actual_stat <- sum(schools$treatment*schools$open)/sum(schools$treatment) - sum(schools$control*schools$open)/sum(schools$control)

#Find p-value
sum(abs(simul_stat) >= actual_stat)/NROW(simul_stat)

#Question 7 - 8
#---------------------------------------------------
#Printing the ATE
ate <- actual_stat
ate

#Define mean of control and treatment groups
control_mean <- sum(schools$control*schools$open)/sum(schools$control)
treatment_mean <- sum(schools$treatment*schools$open)/sum(schools$treatment)

#Estimate sample variance for control and treatment groups. Multiplying by schools$control is equivalent to applying a filter to pick the relevant bits in schools$open in control group
s_c <- (1/(sum(schools$control)-1))*sum(((schools$open-control_mean)*schools$control)^2)
s_t <- (1/(sum(schools$treatment)-1))*sum(((schools$open-treatment_mean)*schools$treatment)^2)

Vneyman <- (s_c/sum(schools$control) + s_t/sum(schools$treatment))
print(sqrt(Vneyman))
print(actual_stat/sqrt(Vneyman))

print(actual_stat-1.96*sqrt(Vneyman))
print(actual_stat+1.96*sqrt(Vneyman))
