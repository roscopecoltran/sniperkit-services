# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class ListVerseItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    url = scrapy.Field()
    titulo = scrapy.Field()
    category = scrapy.Field()
    name = scrapy.Field()
    body_list = scrapy.Field()
    body_list = scrapy.Field()
    title_list = scrapy.Field()
    author = scrapy.Field()
    time = scrapy.Field()

    paginacion = scrapy.Field()
    pass
