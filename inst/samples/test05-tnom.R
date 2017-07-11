# tnom-test.ssc

n.genes <- 200
n.samples <- 10

bogus <- matrix(rnorm(n.samples*n.genes, 0, 3), ncol=n.samples)
splitter <- rep(F, n.samples)
splitter[sample(1:n.samples, trunc(n.samples/2))] <- T

tn <- TNoM(bogus, splitter)
summary(tn)

tnf <- update(tn)
plot(tnf)
hist(tnf)

rm(bogus, splitter, n.genes, n.samples, tn, tnf)
