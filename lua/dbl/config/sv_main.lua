dbl.config = dbl.config or {}

--									Data

dbl.config["DataMode"] = "file"						-- Database mode, must be "sqlite", "file" or "sql".
dbl.config["DatabaseName"] = "dbl_blacklist"		-- The name to be used for SQLlite database or file name.

--									SQL

dbl.config["sql"] = {
	host = "ip",
	username = "dbusername",
	password = "dbpassword",
	dbname = "dbname",
	port = 3306
}

--									Ranks

dbl.config["Ranks"] = {
	["Staff"] = {									-- Ranks that will be able to add / remove models to blacklist.
		["superadmin"] = true,
	},
}