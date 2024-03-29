#' Simulation Demo on the unit sphere S^2
#' 
#' Fitting a RFBF from a random data generated by the following parameters 
#' 
#' parameters used to generate random data sets 
#' @param type The manifold considered (sphere) 
#' @param case The shape of the population flow (c, 2fold or 6fold) 
#'        @example c  A "C"-shaped flow on the unit sphere 
#'        @example 2fold  A half of the two-fold star-shaped flow
#'        @example 6fold  A quater of the six-fold star-shaped flow
#' @param sd The standard deviation used to generate the noisy data
#' 
#' parameters used to obtain RFBFs 
#' @param y0 The starting (boundary) point
#' @param y1 The ending (boundary) point
#' @param resolution The number of points on the initial flow connecting 
#' y0 and y1
#' @param h The scale parameter to capture the local variation
#' @param rho The shrinkage constant used during iterations 
#' @param eps The stopping criterion constant 
#' 
#' 
#' @export curve_fbf A RFBF determined by the given parameters and 
#' visualization in 3D space


rm(list=ls())
library(rgl)

# import functions 
source("./RFBF functions/add_functions.R")
source("./RFBF functions/RFBF_smoothing.R")
source("./RFBF functions/RFBF_interpolation.R")
source("./RFBF functions/RFBF_fitting_function.R")

# example begins here
type = "sphere"

case = "2fold" #  "6fold" # "c" #

sd <- 0.015

showcase = paste(type,"_",case,sep="")

if(showcase=="sphere_c"){
  # population flow
  pure_curve = data.matrix(read.csv("./data sets/sphere_c.csv", header=FALSE))
  # set boundary points
  y0 <- c(0.58676580, 0.03460339, 0.80901699)
  y1 <- c(-0.3904378,  0.4393744,  0.8090170)
  # set RFBF parameters 
  resolution <- 20
  h <- 0.14 
  rho <- 0.95
  eps <- 1e-2
}else if(showcase=="sphere_6fold"){
  # population flow
  pure_curve = data.matrix(read.csv("./data sets/sphere_6fold.csv",
                                    header=FALSE))
  # set boundary points
  y0 <- c(-0.011409,  0.594140,  0.804280)
  y1 <- c(-0.593770,  0.012112,  0.804540)
  # set RFBF parameters 
  resolution <- 40
  h <- 0.08
  rho <- 0.95
  eps <- 1e-2
}else if(showcase=="sphere_2fold"){
  # population flow
  pure_curve = data.matrix(read.csv("./data sets/sphere_2fold.csv", 
                                    header=FALSE))
  # set boundary points
  y0 <- c(0.37931, 0.46014, 0.80274)
  y1 <- c(-0.46192, -0.37645,  0.80307)
  # set RFBF parameters 
  resolution <- 30
  h <- 0.08
  rho <- 0.95
  eps <- 1e-2
}

n = ncol(pure_curve)

## generate noisy data 

weighted_noise = FALSE
manifoldata <- NULL

if (weighted_noise==TRUE){
  weight <- abs(c(1:n)-(n+1)/2)
  
  weight <- ceiling(max(weight))-weight
  
  weight <- (weight-floor(min(weight)))/(ceiling(max(weight))-
                                           floor(min(weight)))
  
  
  weight[which(weight<=0.3)] <- 0.3
  
  weight[which(weight>=0.6)] <- 0.6
}else{
  weight = rep(1,n)
}


for (i in 1:n){
  noisy1 <- pure_curve[1,i]+weight[i]*rnorm(1,0,sd)
  
  noisy2 <- pure_curve[2,i]+weight[i]*rnorm(1,0,sd)
  
  noisy3 <- pure_curve[3,i]
  
  noisy <- rbind(noisy1,noisy2,noisy3)
  
  noisy <- apply(noisy,2,function(x){x/norm2(x)})
  
  manifoldata <- cbind(manifoldata,noisy)
  
}


# RFBF algorithm begins here

## initial curve 
gamma_ini <- gamma_given(resolution,y0,y1,1)

## Fitting RFBF 
sol <- RFBF_fitting(gamma_ini, manifoldata, y0,y1,h,rho)

sol <- apply(sol,2,function(x)x/norm2(x))



## smoothing the flow 
h_smoothing = h

sol_smoothing = FBF_smoothing(sol,h_smoothing)

## interpolation for the flow  
dist_ini = norm2(gamma_ini[,2]-gamma_ini[,3])

curve_fbf = FBF_interpolation(sol_smoothing,dist_ini)



## plot the result in 3D
open3d()
spheres3d(c(0,0,0),radius = 1,color="yellow",alpha=1)
points3d(manifoldata[1,],manifoldata[2,],manifoldata[3,],alpha=0.9)
rgl.spheres(curve_fbf[1,],curve_fbf[2,],curve_fbf[3,], r = 0.005, color = "red")


