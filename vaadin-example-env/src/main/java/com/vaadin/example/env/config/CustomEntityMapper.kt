package com.vaadin.example.env.config

import com.fasterxml.jackson.databind.DeserializationFeature
import com.fasterxml.jackson.databind.ObjectMapper
import com.vaadin.example.env.module.javatime.CustomJavaTimeModule
import org.springframework.data.elasticsearch.core.EntityMapper
import org.springframework.data.elasticsearch.core.geo.CustomGeoModule
import java.io.IOException


class CustomEntityMapper : EntityMapper {
    private val objectMapper = ObjectMapper()
    init {
        objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
        objectMapper.configure(DeserializationFeature.ACCEPT_SINGLE_VALUE_AS_ARRAY, true)
        objectMapper.registerModule(CustomGeoModule())
        objectMapper.registerModule(CustomJavaTimeModule())
    }

    @Throws(IOException::class)
    override fun mapToString(obj: Any): String {
        return this.objectMapper.writeValueAsString(obj)
    }

    @Throws(IOException::class)
    override fun <T> mapToObject(source: String, clazz: Class<T>): T {
        return this.objectMapper.readValue(source, clazz)
    }
}