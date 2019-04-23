library(ClassComparison)

RNGversion("3.5.3")
set.seed(782562)
betaPerc <- 0.10
nGenes <- 1000
alpha <- 0.2
nUnif <- trunc(nGenes*(1-betaPerc))
pvals <- c(runif(nUnif), rbeta(nGenes-nUnif, alpha, 1))
fit <- Bum(pvals)

fit@ahat
fit@lhat
fit@pihat

fdr <- 0.2
countSignificant(fit, alpha=fdr, by="FDR")
picked <- selectSignificant(fit, alpha=fdr, by="FDR")

truth <- rep(c("Null", "Real"), times=c(nUnif, nGenes-nUnif))

table(truth, byFDR=picked)

conf <- 0.80
countSignificant(fit, alpha=conf, by="EmpiricalBayes")
epicked <- selectSignificant(fit, alpha=conf, by="EmpiricalBayes")

table(truth, EB=epicked)

table(byFDR=picked, EB=epicked)

# unknown method
try( countSignificant(fit, by="HandWaving") )

# out of range
try( b <-  Bum(rnorm(1000)) )
try( b <- Bum(c(pvals, 1.1)) )

# bad input type
try( b <- Bum(LETTERS) )
try( b <- Bum(factor(LETTERS) ))
