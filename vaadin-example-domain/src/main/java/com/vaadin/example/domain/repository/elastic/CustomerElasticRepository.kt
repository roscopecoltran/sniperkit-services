package com.vaadin.example.domain.repository.elastic

import com.vaadin.example.domain.entity.Customer
import com.vaadin.example.domain.repository.elastic.custom.CustomerElasticRepositoryCustom
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository

interface CustomerElasticRepository : ElasticsearchRepository<Customer, Long>, CustomerElasticRepositoryCustom<Customer>