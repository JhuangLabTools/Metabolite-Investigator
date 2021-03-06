make_matrices <- function(dat,
                         clustmethod = "ward.D2",
                         r2Col,
                         pCol,
                         significant){
  
  # st2$pHierBonf <- st2[[pCol]]
  # st2[,significant:=pHierBonf<=0.05]
  # st2[,.N,significant]
  st2 <- copy(dat)
  setnames(x = st2, old = c(r2Col, pCol, significant), new = c("r2Col", "pCol", "significant"), skip_absent = T)
  
  st2max = st2[,.( maxR2            = max(r2Col, na.rm = T),
                   maxIsSignificant = significant[r2Col==max(r2Col)][1],
                   nStudies         = .N,
                   direction        = sign(estimate[r2Col == max(r2Col)][1]),
                   pcorrMaxR2       = pCol[r2Col==max(r2Col)][1]),
               by = .(metab, term)]
  

  # st2max[maxIsSignificant==F, maxR2:=0]
  st2max[, maxR2:=maxR2*direction]
  st2max_r2 = dcast.data.table(st2max, metab ~ term, value.var = "maxR2")
  st2max_r2_matrix = as.matrix(st2max_r2[,-'metab'])
  rownames(st2max_r2_matrix) =  st2max_r2$metab
  st2max_pval = dcast.data.table(st2max, metab ~ term, value.var = "pcorrMaxR2")
  st2max_pval_matrix = as.matrix(st2max_pval[,-'metab'])
  rownames(st2max_pval_matrix) =  st2max_pval$metab
  
  # dont cluster single factor/metab matrices
  res = c()
  
  if(ncol(st2max_r2_matrix) > 1 & nrow(st2max_r2_matrix) > 1){
    
    cc <- hclust(dist(t(st2max_r2_matrix)), method = clustmethod)
    # cc$order
    # plot(cc)
    # colnames(st2max_r2_matrix)[cc$order]
    rc <- hclust(dist((st2max_r2_matrix)), method = clustmethod )
    
    res$r2matrix = t(st2max_r2_matrix[rc$order, cc$order])
    res$pvalmatrix = t(st2max_pval_matrix[rc$order, cc$order])
    
  } else {
    
    res$r2matrix = t(st2max_r2_matrix)
    res$pvalmatrix = t(st2max_pval_matrix)
    
  }
  
  
  
  return(res)
}