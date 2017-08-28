<?php 

return [
    'connections' => [
        'default' => 'bolt',
        'neo4j' => [
            'driver' => 'neo4j',
            'host'   => 'localhost',
            'port'   => '7687',
            'username' => 'neo4j',
            'password' => 'neo',
        ]
    ]
];