package com.vaadin.example.domain.service

import com.vaadin.example.domain.criteria.CustomerCriteria
import com.vaadin.example.domain.entity.Customer
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable

interface CustomerService {
    fun findAll(customerCriteria: CustomerCriteria, pageable: Pageable) : Page<Customer>
    fun save(customer: Customer): Customer
    fun delete(customer: Customer)
}