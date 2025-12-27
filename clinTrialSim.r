#check sema clinical trial paper and data, also the different doses and simulation code  https://www.youtube.com/watch?v=zm9SAHc63_o
#Research Study Investigating How Well Semaglutide Works in People Suffering From Overweight or Obesity (STEP 1) https://clinicaltrials.gov/study/NCT03548935?tab=results#outcome-measures
#Once-Weekly Semaglutide in Adults with Overweight or Obesity https://www.nejm.org/doi/full/10.1056/NEJMoa2032183
#A Research Study to Look Into How Well Semaglutide Medicine Works at Different Doses in People With Type 2 Diabetes and Overweight https://clinicaltrials.gov/study/NCT05486065?tab=results#outcome-measures
set.seed(123)
n<-60
sim_data<-data.frame(categorical_var=rep(c("Sema","Placebo"),each=n/2),continuous_covariate=rnorm(n,mean=50,sd=10))
#beta0=30,tauSema=10,B/covariation=0.5,epsilon_ij~N(0,5)
sim_data$dependent_var<-with(sim_data,30+10*(categorical_var=="Sema")+0.5*continuous_covariate+rnorm(n,mean=0,sd=5))
model<-aov(dependent_var~categorical_var+continuous_covariate,data=sim_data)
summary(model)
#increasevariance
sim_data$dependent_var<-with(sim_data,30+10*(categorical_var=="Sema")+0.5*continuous_covariate+rnorm(n,mean=0,sd=20))
model<-aov(dependent_var~categorical_var+continuous_covariate,data=sim_data)
summary(model)
