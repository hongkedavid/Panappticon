MItest <- function(x, y, S, suffStat) {
   if (length(S) == 0) {
     res <- ci.test(suffStat[,x], suffStat[,y])$p.value
   } else {
     res <- ci.test(suffStat[,x], suffStat[,y], suffStat[,S])$p.value
   }
   res
}

A <- read.table("x.data", sep=",", col.names=c("q", "a", "b", "c", "d", "e", "f"))

library(bnlearn)

A[,1] <- cut(A[,1], breaks = c(-1, 8, 50), labels = c("-", "+"))
A[,2] <- cut(A[,2], breaks = 4, labels = c("a", "b", "c", "d"))
A[,3] <- cut(A[,3], breaks = 4, labels = c("a", "b", "c", "d"))
A[,4] <- cut(A[,4], breaks = 4, labels = c("a", "b", "c", "d"))
A[,5] <- cut(A[,5], breaks = 4, labels = c("a", "b", "c", "d"))
A[,6] <- cut(A[,6], breaks = 4, labels = c("a", "b", "c", "d"))
A[,7] <- cut(A[,7], breaks = 4, labels = c("a", "b", "c", "d"))
#ci.test(x = A[,1], y = A[,2], z = data.frame(A[,4]))
#ci.test(x = A[,1], y = A[,4], z = data.frame(A[,2]))

library(methods)
library(pcalg)
pc.fit <- pc(suffStat = A, indepTest = MItest, skel.method = "stable", labels = c("QoE", "sdcard1", "sdcard2", "gzip1", "system", "gzip2", "gzip3"), alpha = 0.05)

warnings()

library(graph)
library(grid)
library(Rgraphviz)
png(filename="/home/david/pc_cond.png")
plot(pc.fit, main = "Estimated Causal DAG")
dev.off()
