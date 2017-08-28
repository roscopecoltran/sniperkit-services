package com.vaadin.example.env.module.javatime

import com.fasterxml.jackson.core.Version
import com.fasterxml.jackson.databind.module.SimpleModule
import java.time.LocalDate

class CustomJavaTimeModule : SimpleModule("Java Time Elastic Search Custom", Version(1, 0, 0, "SNAPSHOT", "com.example.vaadin", "vaadin-project-example")){
    init {
        this.addDeserializer(LocalDate::class.java, LocalDateDeserializerCustom())
        this.addSerializer(LocalDate::class.java, LocalDateSerializerCustom())
    }
}