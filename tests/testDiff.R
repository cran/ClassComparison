library(ClassComparison)

nGenes <- 1000
nSamplesPerGroup <- 10
nGroups <- 2

set.seed(944637)
data <- matrix(rnorm(nGenes*nSamplesPerGroup*nGroups),
               nrow=nGenes)
classes <- factor(rep(c("A", "B"), each=nSamplesPerGroup))

mtt <- MultiTtest(data, classes)
summary(mtt)

mw <- MultiWilcoxonTest(data, classes)
summary(mw)

mlm <- MultiLinearModel(Y ~ classes, data.frame(classes=classes), data)
summary(mlm)

dud <- Dudoit(data, classes, nPerm=100, verbose=FALSE)
summary(dud)

tn <- TNoM(data, classes)
summary(tn)

sam <- Sam(data, classes)
summary(sam)

tgs <- TwoGroupStats(data, classes)
summary(tgs)
smoo <- SmoothTtest(tgs)
summary(smoo)
#plot(smoo@smooth.t.statistics, mtt@t.statistics)
