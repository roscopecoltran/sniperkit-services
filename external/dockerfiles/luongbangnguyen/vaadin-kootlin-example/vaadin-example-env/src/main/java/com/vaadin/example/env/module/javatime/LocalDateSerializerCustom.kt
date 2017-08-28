package com.vaadin.example.env.module.javatime

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.databind.JsonSerializer
import com.fasterxml.jackson.databind.SerializerProvider
import com.vaadin.example.env.constants.SystemConstants
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class LocalDateSerializerCustom : JsonSerializer<LocalDate>(){
    override fun serialize(localDate: LocalDate, generator: JsonGenerator, provider: SerializerProvider) {
        val formatter = DateTimeFormatter.ofPattern(SystemConstants.DATE_PATTERN_DEFAULT)
        generator.writeString(localDate.format(formatter))
    }
}