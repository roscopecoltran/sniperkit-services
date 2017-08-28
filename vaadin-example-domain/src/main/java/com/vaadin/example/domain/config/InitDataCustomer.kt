package com.vaadin.example.domain.config

import com.vaadin.example.domain.repository.elastic.CustomerElasticRepository
import com.vaadin.example.domain.repository.jpa.CustomerJpaRepository
import com.vaadin.example.domain.util.getFormatValue
import org.springframework.boot.CommandLineRunner
import org.springframework.context.annotation.Bean
import org.springframework.stereotype.Component
import java.time.LocalDate
import java.util.*


@Component
class InitDataCustomer {

    @Bean
    fun initData(customerJpaRepository: CustomerJpaRepository, customerElasticRepository: CustomerElasticRepository): CommandLineRunner = CommandLineRunner {
        var isDataElasticNotExisted = true
        if(customerElasticRepository.count() > 0) {
            isDataElasticNotExisted = false
        }
        val names = listOf( "Gabrielle Patel", "Brian Robinson", "Eduardo Haugen",
                "Koen Johansen", "Alejandro Macdonald", "Angel Karlsson", "Yahir Gustavsson", "Haiden Svensson",
                "Emily Stewart", "Corinne Davis", "Ryann Davis", "Yurem Jackson", "Kelly Gustavsson",
                "Eileen Walker", "Katelyn Martin", "Israel Carlsson", "Quinn Hansson", "Makena Smith",
                "Danielle Watson", "Leland Harris", "Gunner Karlsen", "Jamar Olsson", "Lara Martin",
                "Ann Andersson", "Remington Andersson", "Rene Carlsson", "Elvis Olsen", "Solomon Olsen",
                "Jaydan Jackson", "Bernard Nilsen")

            val r = Random(0)
            names.map { it.split(" ") }.map{ createCustomer(it, r) }.forEach {
                        customerJpaRepository.save(it)
                        if(isDataElasticNotExisted) {
                            customerElasticRepository.save(it)
                        }
                    }
        }

    private fun createCustomer(split: List<String>, r: Random): com.vaadin.example.domain.entity.Customer = com.vaadin.example.domain.entity.Customer().apply {
        firstName = split[0]
        lastName = split[1]
        email = split[0].toLowerCase() + "@" + split[1].toLowerCase() + ".com"
        status = com.vaadin.example.domain.enums.CustomerStatus.values()[r.nextInt(com.vaadin.example.domain.enums.CustomerStatus.values().size)]
        birthDate = LocalDate.now().plusDays((0 - r.nextInt(365 * 15 + 365 * 60)).toLong())
        description = "$firstName $lastName $email $status ${birthDate.getFormatValue()}"
    }
}