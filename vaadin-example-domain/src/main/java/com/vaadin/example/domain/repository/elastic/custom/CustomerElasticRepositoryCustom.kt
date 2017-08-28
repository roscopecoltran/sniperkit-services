package com.vaadin.example.domain.repository.elastic.custom

import com.vaadin.example.domain.criteria.CustomerCriteria
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable

interface CustomerElasticRepositoryCustom <T> {
    fun findAllCustomer(customerCriteria: CustomerCriteria, pageable: Pageable) : Page<T>
}