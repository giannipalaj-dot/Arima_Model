###############################################################################
# Retail Food & Beverage Sales: Seasonal ARIMA Forecast
# Author : Gianni Palaj
# Date   : November 1, 2026
# Data   : Chapter_03.csv (monthly sales, Jan 1992 - Sep 2017, 309 obs)
# Goal   : Forecast the next 30 months of sales
###############################################################################


# 0. Packages ----------------------------------------------------------------
# install.packages(c("astsa", "forecast", "tseries"), dependencies = TRUE)
library(astsa)
library(forecast)
library(tseries)
library(ggplot2)


# 1. Load data ---------------------------------------------------------------
setwd("C:/Users/giann/Desktop/BUA 650")

data1 <- read.csv("Chapter_03.csv", header = TRUE, sep = ",")
head(data1)

data <- ts(data1$sales, start = c(1992, 1), frequency = 12)
data


# 2. Exploratory analysis ----------------------------------------------------
start(data)
end(data)
frequency(data)
class(data)
summary(data)
sum(is.na(data))   # 0 missing values

# Upward trend with a December peak each year -> non-stationary
plot(data, xlab = "Years", ylab = "Sales (millions of dollars)",
     main = "Monthly Retail Food and Beverage Sales")

ggseasonplot(data, year.labels = TRUE, year.labels.left = TRUE) +
  labs(title = "Seasonal Plot: Sales by Month, One Line per Year",
       y = "Sales (millions of dollars)")

acf2(data, max.lag = 24)

# ADF test: p = 0.47, so the series is non-stationary
adf_result <- adf.test(data)
print(adf_result)


# 3. Differencing ------------------------------------------------------------
datadiff12 <- diff(data, lag = 12)
plot.ts(datadiff12, main = "Seasonally Differenced Sales (lag 12)")

diff1and12 <- diff(datadiff12, lag = 1)
plot(diff1and12, main = "Trend and Seasonally Differenced Sales")

adf.test(diff1and12)   # stationary after d = 1, D = 1

acf2(diff1and12, max.lag = 36)
# Starting model from ACF/PACF: ARIMA(2,1,1)(2,1,2)[12]


# 4. Model 1: ARIMA(2,1,1)(2,1,2)[12] ----------------------------------------
model1 <- arima(data, order = c(2, 1, 1),
                seasonal = list(order = c(2, 1, 2), period = 12))
summary(model1)   # AIC = 4607.83

Acf(residuals(model1), main = "Model 1 Residual ACF")
Box.test(residuals(model1), lag = 24, fitdf = 7, type = "Ljung-Box")
# p = 0.0006: autocorrelation remains (spike at lag 5)


# 5. Model 2: ARIMA(6,1,1)(2,1,2)[12] ----------------------------------------
model2 <- arima(data, order = c(6, 1, 1),
                seasonal = list(order = c(2, 1, 2), period = 12))
summary(model2)   # AIC = 4600.89, MAPE = 0.877%

Acf(residuals(model2), main = "Model 2 Residual ACF")
Box.test(residuals(model2), lag = 24, fitdf = 11, type = "Ljung-Box")
# p = 0.009


# 6. auto.arima comparison ---------------------------------------------------
best_model <- auto.arima(data)
summary(best_model)   # ARIMA(2,1,2)(0,1,2)[12], AIC = 4645.12

Box.test(residuals(best_model), lag = 24, fitdf = 6, type = "Ljung-Box")

c(model1 = AIC(model1), model2 = AIC(model2), auto = AIC(best_model))


# 7. 30-month forecast (Oct 2017 - Mar 2020) ---------------------------------
Pred <- forecast(model2, h = 30)
Pred

plot(Pred, ylab = "Sales (millions of dollars)", xlab = "Year",
     main = "30-Month Forecast: ARIMA(6,1,1)(2,1,2)[12]")


# 8. Holdout test (train: Jan 1992 - Sep 2015, test: Oct 2015 - Sep 2017) ------
train <- window(data, end = c(2015, 9))
test  <- window(data, start = c(2015, 10))

model2_train <- Arima(train, order = c(6, 1, 1),
                      seasonal = list(order = c(2, 1, 2), period = 12))
auto_train   <- auto.arima(train)

fc_model2 <- forecast(model2_train, h = 24)
fc_auto   <- forecast(auto_train,   h = 24)

autoplot(window(data, start = c(2012, 1))) +
  autolayer(fc_model2, series = "ARIMA(6,1,1)(2,1,2)[12]", PI = FALSE) +
  autolayer(fc_auto,   series = "auto.arima", PI = FALSE) +
  geom_vline(xintercept = 2015 + 9/12, linetype = "dashed") +
  labs(title = "Holdout Test: Forecasts vs. Actual Sales (Oct 2015 - Sep 2017)",
       subtitle = "Models fit on data to the left of the dashed line only",
       x = "Year", y = "Sales (millions of dollars)", colour = "Model")

accuracy(fc_model2, test)
accuracy(fc_auto,   test)
# Model 2 test MAPE 0.81% vs auto.arima 0.82%: nearly identical
