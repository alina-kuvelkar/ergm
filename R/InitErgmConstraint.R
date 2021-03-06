#  File R/InitErgmConstraint.R in package ergm, part of the Statnet suite
#  of packages for network analysis, https://statnet.org .
#
#  This software is distributed under the GPL-3 license.  It is free,
#  open source, and has the attribution requirements (GPL Section 7) at
#  https://statnet.org/attribution
#
#  Copyright 2003-2020 Statnet Commons
#######################################################################
#============================================================================
# This file contains the following 12 functions for initializing empty
# constraint lists (each prependend with "InitErgmConstraint")
#         <edges>                   <odegreedist>
#         <degrees>=<nodedegrees>   <bd>
#         <degreesTetrad>           <idegrees>
#         <degreesHexad>            <odegrees>
#         <degreedist>              <hamming>
#         <idegreedist>            <observed>
#============================================================================

##########################################################################################
# Each of the <InitErgmConstraint.X> functions accepts an existing constraint list, 'conlist',
# and to this adds an empty constraint list for term X; if any arguments are passed besides
# 'conlist", execution will halt.
#
# --PARAMETERS--
#   conlist: a list, presumably of constraints for other terms
#
# --RETURNED--
#   conlist: updated to include the initialized empty constraint list for term X
#
##########################################################################################

# Baseline constraint incorporating network attributes such as
# directedness, bipartitedness, and self-loops.
InitErgmConstraint..attributes <- function(lhs.nw, ...){
  list(
    free_dyads = {
      n <- network.size(lhs.nw)
      storage.mode(n) <- "integer"
      ## NB: Free dyad RLE matrix is stored in a column-major order for
      ## consistency with R.
      d <-
        if(is.directed(lhs.nw)){
          if(has.loops(lhs.nw)){
            compress(structure(list(lengths=rep(n,n), values=rep(TRUE,n)), class="rle"))
          }else{
            structure(list(lengths=c(1L,rep(c(n,1L),n-1L)), values=c(rep(c(FALSE, TRUE),n-1L),FALSE)), class="rle")
          }
        }else if(is.bipartite(lhs.nw)){
          b1 <- as.integer(lhs.nw%n%"bipartite")
          b2 <- n - b1
          compress(structure(list(lengths=c(rep(n,b1), rep(c(b1,b2),b2)), values=c(rep(FALSE, b1), rep(c(TRUE,FALSE),b2))),class="rle"))
        }else{
          if(has.loops(lhs.nw)){
            vals <- c(rep(c(TRUE,FALSE),n-1L),TRUE)
            lens <- integer(2L*(n-1L)+1L)
            for(i in seq_len(n-1L)){
              lens[2L*i-1L] <- i
              lens[2L*i] <- n-i
            }
            lens[2L*n-1L] <- n
          }else{
            vals <- c(rep(c(FALSE,TRUE),n-1L),FALSE)
            lens <- integer(2L*(n-1L)+1L)
            for(i in seq_len(n-1L)){
              lens[2L*i-1L] <- n-i+1L
              lens[2L*i] <- i
            }
            lens[2L*n-1L] <- 1L
          }          
          structure(list(lengths=lens,values=vals), class="rle")
        }
      rlebdm(d, n)        
    },
    constrain = character(0),
    dependence = FALSE)
}

InitErgmConstraint.edges<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("Edge count constraint does not take arguments at this time."))
   list(dependence = TRUE, implies = "edges")
}

InitErgmConstraint.degrees<-InitErgmConstraint.nodedegrees<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("Vertex degrees constraint does not take arguments at this time."))
   list(dependence = TRUE, constrain = "degrees", implies = c("degrees", "edges", "idegrees", "odegrees", "idegreedist", "odegreedist", "degreedist", "bd"))
}

InitErgmConstraint.odegrees<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("Vertex odegrees constraint does not take arguments at this time."))
   if(!is.directed(lhs.nw)) ergm_Init_abort("Vertex odegrees constraint is only meaningful for directed networks.")
   list(dependence = TRUE, implies = c("odegrees", "edges", "odegreedist"))
}

InitErgmConstraint.idegrees<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("Vertex idegrees constraint does not take arguments at this time."))
   if(!is.directed(lhs.nw)) ergm_Init_abort("Vertex idegrees constraint is only meaningful for directed networks.")
   list(dependence = TRUE, implies = c("idegrees", "edges", "idegreedist"))
}

InitErgmConstraint.b1degrees<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("B1 vertex degrees constraint does not take arguments at this time."))
   if(!is.bipartite(lhs.nw)) ergm_Init_abort("B1 vertex degrees constraint is only meaningful for bipartite networks.")
   list(dependence = TRUE, implies = c("b1degrees", "edges"))
}

InitErgmConstraint.b2degrees<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("B2 vertex degrees constraint does not take arguments at this time."))
   if(!is.bipartite(lhs.nw)) ergm_Init_abort("B2 vertex degrees constraint is only meaningful for bipartite networks.")
   list(dependence = TRUE, implies = c("b2degrees", "edges"))
}

InitErgmConstraint.degreedist<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("Degree distribution constraint does not take arguments at this time."))
   list(dependence = TRUE, implies = c("degreedist", "edges", "idegreedist", "odegreedist"))
}

InitErgmConstraint.idegreedist<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("InDegree distribution constraint does not take arguments at this time."))
   list(dependence = TRUE, implies = c("idegreedist", "edges"))
}

InitErgmConstraint.odegreedist<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("OutDegree distribution constraint does not take arguments at this time."))
   list(dependence = TRUE, implies = c("odegreedist", "edges"))
}

InitErgmConstraint.bd<-function(lhs.nw, attribs=NULL, maxout=NA, maxin=NA, minout=NA, minin=NA, ...){
   if(nargs()>6)
     ergm_Init_abort(paste("Bounded degrees constraint takes at most 5 arguments; ",nargs()-1," given.",sep=""))
   if(...length()) ergm_Init_abort(paste0("Unrecognised argument(s) ", paste.and(names(list(...)), oq="'", cq="'"),".")) 
   list(attribs=attribs,maxout=maxout,maxin=maxin,minout=minout,minin=minin)
}

InitErgmConstraint.hamming<-function(lhs.nw, ...){
   if(...length())
     ergm_Init_abort(paste("Hamming distance constraint does not take arguments at this time."))
   list(dependence = TRUE)
}

InitErgmConstraint.observed <- function(lhs.nw, ...){
  if(...length())
    ergm_Init_abort(paste("Toggle non-observed constraint does not take arguments at this time."))
  list(free_dyads = as.rlebdm(as.edgelist(is.na(lhs.nw))),
       dependence = FALSE, implies = c("observed"))
}

InitErgmConstraint.blockdiag<-function(lhs.nw, attrname=NULL, ...){
  if(...length())
    ergm_Init_abort(paste("Block diagonal constraint takes one argument at this time."))
  list(attrname=attrname,
       free_dyads = {
         n <- network.size(lhs.nw)
         storage.mode(n) <- "integer"
         a <- lhs.nw %v% attrname
         if(NVL(lhs.nw%n%"bipartite",0)){
           bip <- lhs.nw %n% "bipartite"
           ea <- a[seq_len(bip)]
           aa <- a[bip+seq_len(n-bip)]
           if(length(rle(ea)$lengths)!=length(unique(rle(ea)$values)) || length(rle(aa)$lengths)!=length(unique(rle(aa)$values))) ergm_Init_abort("Current implementation of block-diagonal sampling requires that the blocks of the egos and the alters be contiguous. See help('ergm-constraints') for more information.")
           
           tmp <- .double.rle(ea, aa)
           el <- tmp$lengths1
           al <- tmp$lengths2
           
           o <- rlebdm(c(rep(rle(FALSE), bip*n, scale="run"),
                         do.call(c,rep(
                                     mapply(function(blen,bend){rep(rle(c(FALSE,TRUE,FALSE)), c(bend-blen, blen, n-bend), scale="run")},
                                            el, cumsum(el), SIMPLIFY=FALSE),
                                     al)
                                 )), n)
           # Future-proofing: in case it's bipartite directed, add
           # both thte blocks and their transposes. (If undirected,
           # it'll get filtered out by the .attributes constraints.)
           ot <- rlebdm(c(do.call(c,rep(
                                      mapply(function(blen,bend){rep(rle(c(FALSE,TRUE,FALSE)), c(bip+bend-blen, blen, n-bip-bend), scale="run")},
                                             al, cumsum(al), SIMPLIFY=FALSE),
                                      el)
                                  ),
                          rep(rle(FALSE), (n-bip)*n, scale="run")), n)
           o | ot
         }else{
           a <- rle(a)
           rlebdm(compress(do.call(c,rep(
                                          mapply(function(blen,bend){rep(rle(c(FALSE,TRUE,FALSE)), c(bend-blen, blen, n-bend), scale="run")},
                                                 a$lengths, cumsum(a$lengths), SIMPLIFY=FALSE),
                                          a$lengths)
                                      )), n)
         }
       },
       dependence = FALSE)
}



InitErgmConstraint.fixedas<-function(lhs.nw, present=NULL, absent=NULL,...){
  if(is.null(present) & is.null(absent))
    ergm_Init_abort(paste("fixedas constraint takes at least one argument, either present or absent or both."))
  if(!is.null(present)){
    if(is.network(present)){
      present <- as.edgelist(present)
    }
    if(!is.matrix(present)){
      ergm_Init_abort("Argument 'present' in fixedas constraint should be either a network or edgelist")
    }
  }
  if(!is.null(absent)){
    if(is.network(absent)){
      absent <- as.edgelist(absent)
    }
    if(!is.matrix(absent)){
      ergm_Init_abort("Argument 'absent' in fixedas constraint should be either a network or edgelist")
    }
  }
  list(
    free_dyads = {
      # FixedEdgeList
      fixed <- as.edgelist(rbind(present,absent),
                           n=lhs.nw%n%"n",
                           directed=lhs.nw%n%"directed",
                           bipartite=lhs.nw%n%"bipartite",
                           loops=lhs.nw%n%"loops")
      if(any(duplicated(fixed))){
        ergm_Init_abort("Dyads cannot be fixed at both present and absent")
      }

      !as.rlebdm(fixed)
    },
    dependence = FALSE)
}


InitErgmConstraint.fixallbut<-function(lhs.nw, free.dyads=NULL,...){
  if(is.null(free.dyads))
    ergm_Init_abort(paste("fixallbut constraint takes one required argument free.dyads and one optional argument fixed.state"))
  
  
  if(is.network(free.dyads)){
    free.dyads <- as.edgelist(free.dyads)
  }
  
  if(!is.matrix(free.dyads)){
    ergm_Init_abort("Argument 'free.dyads' in fixallbut constraint should be either a network or edgelist")
  }
  
#	
#	if(!is.null(fixed.state)){
#		if(length(fixed.state)==1)
#			rep(fixed.state,nrow(fixed.dyads))
#		if(length(fixed.state != nrow(fixed.dayds)))
#			stop("fixed.state should be a vector of length equals to the nubmer of dyads in fixed.dyads")
#		if(!all(fixed.state %in% c(0,1)))
#			stop("fixed.state should be a vector of 0,1")
#	}
#	
#	
  list(
    free_dyads = { 
      fixed <- as.edgelist(free.dyads,
                           n=lhs.nw%n%"n",
                           directed=lhs.nw%n%"directed",
                           bipartite=lhs.nw%n%"bipartite",
                           loops=lhs.nw%n%"loops")
      as.rlebdm(free.dyads)
    },
    dependence = FALSE)
}


InitErgmConstraint.Dyads<-function(lhs.nw, fix=NULL, vary=NULL,...){
  if(is.null(fix) & is.null(vary))
    ergm_Init_abort(paste("Dyads constraint takes at least one argument, either",sQuote("fix"),"or",sQuote("vary"),"or both."))

  fd <- lapply(list(fix=fix,vary=vary),
                       function(f){
                         if(!is.null(f)){
                           f[[3]] <- f[[2]]
                           f[[2]] <- lhs.nw
                           m <- ergmMPLE(f, output="array")$predictor
                           m <- m!=0
                           m[is.na(m)] <- FALSE
                           if(!is.directed(lhs.nw)){
                             m <- m | aperm(m, c(2L,1L,3L))
                           }
                           lapply(seq_len(dim(m)[3]), function(i) as.rlebdm(m[,,i]))
                         }
                       })
  fd$fix <- if(length(fd$fix)) fd$fix %>% map(`!`) %>% reduce(`&`)
  fd$vary <- if(length(fd$vary)) fd$vary %>% reduce(`|`)
  fd <- Reduce(`|`, fd)

  list(free_dyads = compress(fd),
       dependence = FALSE)
}
