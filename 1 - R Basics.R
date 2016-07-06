######################################
### R For The SQL Server Developer ###
### Kevin Feasel                   ###
### 1 - R Basics                   ###
######################################

#We set a variable using the <- construct
y <- 500
#We can also assign a multi-element vector using <-
#The . in R is like _ in C-based languages.
our.second.vector <- c(10.4, 11.9, 38.1, 2.2, 0.7664)
#Of course, the _ in R is also like the _ in C-based languages!
our_third_vector <- c(9.99, 19.99, 29.99)

#We can also create a function using the same construct
normalize <- function(x) {
  #standardize values of x; subtract mean & rescale so sd = 1
  (x-mean(x))/sd(x)
}

#Help is a great way of getting more information.
#If you're feeling particularly lazy, you can use ? like ?rnorm
help(rnorm)

#And a vector.  <- is powerful!
#rnorm(100) returns a vector of 100 values fit a normal distribution of
  #mean 0 and standard deviation 1.
  #We want to show off our normalize function, so we'll shift the results
  #by multiplying each value by 5 and adding 2 to each value.
#Note that there's no foreach loop, no for loop, etc.  Like SQL, RBAR is a
  #no-no in general here.  Better to use set-based operations, as they're MUCH
  #faster!
x <- rnorm(100)*5+2
#Call our function on the data set x and put the results into z.
z <- normalize(x)

#We can call built-in methods easily.  We want to make sure that after
#normalization, our mean is (appx) 0 and our standard deviation is (appx) 1
mean(z)
sd(z)
#Just to make sure I'm not cheating, here are the mean and sd for x
mean(x)
sd(x)

#Looking at charts of numbers is cool and all, but visuals are easier to follow
#This visual proves that our normalize function does NOT change the distribution
plot(x,z)

