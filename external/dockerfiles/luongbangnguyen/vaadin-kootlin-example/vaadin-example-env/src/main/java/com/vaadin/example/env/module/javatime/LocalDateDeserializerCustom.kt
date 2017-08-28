package com.vaadin.example.env.module.javatime

import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.JsonDeserializer
import com.vaadin.example.env.constants.SystemConstants
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class LocalDateDeserializerCustom : JsonDeserializer<LocalDate>(){

    override fun deserialize(parser: JsonParser, context: DeserializationContext): LocalDate? {
        val formatter = DateTimeFormatter.ofPattern(SystemConstants.DATE_PATTERN_DEFAULT)
        return LocalDate.parse(parser.valueAsString, formatter)
    }
}