package com.vaadin.example.web.ui.util

import com.vaadin.spring.annotation.SpringComponent
import com.vaadin.spring.annotation.UIScope
import com.vaadin.ui.Label
import com.vaadin.ui.VerticalLayout

@SpringComponent
@UIScope
class ErrorMessage : VerticalLayout() {
    private final val label = Label()
    init {
        isVisible = false
        styleName = "msg-error-custom"
        this.addComponent(label)
        this.isSpacing = false
    }

    fun setMessage(message: String) {
        label.value = message
    }
}