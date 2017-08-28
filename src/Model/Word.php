<?php 

namespace Elang\Model;

class Word extends Cypher 
{
    protected $label = 'Word';

    public static function create(Array $params = [])
    {
        $cypher = new static;

        $label = $cypher->getLabel();

        $paramsString = $cypher->getNodeParamsString($params);

        $query = "CREATE (w:$label ${paramsString}) RETURN w";

        return $cypher->run($query);
    }
}