library("data.table")
library("foreach")
library("ggplot2")
library("splines")
options(scipen=9999)

ldfs = c(
    2.85637, 1.58402, 1.37531, 1.3001, 1.21469, 1.28128, 1.15415, 1.09783, 1.09302, 
    1.06395, 1.04992, 1.04659, 1.05164, 1.03117, 1.0236, 1.06338, 1.03234, 1.0172, 
    1.01795, 1.01813, 1.01413, 1.00863, 1.01346, 1.00372, 1.00423, 1.00683, 1.04633, 
    1.01796, 1.02279, 1.00629, 1.00205, 1.00316, 1.007, 1.02828, 1.00117, 1.00303, 
    1.00055, 1.02272, 1.00678, 1.00152, 1.00013, 1.01347, 1, 1.00071, 1.00136
)

# Compute cumulative development factors.
cldfs = rev(cumprod(rev(ldfs)))

# Compute percent-of-ultimate factors. 
pous = 1 / cldfs

# Collate data elements within a data.table.
DF = data.table(
    xinit=1:length(pous), ldf0=ldfs, cldf0=cldfs, y=pous, 
    stringsAsFactors=FALSE
)

# Rescale `dev` to be between 0-1 to prevent numerical issues. 
DF[,x:=seq(0, 1, length.out=nrow(DF))]

setcolorder(
    DF, c("xinit", "x", "y", "ldf0", "cldf0")
)

# Method #1
X = poly(DF$x, degree=3, raw=TRUE)
y = DF$y

# Combine design matrix with target response y (pous).
DF0 = setDT(cbind.data.frame(X, y))

# Call lm function. On RHS of formula, `.` specifies all columns in DF0 are to be used. 
mdl = lm(y ~ ., data=DF0)

# Bind reference to fitted values.
DF[,yhat1:=unname(predict(mdl))]


# Custom legend.
exhibitTitle = paste0("Polynomial Regression: Percent-of-Ultimate Modeled vs. Actual")
ggplot(DF) + 
    geom_point(aes(x=xinit, y=y, color="Actual"),  size=2) +
    geom_line(aes(x=xinit, y=yhat1, color="Predicted"), size=1.0) + 
    guides(color=guide_legend(override.aes=list(shape=c(16, NA), linetype=c(0, 1)))) +
    scale_color_manual("", values=c("Actual"="#758585", "Predicted"="#E02C70")) +
    scale_x_continuous(breaks=seq(DF[,min(xinit)], DF[,max(xinit)], 2)) + 
    scale_y_continuous(breaks=seq(0, 1, .1)) + ggtitle(exhibitTitle) +
    theme(
        plot.title=element_text(size=10, color="#E02C70"), 
        axis.title.x=element_blank(), axis.title.y=element_blank(), 
        axis.text.x=element_text(angle=0, vjust=0.5, size=8),
        axis.text.y=element_text(size=8)
        )






# Saving ggplots:
ggsave(
    "C:/Users/i103455/Repos/Tutorials/Supporting/Rsmooth1.png", 
    device="png", width=8, height=5.5, units="in", dpi=100
    )