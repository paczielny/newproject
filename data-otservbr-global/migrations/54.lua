function onUpdateDatabase()
	logger.info("Updating database to version 54 (weapon proficiencies")
	db.query("ALTER TABLE `players` ADD `weapon_proficiencies` mediumblob DEFAULT NULL;")
end
