package com.vaadin.example.domain.repository.jpa.custom

import com.vaadin.example.domain.criteria.CustomerCriteria
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable

interface CustomerJpaRepositoryCustom<T> {
    fun finAllCustomer(customerCriteria: CustomerCriteria, pageable: Pageable): Page<T>
}