package com.vaadin.example.domain.criteria

import java.time.LocalDate

data class CustomerCriteria
(
        val filterString: String = "",
        var birthdayBegin: LocalDate?,
        var birthdayEnd: LocalDate?,
        val status: com.vaadin.example.domain.enums.CustomerStatus?
)