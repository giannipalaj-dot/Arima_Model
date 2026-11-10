Retail Food & Beverage Sales Forecasting with Seasonal ARIMA

Time series analysis and forecasting of monthly retail food and beverage sales in R, using seasonal ARIMA (SARIMA) models.

Overview

The goal is to forecast the next 30 months of sales (Oct 2017 to Mar 2020). The script walks through exploratory analysis, stationarity testing, model selection, residual diagnostics, forecasting, and a holdout test of out-of-sample accuracy.

Data

Chapter_03.csv contains synthetic monthly sales from January 1992 to September 2017.
309 observations, no missing values.

Methodology
1. Exploratory analysis: time plot, seasonal plot, ACF/PACF. Sales show an upward trend and a December peak each year.
2. Stationarity: Augmented Dickey-Fuller test on the raw series (p = 0.47, non-stationary), then a seasonal difference (lag 12) plus a first difference, after which the series is stationary.
3. Model identification: ACF/PACF of the differenced series suggest a starting model of ARIMA(2,1,1)(2,1,2)[12].
4. Model comparison: two hand-built models and auto.arima, compared on AIC, error measures, and Ljung-Box residual tests.
5. Forecast: 30-month forecast with 80% and 95% prediction intervals.
6. Holdout test: models fit on Jan 1992 to Sep 2015 and scored on the final 24 months.

Results

ARIMA(6,1,1)(2,1,2)[12] had the lowest AIC and was used for the final forecast. On the 24-month holdout it reached a test MAPE of about 0.81%, versus 0.82% for auto.arima, so the two forecast almost equally well. Neither model fully passed the Ljung-Box test, which suggests some autocorrelation remains in the residuals.


