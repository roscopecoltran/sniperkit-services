package com.vaadin.example.domain.util

import com.vaadin.example.env.constants.SystemConstants
import java.time.LocalDate
import java.time.format.DateTimeFormatter

fun LocalDate.getFormatValue() : String {
   val formatter = DateTimeFormatter.ofPattern(SystemConstants.DATE_PATTERN_DEFAULT)
    return formatter.format(this)
}
