<?php 

namespace Elang\Scraper\es_MX;

use Elang\Scraper\AbstractBaseScraper;
use Elang\Model\Word;

class WordsScraper extends AbstractBaseScraper
{
    public $hostname = 'https://www.memrise.com';

    public $path = 'course/203799/5000-most-frequent-spanish-words';

    public $namespace = 'words';

    public $pageCount = 50;

    const NORMALIZE_CHARS = [
        'Š'=>'S', 'š'=>'s', 'Ð'=>'Dj','Ž'=>'Z', 'ž'=>'z', 'À'=>'A', 'Á'=>'A', 'Â'=>'A', 'Ã'=>'A', 'Ä'=>'A',
        'Å'=>'A', 'Æ'=>'A', 'Ç'=>'C', 'È'=>'E', 'É'=>'E', 'Ê'=>'E', 'Ë'=>'E', 'Ì'=>'I', 'Í'=>'I', 'Î'=>'I',
        'Ï'=>'I', 'Ñ'=>'N', 'Ń'=>'N', 'Ò'=>'O', 'Ó'=>'O', 'Ô'=>'O', 'Õ'=>'O', 'Ö'=>'O', 'Ø'=>'O', 'Ù'=>'U', 'Ú'=>'U',
        'Û'=>'U', 'Ü'=>'U', 'Ý'=>'Y', 'Þ'=>'B', 'ß'=>'Ss','à'=>'a', 'á'=>'a', 'â'=>'a', 'ã'=>'a', 'ä'=>'a',
        'å'=>'a', 'æ'=>'a', 'ç'=>'c', 'è'=>'e', 'é'=>'e', 'ê'=>'e', 'ë'=>'e', 'ì'=>'i', 'í'=>'i', 'î'=>'i',
        'ï'=>'i', 'ð'=>'o', 'ñ'=>'n', 'ń'=>'n', 'ò'=>'o', 'ó'=>'o', 'ô'=>'o', 'õ'=>'o', 'ö'=>'o', 'ø'=>'o', 'ù'=>'u',
        'ú'=>'u', 'û'=>'u', 'ü'=>'u', 'ý'=>'y', 'ý'=>'y', 'þ'=>'b', 'ÿ'=>'y', 'ƒ'=>'f',
        'ă'=>'a', 'î'=>'i', 'â'=>'a', 'ș'=>'s', 'ț'=>'t', 'Ă'=>'A', 'Î'=>'I', 'Â'=>'A', 'Ș'=>'S', 'Ț'=>'T',
    ];

    public function createWord(String $word)
    {
        $word = Word::create(['word' => $word]);

        return $this;
    }

    public function removeDuplicates()
    {
        $letters = $this->getLetters();

        foreach ($letters as $index) {
            $this->index($index)
                ->onFile()
                ->clean()
                ->save();
        }

        return $this;
    }

    public function scrape()
    {
        $page = 0;
        while ($page <= $this->pageCount) {
            $page++;
            print_r("Scraping page: $page");
            $this->index($page)
                ->makeURL()
                ->getBody()
                ->getWords()
                ->separateWordPairs()
                ->orderAlphabetically()
                ->saveToJSONFile()
                ->reset();
        }

        return $this;
    }

    public function saveToJSONFile()
    {
        $wordsByLetter = $this->data;

        foreach ($wordsByLetter as $letter => $group) {
            $this->index($letter)
                ->onFile()
                ->setData($group)
                ->combineJson()
                ->save();
        }

        return $this;
    }

    /**
     * normalize the scraped words array
     * 
     * some of the scraped words come in pairs separated by a comma (word, word)
     * 
     * @param 
     * 
     * @return 
     * */
    public function separateWordPairs()
    {
        $words = $this->data;

        foreach ($words as $word) {
            $w = preg_replace('/\s+/', '', $word);
            if (preg_match('/,/', $w)) {
                $group = explode(',', $w);
                array_splice($words, array_search($word, $words), 1, $group);
            }
        }

        return $this->setData($words);
    }

    public function orderAlphabetically()
    {
        $words = $this->data;

        $wordsByLetter = [];
        foreach ($words as $word) {
            $letter = mb_substr($word, 0, 1);
            if (isset(self::NORMALIZE_CHARS[$letter])) {
                $letter = self::normalizeFirstLetter($letter);
            }
            $wordsByLetter[$letter][] = $word;
        }

        return $this->setData($wordsByLetter);
    }

    static function normalizeFirstLetter(String $letter): string 
    {
        return strtolower(self::NORMALIZE_CHARS[$letter]);
    }

    public function getWords()
    {
        $words = $this->body->filter('.central-column .things .thing.text-text .col_a .text');
        $words->each(function($word){
            array_push($this->data, $word->text());
        });

        return $this;
    }

    public function makeURL()
    {
        $this->url = "{$this->hostname}/{$this->path}/{$this->index}";

        return $this;
    }
}





