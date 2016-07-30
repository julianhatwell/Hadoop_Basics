library(readr)
library(data.table)
library(dplyr)
fileloc <- "C:\\Dev\\Study\\Hadoop\\big_data_capstone_datasets_and_scripts\\"
folders <- paste0(c("chat", "combined", "flamingo"), "-data")
files <- list()
paths <- character(0)

for (folder in folders) {
  files[[folder]] <- dir(paste0(fileloc, folder))
}
for (i in seq_along(folders)) {
  paths[i] <- paste0(fileloc, folder)
}

listing <- character(0)
fullpathlisting <- character(0)
for (i in seq_along(folders)) {
  listing <- c(listing, files[[folders[i]]])
  fullpathlisting <- c(fullpathlisting
                       , paste0(fileloc
                                , folders[i]
                                , "\\"
                                , files[[folders[i]]]))
}

for (i in seq_along(listing)) {
  print(paste("assigning", listing[i]))
  headers <- !(grepl("^chat.*", listing[i]))
  assign(listing[i], read_csv(fullpathlisting[i], col_names = headers, na = "NULL"))
}

length(unique(`buy-clicks.csv`$buyId))
sum(`buy-clicks.csv`$price)

lattice::barchart(tapply(`buy-clicks.csv`$buyId, `buy-clicks.csv`$buyId, length), horizontal = FALSE, ylab = "Number of items purchased", xlab = "buyId (item Id)", col = "violetred")

lattice::barchart(tapply(`buy-clicks.csv`$price, `buy-clicks.csv`$buyId, sum), horizontal = FALSE, ylab = "Total Revenue", xlab = "buyId (item Id)", col = "violetred")

lattice::barchart(head(sort(tapply(`buy-clicks.csv`$price, `buy-clicks.csv`$userId, sum), decreasing = TRUE), 10), horizontal = FALSE, xlab = "userId", ylab = "Total Revenue")

top3 <- head(sort(tapply(`buy-clicks.csv`$price, `buy-clicks.csv`$userId, sum), decreasing = TRUE), 3)
tapply(`game-clicks.csv`$isHit, `game-clicks.csv`$userId, function(x) {
  sum(x)/length(x)
})[names(top3)]

numAdClicks <- tapply(`ad-clicks.csv`$txId, `ad-clicks.csv`$adCategory, length)
sum(numAdClicks * ifelse(names(numAdClicks) == "electronics", 0.75, 0.4))

hitRatio <- tapply(`game-clicks.csv`$isHit, `game-clicks.csv`$userId, function(x) { sum(x)/length(x) } )
HitRatio <- setkey(data.table(userId = as.numeric(dimnames(hitRatio)[[1]])
                       , hitRatio = hitRatio), userId)

lattice::densityplot(hitRatio)

totalMoneySpent <- tapply(`buy-clicks.csv`$price, `buy-clicks.csv`$userId, sum)
TotalMoneySpent <- setkey(data.table(userId = as.numeric(dimnames(totalMoneySpent)[[1]])
                              , totalMoneySpent = totalMoneySpent), userId)

lattice::densityplot(totalMoneySpent)

sessionStarts <- `user-session.csv`[`user-session.csv`$sessionType == "start",]
sessionEnds <- `user-session.csv`[`user-session.csv`$sessionType == "end",]

combinedSessions <- dplyr::inner_join(sessionStarts, sessionEnds, by = c("userSessionId", "userId"))
sessionDuration <- data.frame(userId = combinedSessions$userId
                           , sessionDuration = combinedSessions$timestamp.y - combinedSessions$timestamp.x)
totalTimeSpent <- tapply(sessionDuration$sessionDuration, sessionDuration$userId, sum)
TotalTimeSpent <- setkey(data.table(userId = as.numeric(dimnames(totalTimeSpent)[[1]])
                             , totalTimeSpent = totalTimeSpent), userId)

lattice::densityplot(totalTimeSpent)

team <- setkey(data.table(team.csv), teamId)
names(`team-assignments.csv`) <- c("timestamp", "teamId", "userId", "assignmentId")
user.team <- setkey(data.table(`team-assignments.csv`), teamId)
user.team.stats <- setkey(team[J(user.team)][!(is.na(strength)), .(numTeams = .N, aveStrength = mean(strength)), by = userId], userId)

lattice::densityplot(user.team.stats$aveStrength)

naToZero <- function(x) {if (is.na(x)) 0 else x }

(comb <- TotalMoneySpent[J(TotalTimeSpent)][J(HitRatio)][J(user.team.stats)][, `:=`(
  totalMoneySpent = sapply(totalMoneySpent, naToZero)
  , totalTimeSpent = sapply(totalTimeSpent, naToZero))][!(is.na(hitRatio)) & totalTimeSpent > 0.00,])

write.csv(comb
          , file = paste0(fileloc, "HitsTimeMoney.csv")
          , row.names = FALSE)

# radial graphs of clusters
clusts <- read.csv(paste0(fileloc, "TeamUserStats.csv"))
scaledClusts <- as.data.frame(lapply(clusts[,3:6], scale))

lattice::parallelplot(scaledClusts[,2:5]
                      , key = simpleKey(
                          text = as.character(clusts[,2])
                          , points = FALSE
                          , lines = TRUE
                          , cex = 0.7
                          , columns = 3)
                      , aspect = 0.175
                      , horizontal.axis = FALSE)

# adding chat data
chattyUsers <- setkey(data.table(read.csv(paste0(fileloc, "chattyUsers.csv"))), userId)
(comb <- chattyUsers[J(comb)][, numChatItems := sapply(numChatItems, naToZero)])

xyplot(aveStrength~numChatItems, data = comb)

chattyTeams <- setkey(data.table(read.csv(paste0(fileloc, "chattyTeams.csv"))), teamId)
teams <- setkey(data.table(team.csv), teamId)
(teams <- chattyTeams[J(teams)][, numChatItems := sapply(numChatItems, naToZero)])

xyplot(strength~numChatItems, data = teams)



nonSessionClicks <- `game-clicks.csv`[`game-clicks.csv`$userId %in% as.numeric(comb[totalTimeSpent == 0.00, userId]),]
sessionsToCheck <- unique(nonSessionClicks$userSessionId)

# reported issues with the data
# write.csv(comb[totalTimeSpent == 0.00, userId]
#           , file=paste0(fileloc, "UsersNotInUserSessions.csv")
#           , row.names = FALSE)
# 
# write.csv(sessionsToCheck
#           , file=paste0(fileloc, "SessionsNotInUserSessions.csv")
#           , row.names = FALSE)


# teams in team-assignments not in team
tnt <- unique(anti_join(`team-assignments.csv`, team.csv, by = c("team" = "teamId"))$team)
team.csv[team.csv$teamId %in% tnt, ]
`team-assignments.csv`[`team-assignments.csv`$team %in% team.csv$teamId, ]

# teams in team and team assignments
tit <- unique(`team-assignments.csv`[`team-assignments.csv`$team %in% team.csv$teamId, "team"])
