# Calculate the correlation between the GEBVs and observed values of individuals in the validaiton set.

acc = matrix(0,ncol=2, nrow=20)
phen = read.csv("Cattle.csv")
for (i in 1:20) {
    slemm = read.csv(paste0("slemm_", i,".csv"))
    gwablup = read.csv(paste0("gwablup_", i,".csv"))
    training = read.csv(paste0("training_", i,".csv"))
    val = phen[!(phen$id %in% training$id),]
    colnames(val)[1] = "IID"

    val = merge(val, slemm, by = "IID")
    val = merge(val, gwablup, by="IID")
    
    acc[i,1] = cor(val$scs, val$GEBV.x)
    acc[i,2] = cor(val$scs, val$GEBV.y)
    
}
acc
t.test(acc[,1], acc[,2], paired=T)
