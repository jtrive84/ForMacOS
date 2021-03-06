
## Optimizing R Code with Rcpp
###### Author: James Triveri

R is an interpreted language, which means it is very flexible, but also has inferior runtime performance when compared with compiled, statically-typed programming languages such as C/C++. However, we can get the best of both worlds by taking advantage of the Rcpp library, a package which facilitates the integration of executable C++ code within R programs to optimize CPU-bound bottlenecks. 
In this article, I'll demonstrate how Rcpp can be leveraged within your programs for a fairly common task: Estimating the value of some quantity between two development periods via interpolation.

### Prerequisites


If you don't have them already, install the data.table, foreach and Rcpp libraries the conventional way: Open RStudio, and from the interactive console, run:

```R
> install.packages(c("data.table", "foreach", "Rcpp"))
```

Since Rcpp requires a C compiler, it is also necessary to install Rtools, available [here](https://cran.r-project.org/bin/windows/Rtools/). Be sure to install a version compatible with your installed version of R, and do not install Rtools to a directory location with spaces in the path. If possible, install directly to C:/ (e.g. `C:/Rtools`).

### Setup

Assume we have a dataset representing estimates of the number of cumulative incurred claims at 12 months for some line of business. Let's assume the number of claims at time=0 is a known quantity, say 50. A synthetic simulated dataset of cumulative claims counts at t=0 and t=12 could be created as follows:


```R
library("data.table")
options(scipen=9999)
set.seed(516)

NBR_SIMS = 10000

simsDF = data.table(
    t0=rep(50, NBR_SIMS), 
    t12=sample(seq(45, 90), size=NBR_SIMS, replace=TRUE)
    )
```

Reviewing the first 10 rows of `simsDF` yields:

```
> head(simsDF, 10)
    t0 t12
 1: 50  56
 2: 50  78
 3: 50  81
 4: 50  88
 5: 50  45
 6: 50  54
 7: 50  70
 8: 50  51
 9: 50  66
10: 50  79
```

Let's imagine some analysis requires cumulative claim count estimates for each of the intermediate months, e.g. t1, t2, ..., t11. Essentially, the task boils down to converting a data.table of dimension 10,000 x 2 to one with dimensionality 10,000 x 12 via interpolation. 

A vector of the evaluation points is created (including end points, (0, 12)) along with a list of 2-element vectors for each of the 10000 simulated claim counts at t=0 and t=12:


```R
library("foreach")

# Independent value endpoints.
xvals = c(0, 12) 

# Evaluation points at which to perform interpolation.
evalp = min(xvals):max(xvals)

# List containing 10000 2-element vectors. 
yvals = mapply(                        
    function(y0, y1) c(y0, y1), y0=simsDF[["t0"]], y1=simsDF[["t12"]], 
    SIMPLIFY=FALSE
    )
```

Our first implementation uses base R. We call the `approx` function, which performs interpolation between xvals and yvals at the specified points of evaluation. We record the total execution time for later comparison:


```R

t_init_0 = proc.time()

interpDF0 = foreach(
    ii=1:length(yvals), .errorhandling="stop", .combine="rbind",
    .final=function(m) as.data.table(m, keep.rownames=FALSE)
) %do% {
    approx(x=xvals, y=yvals[[ii]], xout=evalp)$y
}

setnames(interpDF0, as.character(evalp))

t_total_0 = (proc.time()-t_init_0)[["elapsed"]]
message("Runtime for first approach (approx): ", t_total_0, " seconds.")
# Runtime for first approach (approx):  6.37 seconds.
```

The resulting interpolated data.table contains 10,000 rows by 13 columns. Columns `0` and `12` contain the same values from `simsDF`, and all intermediate columns represent linearly interpolated values:

```
        0        1        2     3        4        5    6        7        8     9       10       11 12
    1: 50 52.66667 55.33333 58.00 60.66667 63.33333 66.0 68.66667 71.33333 74.00 76.66667 79.33333 82
    2: 50 49.58333 49.16667 48.75 48.33333 47.91667 47.5 47.08333 46.66667 46.25 45.83333 45.41667 45
    3: 50 52.50000 55.00000 57.50 60.00000 62.50000 65.0 67.50000 70.00000 72.50 75.00000 77.50000 80
    4: 50 52.16667 54.33333 56.50 58.66667 60.83333 63.0 65.16667 67.33333 69.50 71.66667 73.83333 76
    5: 50 49.75000 49.50000 49.25 49.00000 48.75000 48.5 48.25000 48.00000 47.75 47.50000 47.25000 47
   ---                                                                                               
 9996: 50 53.00000 56.00000 59.00 62.00000 65.00000 68.0 71.00000 74.00000 77.00 80.00000 83.00000 86
 9997: 50 50.00000 50.00000 50.00 50.00000 50.00000 50.0 50.00000 50.00000 50.00 50.00000 50.00000 50
 9998: 50 52.16667 54.33333 56.50 58.66667 60.83333 63.0 65.16667 67.33333 69.50 71.66667 73.83333 76
 9999: 50 50.16667 50.33333 50.50 50.66667 50.83333 51.0 51.16667 51.33333 51.50 51.66667 51.83333 52
10000: 50 49.83333 49.66667 49.50 49.33333 49.16667 49.0 48.83333 48.66667 48.50 48.33333 48.16667 48
```

The first implementation requires almost 6.5 seconds to transform the 10000x2 data.table into a 10000x12 interpolated representation. Let's see if 

### Rcpp

[Rcpp](https://cran.r-project.org/web/packages/Rcpp/index.html)  is a third-party R library which simplifies the process of extending R with compiled code extensions, typically of the C++ variety. A function or other callable is written in C++. The C++ source file gets compiled into a shared library, which is then called from R like any other function. One of the features that makes Rcpp so powerful is that R's native data structures are available and can be leveraged in any user defined extension module without having to manually allocate and deallocate memory.
Although Rcpp has several methods by which compiled C++ functions can be loaded into R, we focus on one method, which is to write the C++ function in a separate file with a.cpp extension, then load it into R using `sourceCpp` (provided by Rcpp).

My first attempt at optimizing the interpolation routine consisted of replacing R's builtin `approx` with an equivalent implementation in C++. The thinking was that the cause of the bottleneck was due to `approx`, since the repeated call to `approx` was the only function explicitly called in the foreach construct. 

As a review, the mathematical expression for linear interpolation is given by:

$$
f(x_{0}) + \frac{f(x_{1}) - f(x_{0})}{x_{1}- x_{0}}(x - x_{0})
$$

The C++ interpolation routine is straightforward to implement, and was identified as approxc1 to distinguish it from the builtin. I assumed it would serve as a drop-in replacement for approx, but with improved performance. What follows is the declaration for approxc1 found in approxc1.cpp:


```cpp
#include <Rcpp.h>
using namespace Rcpp;

// =============================================================================
// approxc1.cpp                                                                |
// =============================================================================
// This is `approxc1`, C++-implementation of R's native approx function.       |
// Note that x0, x1, y0 and y1 are scalars.                                    |
// evalPts is a numeric vector which represents the points of evaluation.      |
// Returns a vector the same length as evalPts representing the interpolated   |
// values.                                                                     |
// =============================================================================

// [[Rcpp::export]]
NumericVector approxc1(int x0, int x1, double y0, double y1, NumericVector evalPts) {
    
    int n = evalPts.size();
    double quotient = ((y1 - y0)/(x1 - x0));
    NumericVector vout(n);
    
    for(int i=0; i<n; i++) {
        vout[i] = (quotient * (evalPts[i] - x0) + y0);
    }
    return(vout);
}
```

approxc1 interpolates a single row at a time, returning a vector of interpolated values at the points given by evalPts. approxc1 accepts the `x*` and `y*` arguments as scalars instead of vectors, but we could have very easily written approxc1 to have the same call signature as approx.
Next we test approxc1 on the same dataset to get an idea of the performance improvement. We load `approxc1.cpp` into to the global environment using `sourceCpp`:

```R
library("data.table")
library("foreach")
library("Rcpp")

# Build shared library containing approxc1 and load into global environment.
# Replace "approxc1.cpp" with the full path to the source file. 
Rcpp::sourceCpp("approxc1.cpp", rebuild=TRUE)

# Independent value endpoints.
xvals = c(0, 12) 

# Evaluation points at which to perform interpolation.
evalp = min(xvals):max(xvals)

# List containing 10000 2-element vectors. 
yvals = mapply(                        
    function(y0, y1) c(y0, y1), y0=simsDF[["t0"]], y1=simsDF[["t12"]], 
    SIMPLIFY=FALSE
    )

t_init_1 = proc.time()

# Iterate over yvals list, interpolating at each evalp.
interpDF1 = foreach(
    i=1:length(yvals),.errorhandling="stop",.combine="rbind",
    .final=function(m) as.data.table(m, keep.rownames=FALSE)
) %do% {
    approxc1(
        x0=xvals[1], x1=xvals[2], y0=yvals[[i]][1], y1=yvals[[i]][2],
        evalPts=evalp
        )
}

setnames(interpDF1, as.character(evalp))


t_total_1 = (proc.time()-t_init_1)[["elapsed"]]
message("Runtime for second approach (approxc1): ", t_total_1, " seconds.")
# Runtime for second approach (approxc1): 5.60000000000001. seconds.
```

A reduction of ~1. second isn't exactly what we had in mind! However, this second attempt wasn't a total waste of time, since we learned that R's approx wasn't the bottleneck after all. In fact, taken in isolation, approx performs just as well as the C++ implementation because it is implemented in C/C++.  If you type approx at R???s interactive console without arguments or parens then press enter, the body of the function will be printed. All the way near the bottom, we find the following line starting with yout:

```R
yout <- .Call(C_Approx, x, y, xout, method, yleft, yright, 
```

Whenever approx is called from R, approx calls C_Approx, which we have reason to believe is the C-implemented interpolation routine that approx serves as a wrapper for.

If approx isn???t the bottleneck, the only other construct that could adversely affect total runtime would be the iteration scheme itself, or in this case, the foreach constructor. The next implementation removes the call to foreach, which is subsumed within the revised C++ function. Unlike approxc1, which returned a vector representing a single row of interpolated values at each evaluation point, approxc2 returns a matrix which is coerced to a data.table upon returning to the caller. Another difference between approxc1 and approxc2 is that in approxc2, y0 and y1 are vectors, not scalars. The x parameter is a 2-element vector, which still represents the end-points for interpolation, but it is passed as a single entity instead of separate scalar values as in approxc1. Here is the declaration for approxc2, which we put in a file named *approxc2.cpp*:

```cpp
#include <Rcpp.h>
using namespace Rcpp;
// =============================================================================
// approxc2.cpp                                                                |
// =============================================================================
// This is `approxc2`, a C++ routine that performs tabular interpolation.      |
// Takes as input 2 vectors to interpolate between (y0, y1), a 2-element vector|
// containing the x-values (`x`), and the points at which the interpolation    |
// should take place (`evalPts`).                                              |
// Returns a matrix of dimension length(y0/y1) rows by length(evalPts) columns.|
// =============================================================================

// [[Rcpp::export]]
NumericMatrix approxc2(NumericVector x, NumericVector y0, NumericVector y1, NumericVector evalPts) {
    // approx2c returns a matrix x.size() rows by evalPts columns
    // containing interpolated data at each of evalPts between y0 
    // and y1. `x` is simply an integer vector containing the 
    // bounds for interpolation. 

    if(y0.size()!=y1.size()) stop("Vectors must have the same dimensionality.");

    int x0          = x[0];
    int x1          = x[1];
    int nrows       = y0.size();
    int ncols       = evalPts.size();
    double quotient = 0.0;
    NumericMatrix mat(nrows, ncols);

    for(int i=0; i<nrows; i++) {

        quotient = ((y1[i] - y0[i])/(x1 - x0));

        for(int j=0; j<ncols; j++) {

            mat(i, j) = (quotient * (evalPts[j] - x0) + y0[i]);
        }
    }
    return(mat);
}
```


The implementation of approxc2 is straightforward. The outer-loop iterates by row, the inner-loop by column. We specify a return type of NumericMatrix, which can be specified without having to concern ourselves with any of the details of memory management. Also note that there are more efficient approaches that can be used to populate a matrix via Rcpp (see, for example, the [RcppArmadillo](https://cran.r-project.org/web/packages/RcppArmadillo/RcppArmadillo.pdf) library), but for our purposes, approxc2 will suffice. We now test approxc2 on the same dataset used to benchmark the approx and approxc1 implementations:

```R
library("data.table")
library("Rcpp")

# Build shared library containing approxc1 and load into global environment.
# Replace "approxc2.cpp" with the full path to the source file. 
Rcpp::sourceCpp("approxc2.cpp", rebuild=TRUE)

t_init_2 = proc.time()

# Recall that `simsDF` contains the values of yvals before it was split into 
# a list of 10000 2-element vectors. With approxc2, we pass the columns directly. 
interpd2 = as.data.table(
    approxc2(x=xvals, y0=simsDF[[1]], y1=simsDF[[2]], evalPts=evalp),
    keep.rownames=FALSE
    )

setnames(interpd2, as.character(evalp))

t_total_2 = (proc.time()-t_init_2)[["elapsed"]]
message("Runtime for third approach (approxc2): ", t_total_2, " seconds.")
# Runtime for third approach (approxc2): 0.0600000000000023 seconds.
```

That's closer to what we expected. Switching from approxc1 to approxc2 resulted in an implementation
93x faster, and 106x faster than our first implementation. 

We should verify that interpDF0, interpDF1 and interpDF2 all contain identical values. This can be accomplished by running:

```R
> all(c(all.equal(interpDF0, interpDF1), all.equal(interpDF1, interpDF2)))
[1] TRUE
```

Then via the transitive property, if `interpd0==interpd1` and `interpd1==interpd2`, then `interpd0==interpd2`, and all implementations return an identically interpolated data.table.


In conclusion, we learned that at least in some cases, computational bottlenecks in R programs aren't necessarily due to R functions themselves, but may instead be attributed to the iteration scheme. By moving the iteration into a compiled code extension, we were able to drastically reduce the runtime required to interpolate a table of values. This is what makes Rcpp so powerful: You get all the benefits of C++ without having to deal with the more challenging aspects of working with compiled, statically-typed programming languages. 

More information about using Rcpp and associated C++ template libraries can be found in the *Advanced R* companion site, available [here](http://adv-r.had.co.nz/Rcpp.html).
