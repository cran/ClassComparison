#################################################################
# load the data set
library(ClassComparison)
require(TailRank) # for the prostate cancer data set with 2000 genes
data(expression.data)
data(clinical.info)
# make sure the Status variable has "N"ormals as the first level
# Note that "T" = primary prostate tumor and "L" = lymph node metastasis
temp <- ordered(clinical.info$Status, c('N', 'T', 'L'))
clinical.info$Status <- temp
rm(temp)

#################################################################
# create an exprSet
require(Biobase)
# create a phenoData object and an exprSet
vl <- data.frame(labelDescription=dimnames(clinical.info)[[2]])
rownames(vl) <- as.character(vl[,1])
pheno <- new('AnnotatedDataFrame',
             data=clinical.info,
             varMetadata=vl)
es <- new('ExpressionSet',
          phenoData=pheno,
          exprs=as.matrix(expression.data))
# we don't need the original data now that it has been
# incorporated into the exprSet
rm(expression.data)
rm(vl, pheno)

#################################################################
# Now we can start exercising the ClassComparison package

##################################
# gene-by-gene two-sample t-test (everybody)

tt <- MultiTtest(es, 'Status')
summary(tt)

ttu <- MultiTtestUnequal(es, 'Status')

# check that the comparison using the "status" column in the
# phenoData object is the same as comparing against the first
# level of the factor, i.e., "N"ormal.
tt2 <- MultiTtest(es, clinical.info$Status!='N')
summary(tt2)
# the summary looks the same. we can check the t-statistics
plot(tt@t.statistics, tt2@t.statistics)
abline(0,1)
# so, they really are the same. Now we no longer need the separate
# clinical.info table, or the alternative MultiTtest object
rm(clinical.info, tt2)

# Here is a plot and a histogram of the t-statistics
plot(tt)
hist(tt, breaks=75)

# We have to extract the p-values to show them
hist(tt@p.values, breaks=75)

##################################
# There seems to be an overabundance of small p-values. 
# We can use the Beta-Uniform Mixture for multiple comparisons
# (Pounds and Morris)

bumt <- Bum(tt@p.values)
hist(bumt, res=250)
# The BUM model seems to fit the data quite well. Let's look at
# our estimate of the true positive andtrue negative fractions
# with a single t-test cutoff of 0.01.
summary(bumt)
# There appear to be very few false positives. Of course, a better
# way to approach this is to choose a cutoff based on the false
# discovery rate. If we take FDR = 0.01, then the cutoff is
# quite small:
cutoffSignificant(bumt, 0.01, by='FDR')

# The number of genes called significant at this level is:
countSignificant(bumt, 0.01, by='FDR') # 385

##################################
# gene-by-gene Wilcoxon test with empirical Bayes (Efron and Tibshirani)

wil <- MultiWilcoxonTest(es, 'Status', histsize=101)
hist(wil)
# The empirical Bayes approach using the Wilcoxon test also
# indicates a substantial number of differentially expressed genes.

# The empirical prior in the following command was determined by trial
# and error. It was chosen to ensure that the posterior probabilities
# never quite become negative.
plot(wil, prior=0.39, signif=0.99, ylim=c(0,1))
abline(h=0)

# The summary function gives us both the cutoff values at the desired
# posterior probability along with counts of the number of genes in
# each tail.
summary(wil, prior=0.39, signif=0.99)
countSignificant(wil, prior=0.39, signif=0.99) # 350

# We obtained similar numbers of genes from each test
# (385 with the t-test, 350 with the Wilcoxon test)
# How well do the two tests agree?
sum(selectSignificant(bumt, 0.01, by='FDR') &
    selectSignificant(wil, prior=0.39, signif=0.99)) # 320

##################################
# Total Number of Misclassifications (Yakhini and Ben-Dor)

tn <- TNoM(es, 'Status')
summary(tn)
# the summary isn't terribly informative at present. We still need to
# run the permutation tests

tnf <- update(tn)
plot(tnf)
# The maximum gap between the expected and observed number of genes
# seems to occur near 35 misclassifications.

countSignificant(tn, 35) # 396
countSignificant(tn, 36) # 465
# while we could do something fancier to determine the best cutoff,
# we're going to go with 35 since it yields a similar number of
# interesting genes

sum(selectSignificant(tn, 35) &
    selectSignificant(bumt, 0.01, by='FDR')) # 315

sum(selectSignificant(tn, 35)
    & selectSignificant(wil, prior=0.39, signif=0.99)) # ~ 308
# note that the precise number varies if you only do a few permutations

##################################
# Significance Analysis of Microarrays (Tusher et al)

samt <- Sam(es, 'Status')
plot(samt, tracks=1:3)
summary(samt)
# we note that the "observed" statistics start deviating from the
# "expected" statistics pretty quickly. With a cutoff of 1, we get
# 316 genes, in the neighborhood of what we expect from the earlier
# methods.

sum(selectSignificant(bumt, 0.01, by='FDR') &
    selectSignificant(samt, cutoff=1)) # 316
# note that the genes are sorted by the same t-statistic, and the cutoffs
# are symmetric. So, the method producing fewer genes must produce a
# subset of the other method.

##################################
# Linear models (everybody?)

# Recall that the microarray data must be modeled as the response,
# and it has to be called "Y".
baseline <- MultiLinearModel(Y ~ Status, es)
hist(baseline, breaks=75)

hist(baseline@p.values, breaks=75)
# Not surprisingly, this looks a lot like the plot of p-values from
# the two-sample t-test

# We can apply BUM again
bumb <- Bum(baseline@p.values)
hist(bumb, res=250)

countSignificant(bumb, 0.01, by="FDR") # 629
countSignificant(bumt, 0.01, by="FDR") # 385
sum(selectSignificant(bumt, 0.01, by='FDR') &
    selectSignificant(bumb, 0.01, by='FDR')) # only 369?

# The advantage of the linear model is that we can look
# at mutliple factors or multipel levels of a factor
chipper <- MultiLinearModel(Y ~ Status+ChipType, es)
bumc <- Bum(chipper@p.values)
image(bumc)
# This also looks highly significant

countSignificant(bumc, 0.01, by="FDR") # 1154

# We can compare the models. Recall that "anova" in this
# case prodices a data frame
relativeModel <- anova(baseline, chipper)
bum.rel <- Bum(relativeModel$p.values)
image(bum.rel)
# There appear to be a significant number of genes for which
# the generation of the glass microarray ("ChipType") has
# an effect on expression, even after accounting for the
# expected biological differences between normal prostate
# and prostate cancer. Hmmm...

##################################
# Smooth T test (Baggerly and Coombes)

# We proceed in two steps. First we get the summary statistics
# for the two groups of samples
tgs <- TwoGroupStats(es, 'Status')
opar <- par(mfrow=c(2,3))
plot(tgs)
par(opar)
# The model does potentially odd things when using log ratios
# instead of log intensities

# Next, we smooth and compute t-statistics
smu <- SmoothTtest(tgs, 'Normal', 'Cancer', 'ExprDemo')
summary(smu)

opar <- par(mfrow=c(2,3))
plot(smu,goodflag=4)
par(opar)

# The comparison seems to go the opposite direction by default
# in the gene-by-gene t-test (MultiTtest) compared to the smooth
# t test. More importantly, there semms to be a huge difference
# of opinon rgarding which genes are different.
plot(smu@smooth.t.statistics, tt@t.statistics)


smu.sel <- abs(smu@smooth.t.statistics) > qnorm(0.995)
t.sel <- selectSignificant(bumt, 0.01, by='FDR')

sum(smu.sel) # 402
sum(t.sel) # 385
sum(smu.sel & t.sel) # 259

##################################
# Dudoit adjusted p-values

dud <- Dudoit(es, 'Status', nPerm=300)

# This method is much more conservative about calling things
# differentially expressed
countSignificant(dud, 0.05) # 174
countSignificant(dud, 0.10) # 203
countSignificant(dud, 0.20) # 243
# these numbers can also vary if you only do a few permutations.

dud.sel <- selectSignificant(dud, 0.10)
sum(dud.sel & t.sel) # 203
# again, this uses the same ordering on the t-statistics, so it
# has to select a subset of the genes selected by the plain old
# two-sample t-test with BUM

wil.sel <- selectSignificant(wil, prior=0.39, sig=0.99)
sum(wil.sel) # 350
sum(dud.sel & wil.sel) # 203
# This conservative approcah also strongly agrees with the
# Wilcoxon test.

# But the smooth t-test still selects different genes...
sum(dud.sel & smu.sel) # 168
sum(wil.sel & smu.sel) # 237


##################################
# clean everything up

rm(es, opar)
rm(tt, bumt, wil, tn, tnf, samt, dud)
rm(baseline, chipper, bumb, bumc, tgs, smu)
rm(relativeModel, bum.rel)
rm(t.sel, smu.sel, dud.sel, wil.sel)
