package com.vaadin.example.domain.config

import org.springframework.boot.autoconfigure.domain.EntityScan
import org.springframework.context.annotation.Configuration
import org.springframework.data.elasticsearch.repository.config.EnableElasticsearchRepositories
import org.springframework.data.jpa.repository.config.EnableJpaRepositories

@Configuration
@EnableJpaRepositories(basePackages = arrayOf("com.vaadin.example.domain.repository.jpa"))
@EnableElasticsearchRepositories(basePackages = arrayOf("com.vaadin.example.domain.repository.elastic"))
@EntityScan("com.vaadin.example.domain.entity")
class DomainConfig