#ifndef MPLEconddeg_H
#define MPLEconddeg_H

#include "edgetree.h"
#include "changestat.h"
#include "MHproposal.h"
#include "model.h"

void MPLEconddeg_wrapper (int *heads, int *tails, int *dnedges,
                   int *maxpossibleedges,
                   int *dn, int *dflag, int *bipartite, 
                   int *nterms, char **funnames,
                   char **sonames, 
                   char **MHproposaltype, char **MHproposalpackage,
                   double *inputs, double *theta0, int *samplesize, 
                   double *sample, int *burnin, int *interval,  
                   int *newnetworkheads, 
                   int *newnetworktails, 
                   int *fVerbose, 
                   int *attribs, int *maxout, int *maxin, int *minout,
                   int *minin, int *condAllDegExact, int *attriblength, 
                   int *maxedges,
                   int *mheads, int *mtails, int *mdnedges);
void CondDegSampler (char *MHproposaltype, char *MHproposalpackage,
		 double *theta, double *networkstatistics, 
		 long int samplesize, long int burnin, 
		 long int interval, int hammingterm, int fVerbose,
	       	 Network *nwp, Model *m, DegreeBound *bd);
void CondDegSample (MHproposal *MHp,
			 double *theta, double *statistics, 
			 long int nsteps, long int *staken,
			 int hammingterm, int fVerbose,
			 Network *nwp, Model *m, DegreeBound *bd);
#endif