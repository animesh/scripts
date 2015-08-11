g<-read.csv('g.csv')
s<-read.csv('s.csv')
gn<-read.csv('gn.csv')
sn<-read.csv('sn.csv')

t.test(s$PAIN.6HRS..VAS.,g$PAIN.6.HRS..VAS.)
t.test(s$PAIN.12.HRS..VAS.,g$PAIN.12.HRS..VAS.)
t.test(s$ANALGESIC.REQ..FIRST.24.Hrs.,g$ANALGESIC.REQ..FIRST.24.Hrs.)
t.test(s$Age,g$Age)
t.test(s$DURATION,g$DURATION)

jpeg(file="vas.jpg")
boxplot(s$PAIN.6HRS..VAS.,g$PAIN.6HRS..VAS.,s$PAIN.12.HRS..VAS.,g$PAIN.12.HRS..VAS.)
dev.off()

jpeg(file="analgesic.jpg")
boxplot(s$ANALGESIC.REQ..FIRST.24.Hrs.,g$ANALGESIC.REQ..FIRST.24.Hrs.)
dev.off()

jpeg(file="age.jpg")
boxplot(s$Age,g$Age)
dev.off()

jpeg(file="duration.jpg")
boxplot(s$DURATION,g$DURATION)
dev.off()

summary(s$Age)
summary(g$Age)


