Config = {}
Config.NotifyTask = true -- True to send a Notification to all players that can experience some performance degradation do to Massive Auto Pay Bill Running, False to disable it
Config.MaxPercentPay = 10 -- Percent to take from player money to pay bills | 10 = 10%

-- Society Manager -- NEED TO CHOOSE ONE, BOTH CAN'T BE TRUE
Config.UseBossMenu = true -- qb-bossmenu
Config.UseQBManagement = false -- qb-management

Config.Debug = true --Set true to have "test" console commands and debug print

Config.AutoPayBills = {
    enable = true, --If set to true auto pay bill at the time you set with a maximum of % of player bank account
    hour = 20, -- 24hrs format | ex. 20:00 = 8:00pm
    minutes = 00
}

-- If want to invest in some jobs funds, enable this below
Config.JobsInvest = {
    enable = true, -- If set to true will add money in societys at Config.JobsInvestment at time you set
    hour = 13, -- 24hrs format | ex. 13:00 = 1:00pm
    minutes = 00
}

-- ADD all jobs you want to invest --
Config.JobsInvestment = {
    ["police"] = {
        enable = true,
        amount = 50000
    },
    ["ambulance"] = {
        enable = true,
        amount = 25000
    },
    ["mechanic"] = {
        enable = true,
        amount = 15000
    }
}
