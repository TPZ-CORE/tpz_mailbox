
CREATE TABLE IF NOT EXISTS `mailbox` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_username` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `sender_uniqueId` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `receiver_uniqueId` varchar(50) DEFAULT NULL,
  `title` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `message` longtext CHARACTER SET utf16 COLLATE utf16_unicode_ci NOT NULL,
  `city` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `timestamp` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `viewed` int(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22448 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `mailbox_registrations` (
  `uniqueId` varchar(50) NOT NULL,
  `charidentifier` int(11) NOT NULL DEFAULT 0,
  `identifier` varchar(50) NOT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`uniqueId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
