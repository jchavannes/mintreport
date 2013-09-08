CREATE TABLE `transactions` (
  `date` date DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `originalDescription` varchar(150) DEFAULT NULL,
  `amount` decimal(8,2) DEFAULT NULL,
  `transactionType` varchar(10) DEFAULT NULL,
  `category` varchar(40) DEFAULT NULL,
  `accountName` varchar(40) DEFAULT NULL,
  `labels` varchar(40) DEFAULT NULL,
  `notes` varchar(40) DEFAULT NULL
);
