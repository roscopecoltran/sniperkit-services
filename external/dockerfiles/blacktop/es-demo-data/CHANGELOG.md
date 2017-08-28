Change Log
==========

All notable changes to this project will be documented in this file.

[5.0] - 2016-11-06
------------------

### Fixed

### Added

-	ability to pass in basic auth creds for elasticsearch clusters that need it
-   ability to change the Bulk ingest size with the env var `BULK_SIZE` (defaults to 5MB)
-   ability to change the elasticsearch host with the env var `ES_URL` (defaults to "http://elasticsearch:9200")
-   ability to change the es host that import-dashboard uses as well with the env var `ES_URL`

### Removed

-	use of logstash (I want to use the new ingest nodes instead)

### Changed
