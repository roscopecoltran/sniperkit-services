<?php 

namespace Elang\Scraper;

use Elang\Application;
use Wa72\HtmlPageDom\HtmlPageCrawler;
use Wa72\HtmlPageDom\HtmlPage;

abstract class AbstractBaseScraper extends Application {

    public $hostname = '';

    public $path = '';

    public $directory = '';

    public $namespace = '';

    public $lang = '';

    public $response = '';

    public $body = '';

    public $index = '';

    public $data = [];

    public $lettersPathString = 'a_b_c_d_e_f_g_h_i_j_k_l_m_n_o_p_q_r_s_t_u_v_w_x_y_z';

    abstract public function scrape();

    public function __construct(String $langCode)
    {
        $this->setLang($langCode);

        $directory = dirname(__DIR__, 2) . "/lib/lang/{$this->lang}/{$this->namespace}";
        $this->setDirectory($directory);
    }

    public function reset()
    {
        $this->data = [];

        return $this;
    }

    public function getLetters(): array
    {
        return explode('_', $this->lettersPathString);
    }

    public function createJsonFile(String $content)
    {
        $file = fopen($this->file, 'w');
        fwrite($file, $content);
        fclose($file);

        return $this;
    }

    public function onFile()
    {
        $this->file = "{$this->directory}/{$this->index}.json";

        return $this;
    }

    public function setData($data)
    {
        $this->data = $data;

        return $this;
    }

    public function createDirectory()
    {
        mkdir($this->directory);

        return $this;
    }

    public function combineJson()
    {   
        if (!file_exists($this->directory)) {
            $this->createDirectory();
        }

        if (!file_exists($this->file)) {
            $this->createJsonFile('[]');
        }

        $data = file_get_contents($this->file);

        $tempArray = json_decode($data, true);

        $content = array_merge($tempArray, $this->data);

        $jsonData = json_encode($content, JSON_PRETTY_PRINT);

        return $this->setData($jsonData);
    }

    public function clean()
    {
        $data = file_get_contents($this->file);
        
        $content = json_decode($data, true);
        
        $newContent = array_unique($content);

        $jsonData = json_encode(array_values($newContent), JSON_PRETTY_PRINT);

        return $this->setData($jsonData);
    }

    public function index($index)
    {
        $this->index = $index;

        return $this;
    }

    public function save()
    {
        file_put_contents($this->file, $this->data);

        return $this;
    }

    public function getBody()
    {
        $page = new HtmlPage(file_get_contents($this->url));
        $this->body = $page->filter('body');

        return $this;
    }

    public function getHTMLPage()
    {
        $curl = curl_init($this->url);
        curl_setopt_array($curl, [
            CURLOPT_RETURNTRANSFER => 1,
            CURLOPT_HEADER => 0,
            ]);
        $result = curl_exec($curl);

        if (!$result) {
            print_r("ERROR: ${curl_error($curl)}"); exit;
        }

        $this->response = $result;

        curl_close($curl);

        return $this;
    }

    public function setLang(String $lang)
    {
        $this->lang = $lang;

        return $this;
    }

    public function setDirectory(String $directory)
    {
        $this->directory = $directory;

        return $this;
    }

    public function setNamespace(String $namespace)
    {
        $this->namespace = $namespace;

        return $this;
    }
}