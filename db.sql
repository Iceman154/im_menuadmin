CREATE TABLE `ban` (
  `identifier` varchar(50) NOT NULL DEFAULT '',
  `perma` text NOT NULL,
  `giorni` int(11) DEFAULT 0,
  `data` varchar(50) NOT NULL DEFAULT '0',
  `motivazione` varchar(50) NOT NULL DEFAULT '0',
  `steam` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;