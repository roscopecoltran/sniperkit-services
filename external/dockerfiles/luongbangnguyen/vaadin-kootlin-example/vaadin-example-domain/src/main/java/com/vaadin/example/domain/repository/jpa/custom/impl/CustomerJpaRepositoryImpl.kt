package com.vaadin.example.domain.repository.jpa.custom.impl

import com.querydsl.core.BooleanBuilder
import com.vaadin.example.domain.criteria.CustomerCriteria
import com.vaadin.example.domain.entity.Customer
import com.vaadin.example.domain.repository.jpa.custom.CustomerJpaRepositoryCustom
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.querydsl.QuerydslPredicateExecutor

class CustomerJpaRepositoryImpl : CustomerJpaRepositoryCustom<Customer> {

    @Autowired
    private lateinit var customerRepository: QuerydslPredicateExecutor<Customer>

    override fun finAllCustomer(customerCriteria: CustomerCriteria, pageable: Pageable): Page<Customer> {
        val booleanBuilder  = BooleanBuilder()
        if (customerCriteria.filterString.isNotBlank()) {
           booleanBuilder.and(
                   com.vaadin.example.domain.entity.QCustomer.customer.firstName.toLowerCase().contains(customerCriteria.filterString.toLowerCase())
                           .or(com.vaadin.example.domain.entity.QCustomer.customer.lastName.toLowerCase().contains(customerCriteria.filterString.toLowerCase()))
           )
        }

        if (customerCriteria.birthdayBegin != null) {
            booleanBuilder.and(com.vaadin.example.domain.entity.QCustomer.customer.birthDate.goe(customerCriteria.birthdayBegin))
        }

        if (customerCriteria.birthdayEnd != null) {
            booleanBuilder.and(com.vaadin.example.domain.entity.QCustomer.customer.birthDate.loe(customerCriteria.birthdayEnd))
        }
        return customerRepository.findAll(booleanBuilder, pageable)
    }
}