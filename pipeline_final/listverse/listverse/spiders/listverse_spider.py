from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
#from scrapy.selector import HtmlXPathSelector
from scrapy.selector import Selector
from listverse.items import ListVerseItem
from time import time
import csv
import re
import string
import sys
import json
import sqlite3



try:
    # crea la tabla paa poner los articulos
    conn = sqlite3.connect('/data/listverse.db')
    c = conn.cursor()
    c.execute("""CREATE TABLE articles
                (url varchar(255), date varchar(255), title varchar(255), category varchar(255), author varchar(255), body varchar(50000), PRIMARY KEY (url))""")

    conn.commit()
    conn.close()
except:
    pass


class ListVerseSpider(CrawlSpider):
    name = 'lv_crawler'
    allowed_domains = ["http://listverse.com/","listverse.com"]
    start_urls =['http://listverse.com/',
                 r'http://listverse.com/science-nature/page/[0-9]+/*',
                 r'http://listverse.com/bizarre/[0-9]+/*',
                 r'http://listverse.com/entertainment/page/[0-9]+/*',
                 r'http://listverse.com/fact-fiction/page/[0-9]+/*',
                 r'http://listverse.com/leisure-travel/page/[0-9]+/*',
                 r'http://listverse.com/people-politics/page/[0-9]+/*',
                 r'http://listverse.com/shopping/page/[0-9]+/*',
                 r'http://listverse.com/[0-9]+/[0-9]+/[0-9]+/*',

                 ]
    rules = [
            Rule(LinkExtractor(allow=[r'.*listverse.com/\d+/\d+/\d+/*']), callback='parse_articles'),
            Rule(LinkExtractor(allow=[r'.*listverse.*']), callback='parse_paginacion',follow=True),
        ]




    # We can also close the connection if we are done with it.
    # Just be sure any changes have been committed or they will be lost.

    def parse_paginacion(self,response):
        item = ListVerseItem()
        item['paginacion'] = response.url
        #yield item

    def parse_articles(self, response):
        #item = ListVerseItem()
        item = {}
        item['title'] = response.xpath('//h1/text()').extract()[0]#.encode('utf-8')
        item['url'] = response.url
        item['category'] = response.xpath('//section[@class="new the-article"]/article/a[@class="title-category"]/text()').extract()[0]

        item['author'] = response.xpath('//article/p/span[@class="author"]/a/text()').extract()[0].encode('utf8')
        item['date'] = response.xpath('//article/p/time/text()').extract()[0]

        item['body'] = ' '.join(response.xpath('//article/p/text()').extract()).encode('utf8')
        #item['title_list'] = response.xpath('//article/h2/text()').extract()
        conn = sqlite3.connect('/Users/juanzinser/Documents/MCC/gran_escala/dpa_djms/proyecto/listverse.db')
        c = conn.cursor()
        query_insert = """INSERT INTO articles (url,date,title,category,author,body) VALUES ('{url}','{date}','{title}','{category}','{author}','{body}')""".format(
            url = item['url'], date = item['date'], title = item['title'], category = item['category'], author = item['author'], body = item['body']
        )
        #print(query_insert)
        c.execute(query_insert)
        conn.commit()

        conn.close()

        """
        with open('/Users/juanzinser/Documents/MCC/gran_escala/taller-de-scraping/scrapy/listverse/data/'+item['titulo']+'.json', 'w') as fp:
            json.dump(item, fp)
        """

        yield item
