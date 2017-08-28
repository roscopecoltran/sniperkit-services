package com.vaadin.example.domain.repository.jpa

import com.vaadin.example.domain.entity.Customer
import com.vaadin.example.domain.repository.jpa.custom.CustomerJpaRepositoryCustom
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.querydsl.QuerydslPredicateExecutor

interface CustomerJpaRepository : JpaRepository<Customer, Long>,
        QuerydslPredicateExecutor<Customer>,
        CustomerJpaRepositoryCustom<Customer>