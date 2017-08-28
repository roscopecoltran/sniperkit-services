<?php 

if (file_exists('vendor/autoload.php')) {
    include 'vendor/autoload.php';
}

$app = new Elang\Application;

$lang = 'es_MX';
$scraperMapKey = 'words';
$scraper = $app->getScraper($lang, $scraperMapKey);
// $scraper
//     ->scrape()
//     ->removeDuplicates();

$scraperMapKey = 'verbs';
// $scraper = $app->getScraper($lang, $scraperMapKey);
// $scraper
//     ->scrape()
//     ->removeDuplicates();