<?php 

namespace Elang;

use GraphAware\Neo4j\Client\ClientBuilder;

class Application
{
    protected $connection;

    public function run()
    {
        return $this;
    }

    public function connect()
    {
        $databaseConfig = dirname(__DIR__, 1) . '/config/database.php';
        $connections = require($databaseConfig);
        $type = $connections['connections']['default'];
        $neo4j = $connections['connections']['neo4j'];
        $connection = "$type://${neo4j['username']}:${neo4j['password']}@${neo4j['host']}:${neo4j['port']}";

        try {
            $this->connection = ClientBuilder::create()
                                            ->addConnection($type, $connection)
                                            ->build();
        } catch (\Exception $e) {
            error_log($e->getMessage());
            die();
        }

        return $this;
    }

    public function getConnection()
    {
        return $this->connection;
    }

    public function getScraper(String $lang, String $scraperMapKey)
    {
        $scraper = ucwords($scraperMapKey) . 'Scraper';
        $className = "Elang\Scraper\\{$lang}\\{$scraper}";

        return new $className($lang);
    }
}