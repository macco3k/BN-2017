# BN-2017

Welcome to the repository with the code used for BN assignments 1 and 2. We know the code has become a little messy, this document should provide an overview of where to look.

In model.r on the toplevel, we have the network from assignment 1. It is called defined_net.

In assignment 2, there is another model.r, in which the structure learning algorithms are applied. For the real analysis, we used the command line in Rstudio and executed the structure learning algorithms repeatedly to compare the different possible combinations.

That looked like the following snippet:

```{r}

hc_net <- hc(t, restart = 10, optimized = TRUE)
hiton_net <- si.hiton.pc(t, undirected = FALSE, test="x2", debug = TRUE, alpha=0.01)

graphviz.plot(hc_net)
score(hc_net, t)

graphviz.plot(hiton_net)
score(hiton_net, t)

```

We hope everything is clear.
