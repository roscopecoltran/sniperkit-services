<?php 

namespace Elang\Model;

use Elang\Application;

abstract class Cypher
{
    public function run(String $query)
    {
        $client = $this->getClient();

        $client->run($query);

        return $client;
    }

    public function getLabel()
    {
        return $this->label;
    }

    public function getNodeParamsString(Array $params = []): string
    {
        $paramsString = '';

        foreach ($params as $key => $value) {
            $paramsString .= "$key:'$value',";
        }

        return '{' . substr($paramsString, 0, -1) . '}';
    }

    public function getLabelAlias(): string
    {
        $alias = substr($this->getLabel(), 0, 1);

        return strtolower($alias);
    }

    public function getClient()
    {
        $app = new Application;
        $app->connect();

        return $app->getConnection();
    }
}