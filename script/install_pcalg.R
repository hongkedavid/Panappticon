# Update R package to the laest one at http://sysads.co.uk/2014/06/install-r-base-3-1-0-ubuntu-14-04/

library("utils")
# will encounter problems in missing pkgs 
install.packages("pcalg")
# install graph and RBGL
source("http://bioconductor.org/biocLite.R") 
biocLite("RBGL")
#browseVignettes("graph")
install.packages("igraph", dependencies=TRUE)
# install.packages("/home/david/plyr_1.8.3.tar.gz", repos = NULL, type = "source", dependencies = TRUE) # doesn't work due to missing dependency
