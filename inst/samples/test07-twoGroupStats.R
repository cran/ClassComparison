# two-group-stats-test.ssc

bogus <- matrix(rnorm(30*1000, 8, 3), ncol=30, nrow=1000)
splitter <- rep(F, 30)
splitter[16:30] <- T

x <- TwoGroupStats(bogus, splitter)
summary(x)

opar<-par(mfrow=c(2,3), pch='.')
plot(x)
par(opar)

# cleanup
rm(bogus, splitter, x, opar)

