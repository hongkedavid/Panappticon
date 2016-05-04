# Update R package to 3.4 following http://sysads.co.uk/2014/06/install-r-base-3-1-0-ubuntu-14-04/
# Open R shell
library("utils")
# May encounter problems in missing pkgs in graph 
install.packages("pcalg")
# If so, install graph and RBGL
source("http://bioconductor.org/biocLite.R") 
biocLite("RBGL")
#browseVignettes("graph")
install.packages("pcalg")
