package com.vaadin.example.domain.exeption

class BusinessException : RuntimeException{
    constructor(message: String, ex: Exception?): super(message, ex)
    constructor(message: String): super(message)
    constructor(ex: Exception): super(ex)
}