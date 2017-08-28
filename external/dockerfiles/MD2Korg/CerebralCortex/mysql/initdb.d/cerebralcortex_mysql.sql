-- phpMyAdmin SQL Dump
-- version 4.7.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Aug 23, 2017 at 01:34 PM
-- Server version: 5.7.19-0ubuntu0.16.04.1
-- PHP Version: 7.0.22-0ubuntu0.16.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `cerebralcortex`
--

-- --------------------------------------------------------

--
-- Table structure for table `stream`
--

CREATE TABLE `stream` (
  `identifier` varchar(36) NOT NULL,
  `owner` varchar(36) NOT NULL,
  `name` varchar(150) NOT NULL,
  `data_descriptor` json NOT NULL,
  `execution_context` json NOT NULL,
  `annotations` json NOT NULL,
  `type` varchar(45) NOT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `tmp` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `identifier` varchar(36) NOT NULL,
  `user_name` varchar(80) NOT NULL,
  `password` varchar(100) NOT NULL,
  `token` text NOT NULL,
  `token_issued` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `token_expiry` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `type` varchar(36) NOT NULL,
  `metadata` json NOT NULL,
  `tmp` int(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`identifier`, `user_name`, `password`, `token`, `token_issued`, `token_expiry`, `type`, `metadata`, `tmp`) VALUES
('123', 'string', 'string', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MDM1MTM2MDEsIm5iZiI6MTUwMzUxMzIwMSwiaWRlbnRpdHkiOiJzdHJpbmciLCJmcmVzaCI6ZmFsc2UsImp0aSI6Ijk4MmMwYWQ1LTkzZWMtNDdkZC04NmQ1LTk0YjkwMDNkM2MwZCIsInR5cGUiOiJhY2Nlc3MiLCJ1c2VyX2NsYWltcyI6e30sImlhdCI6MTUwMzUxMzIwMX0.yXypq0xfTG1Jn7CGnpq5CG6_-KDBE9O14Qh2j3y5Krk', '2017-08-23 13:33:21', '2017-08-23 13:40:01', 'md2k', '{}', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `stream`
--
ALTER TABLE `stream`
  ADD PRIMARY KEY (`tmp`),
  ADD KEY `UUID` (`identifier`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`tmp`),
  ADD KEY `UUID` (`identifier`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `stream`
--
ALTER TABLE `stream`
  MODIFY `tmp` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=155;
--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `tmp` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;COMMIT;
