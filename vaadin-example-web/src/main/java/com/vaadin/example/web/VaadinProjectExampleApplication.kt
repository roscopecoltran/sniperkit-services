package com.vaadin.example.web

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.context.annotation.ComponentScan

@SpringBootApplication
@ComponentScan("com.vaadin.example")
class VaadinProjectExampleApplication

fun main(args: Array<String>) {
    SpringApplication.run(VaadinProjectExampleApplication::class.java, *args)
}
