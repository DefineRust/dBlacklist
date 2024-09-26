dbl.config = dbl.config or {}

--									Data

dbl.config["DataMode"] = "file"						-- Database mode, must be "sql" or "file".
dbl.config["DatabaseName"] = "dbl_blacklist"		-- The name to be used for SQL database or file name.

--									Ranks

dbl.config["Ranks"] = {
	["Staff"] = {									-- Ranks that will be able to add / remove models to blacklist.
		["superadmin"] = true,
	},
}