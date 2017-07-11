ng <- 10000
ns <- 50
dat <- matrix(rnorm(ng*ns), ncol=ns)
cla <- factor(rep(c('A', 'B'), 25))
cla2 <- factor(rep(c('X', 'Y', 'Z'), times=c(15, 20, 15)))
covars <- data.frame(Grade=cla, Stage=cla2)
res <- MultiLinearModel(Y ~ Grade + Stage, covars, dat)
summary(res)
hist(res, breaks=101)
plot(res)
plot(res, res@p.values)

graded <- MultiLinearModel(Y ~ Grade, covars, dat)
summary(graded)

hist(graded@p.values, breaks=101)
hist(res@p.values, breaks=101)

oop <- anova(res, graded)
hist(oop$p.values, breaks=101)

first.one <- data.frame(Y=(dat[1,]), covars)
fullmod <- lm(Y ~ Grade + Stage, first.one)
partmod <- lm(Y ~ Grade, first.one)

fullmod
res@coefficients[,1]

summary(fullmod)
res@F.statistics[1]
res@p.values[1]
res@df

anova(fullmod, partmod)
oop[1,]

rm(ng, ns, dat, cla, cla2, covars, res, graded, oop)
rm(first.one, fullmod, partmod)
