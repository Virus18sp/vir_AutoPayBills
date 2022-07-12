local QBCore = exports['qb-core']:GetCoreObject()
-----------------------------------
------------ Functions ------------
-----------------------------------
local function mathRound(value, numDecimalPlaces)
	if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

local function mathGroupDigits(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1' .. ','):reverse())..right
end

local function JobsInvest(...)
	if Config.UseBossMenu then
		for job, options in pairs(Config.JobsInvestment) do
			if options.enable then
				if Config.Debug then print("Adding money to "..job) end
				TriggerEvent('qb-bossmenu:server:addAccountMoney', job, options.amount)
			end
		end
	elseif Config.UseQBManagement then
		for job, options in pairs(Config.JobsInvestment) do
			if options.enable then
				if Config.Debug then print("Adding money to "..job) end
				exports['qb-management']:AddMoney(job, options.amount)
			end
		end
	end
end

local function PayBills(...)
	if Config.Debug then print("vir_AutoPayBills started") end
	if Config.NotifyTask then TriggerClientEvent('QBCore:Notify', -1, {text = 'Auto Pay Bill System Running', caption = 'You may experience some lag, delay or frame drop!!!'}, "primary", 8000) end
	CreateThread(function()
		Wait(0)
		local result = MySQL.query.await('SELECT * FROM phone_invoices')
		if result and result[1] then
			for i=1, #result, 1 do
				Wait(250) --Slow down process
				local ply = QBCore.Functions.GetPlayerByCitizenId(result[i].citizenid)
				----------------------
				if ply then -- Check if player is online and exist
					----------------------
					local accountMoney = ply.Functions.GetMoney('bank') -- Get player bank balance
					----------------------
					if accountMoney > 0 then -- Check if player have enough money to pay invoices
						----------------------
						local amount = mathRound(accountMoney/100*Config.MaxPercentPay) -- Lets set the percent amount to check below
						----------------------
						if amount >= result[i].amount then -- Check if the percent set in config is enough to cover invoice amount
							----------------------
							ply.Functions.RemoveMoney('bank', result[i].amount, "Past due invoices") -- If Money is enough to cover the full amount, lets remove it 
							----------------------
							TriggerClientEvent('QBCore:Notify', ply.PlayerData.source, "you paid ".. mathGroupDigits(result[i].amount).." on past due invoices", "primary") -- Notify player that has been charged for an invoice
							----------------------
							if result[i].society then -- Check if society is not empty
								----------------------
								if QBCore.Shared.Jobs[result[i].society] then -- Check if society is a valid job
									----------------------
									if Config.UseBossMenu then -- Check if is using BossMenu
										TriggerEvent('qb-bossmenu:server:addAccountMoney', result[i].society, result[i].amount) -- Lets deposit the invoice amount payed to the correct job
									elseif Config.UseQBManagement then -- Check if is using QB-Management
										exports['qb-management']:AddMoney(result[i].society, result[i].amount) -- Lets deposit the invoice amount payed to the correct job
									end
									----------------------
								end
								----------------------
							end
							----------------------
							MySQL.query('DELETE FROM phone_invoices WHERE id = ?', {result[i].id}) -- Delete payed invoice from table
							----------------------
							if Config.Debug then print(ply.PlayerData.name.." pay "..result[i].amount.." from bill to "..result[i].society) end -- Print in console if debug is true
							----------------------
						else -- Partial Payment (under test)
							----------------------
							local amount = mathRound(accountMoney/100*Config.MaxPercentPay) -- Lets set the percent amount to check below
							----------------------
							if result[i].amount >= amount then -- Check if invoice amount is more or equal than player balance
								----------------------
								ply.Functions.RemoveMoney('bank', amount, "Past due invoices | Partial Payment") -- Here we will remove the percent amount cause its not enough to cover the full invoice amount 
								----------------------
								TriggerClientEvent('QBCore:Notify', ply.PlayerData.source, "you paid partially ".. mathGroupDigits(amount).." on past due invoices", "primary") -- Notify player that has been charged for an invoice
								----------------------
								if result[i].society then -- Check if society is not empty
									----------------------
									if QBCore.Shared.Jobs[result[i].society] then -- Check if society is a valid job
										----------------------
										if Config.UseBossMenu then -- Check if is using BossMenu
											TriggerEvent('qb-bossmenu:server:addAccountMoney', result[i].society, amount) -- Lets deposit the amount payed to the correct job
										elseif Config.UseQBManagement then -- Check if is using QB-Management
											exports['qb-management']:AddMoney(result[i].society, amount) -- Lets deposit the amount payed to the correct job
										end
										----------------------
									end
									----------------------
								end
								----------------------
								MySQL.update('UPDATE phone_invoices SET amount = amount - :partialpayment WHERE id = :id', {partialpayment = amount, id = result[i].id}) -- Update invoice amount 
								----------------------
								if Config.Debug then print(ply.PlayerData.name.." pay partially "..amount.." from bill to "..result[i].society) end -- Print in console if debug is true
								----------------------
							end
						end
						
					end
			-----------------------
			--- Offline Payment ---		
			-----------------------
				else -- It doesn't matter if you're offline, you'll still pay
					----------------------
					local jsonres = MySQL.scalar.await('SELECT money FROM players WHERE citizenid = ?', {result[i].citizenid}) -- Lets fetch user money accounts
					----------------------
					local accounts = json.decode(jsonres) -- Decode Json Accounts
					----------------------
					if accounts.bank > 0 then -- Lets check if not is broke lol
						----------------------
						local amount = mathRound(accounts.bank/100*Config.MaxPercentPay) -- Lets set the percent amount to check below
						----------------------
						if amount >= result[i].amount then -- Check if the percent set in config is enough to cover invoice amount
							----------------------
							accounts.bank = accounts.bank - result[i].amount -- Lets set the new balance
							----------------------
							MySQL.update('UPDATE players SET money = :accounts WHERE citizenid = :cid',{accounts = json.encode(accounts), cid = result[i].citizenid}) -- Save new money balance
							----------------------
							if result[i].society then -- Check if society is not empty
								----------------------
								if QBCore.Shared.Jobs[result[i].society] then -- Check if society is a valid job
									----------------------
									if Config.UseBossMenu then -- Check if is using BossMenu
										TriggerEvent('qb-bossmenu:server:addAccountMoney', result[i].society, result[i].amount) -- Lets deposit the amount payed to the correct job
									elseif Config.UseQBManagement then -- Check if is using QB-Management
										exports['qb-management']:AddMoney(result[i].society, result[i].amount) -- Lets deposit the amount payed to the correct job
									end
									----------------------
								end
								----------------------
							end
							----------------------
							MySQL.query('DELETE FROM phone_invoices WHERE id = ?', {result[i].id}) -- Delete payed invoice from table
							----------------------
							if Config.Debug then print(ply.PlayerData.name.." pay "..result[i].amount.." from bill to "..result[i].society) end -- Print in console if debug is true
							----------------------
						else -- Partial Payment (under test)
							----------------------
							local amount = mathRound(accounts.bank/100*Config.MaxPercentPay) -- Lets set the percent amount to check below
							----------------------
							if result[i].amount >= amount then -- Check if invoice amount is more than player balance
								----------------------
								accounts.bank = accounts.bank - amount -- Lets set the new balance
								----------------------
								MySQL.update('UPDATE players SET money = :accounts WHERE citizenid = :cid',{accounts = json.encode(accounts), cid = result[i].citizenid}) -- Save new money balance
								----------------------
								MySQL.update('UPDATE phone_invoices SET amount = amount - :partialpayment WHERE id = :id',{partialpayment = amount, id = result[i].id}) -- Update invoice amount 
								----------------------
								if result[i].society then -- Check if society is not empty
									----------------------
									if QBCore.Shared.Jobs[result[i].society] then -- Check if society is a valid job
										----------------------
										if Config.UseBossMenu then -- Check if is using BossMenu
											TriggerEvent('qb-bossmenu:server:addAccountMoney', result[i].society, amount) -- Lets deposit the amount payed to the correct job
										elseif Config.UseQBManagement then -- Check if is using QB-Management
											exports['qb-management']:AddMoney(result[i].society, amount) -- Lets deposit the amount payed to the correct job
										end
										----------------------
									end
									----------------------
								end
								----------------------
								if Config.Debug then print(result[i].citizenid.." pay partially "..amount.." from bill to "..result[i].society) end -- Print in console if debug is true
								----------------------
							end
						end
					end
				end
			end
		end
	end)
end

if Config.JobsInvest.enable then
	exports.vir_AutoPayBill:RunTask(Config.JobsInvest.hour, Config.JobsInvest.minutes, JobsInvest)
end

if Config.AutoPayBills.enable then
	exports.vir_AutoPayBill:RunTask(Config.AutoPayBills.hour, Config.AutoPayBills.minutes, PayBills)
end

if Config.Debug then
	-- Command to Test Auto Pay Bills --
		QBCore.Commands.Add('testBills', 'Test Bills | AutoPayBills (GOD Only)', {}, false, function(source)
			PayBills()
		end, 'god')

-- Command to Test Auto Pay Bills Job Invest --
		QBCore.Commands.Add('testInvest', 'Test Invest | AutoPayBills (GOD Only)', {}, false, function(source)
			JobsInvest()
		end, 'god')
end
