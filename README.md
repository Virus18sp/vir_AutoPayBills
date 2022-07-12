# vir_AutoPayBills
Auto Pay Bill System for QBCore, allow server owners to schedule a task at specific time to charge users invoices based on a pre-defined percent.

# Description
This is a Rebuild for QBCore from original esx_autopaybills (https://github.com/RedAlex/esx_autopaybills)

# Features
- Support for qb-bossmenu.
- Support for qb-management.
- Built in Cron Task.
- Notify users that a Task is Running and may experience some lag, delay or frame drop.
- Notify user that he payed full or partial invoices.
- Multi Job Investment.
- Configurable time to run, enable or disable.
- Online / Offline payment (no matter if players are offline, they will pay they invoces).
- Partially invoice payment if player do not have enough money to pay, they will never go on negative balance.
- Exports for Cron Task so you can use it in another resource.
- Very well commented for easy understand.

# Dependencies
- [qb-bossmenu] (https://github.com/Virus18sp/qb-bossmenu)
- [qb-management](https://github.com/qbcore-framework/qb-management)
- oxmysql 2.0 or higher [(latest recommended)](https://github.com/overextended/oxmysql/releases)
- [qb-core](https://github.com/qbcore-framework/qb-core)

# Installation
- Download resource
- Extract the file, place it in your resources folder and add it to your server.cfg
- Take a look to sv_cfg.lua for Config options
- Enjoy it!

# Credits
- [RedAlex](https://github.com/RedAlex) for original esx resource
- Me for Rebuild it and improve it.
