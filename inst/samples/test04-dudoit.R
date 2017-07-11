ng <- 10000
ns <- 15
nd <- 200
fake.class <- factor(rep(c('A', 'B'), each=ns))
fake.data <- matrix(rnorm(ng*ns*2), nrow=ng, ncol=2*ns)
fake.data[1:nd, 1:ns] <- fake.data[1:nd, 1:ns] + 2
fake.data[(nd+1):(2*nd), 1:ns] <- fake.data[(nd+1):(2*nd), 1:ns] - 2

dud <- Dudoit(fake.data, fake.class, nPerm=300)
summary(dud)
plot(dud)
countSignificant(dud, 0.05)

rm(ng, ns, nd, fake.class, fake.data, dud)
