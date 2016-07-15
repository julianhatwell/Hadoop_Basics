rev <- data.table(revenue = sort(tapply(`buy-clicks.csv`$price
                  , `buy-clicks.csv`$userId
                  , sum)
           , decreasing = TRUE))
rev$userId = as.integer(row.names(rev))
setkey(rev, userId)

plat <- setkey(data.table(unique(`user-session.csv`[`user-session.csv`$sessionType == "start"
  , c("userId", "platformType")])), userId)

hr <- data.table(hitR = hitRatio)
hr$userId <- as.integer(row.names(hr))
setkey(hr, userId)

rev_plotting <- plat[J(rev)][!is.na(platformType),]
rev_plotting <- hr[J(rev_plotting)][, platformType := factor(platformType)]

barchart(factor(userId)~revenue, data = rev_plotting
        , groups = factor(platformType)
        , border = "transparent"
        , horizontal = FALSE
        , scales = list(
          x = list(draw = FALSE)
        )
        , ylab = "Total Revenue"
        , auto.key = TRUE)

xyplot(revenue~hitR
       , data = rev_plotting
       , groups = platformType
       , xlim = c(0, 0.2)
       , panel = panel.superpose
       , panel.groups = function(x,y, ...) {
         panel.xyplot(x, y, ...)
         panel.lmline(x, y, ...)
       }
       , auto.key = TRUE)

xyplot(revenue~hitR | platformType
       , data = rev_plotting
       , subset = hitR < 0.2
       , groups = platformType
       #, xlim = c(0, 0.2)
       , panel = function(x,y, ...) {
         panel.xyplot(x, y, ...)
         panel.lmline(x, y, ...)
       })
