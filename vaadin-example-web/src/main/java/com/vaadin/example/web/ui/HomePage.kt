package com.vaadin.example.web.ui

import com.vaadin.annotations.Theme
import com.vaadin.annotations.Title
import com.vaadin.example.web.ui.customer.CustomerForm
import com.vaadin.example.web.ui.customer.CustomerList
import com.vaadin.server.VaadinRequest
import com.vaadin.shared.ui.MarginInfo
import com.vaadin.spring.annotation.SpringUI
import com.vaadin.ui.HorizontalLayout
import com.vaadin.ui.UI
import com.vaadin.ui.VerticalLayout
import com.vaadin.ui.Window
import org.springframework.beans.factory.annotation.Autowired

@SpringUI
@Title("Vaadin And Kotlin Example")
@Theme("customtheme")
class HomePage : UI() {

    @Autowired
    private lateinit var customerList: CustomerList

    @Autowired
    private lateinit var form: CustomerForm

    override fun init(request: VaadinRequest) {
        val verticalLayout = VerticalLayout()

        val window = Window("Add customer")
        window.center()
        window.isModal = true
        window.content = form.apply { margin = MarginInfo(true) }

        form.setAfterSaveCustomerEvent {
            customerList.updateList()
            window.close()
        }

        customerList.setAddCustomerEvent {
            form.setCustomer(com.vaadin.example.domain.entity.Customer())
            window.caption = "Add customer"
            addWindow(window)
        }
        customerList.setSelectCustomerEvent {
            form.setCustomer(it)
            window.caption = "Edit customer"
            addWindow(window)
        }

        val main = HorizontalLayout(customerList)
        main.setSizeFull()
        main.setExpandRatio(customerList, 1f)
        customerList.updateList()

        verticalLayout.addComponent(main)
        content = verticalLayout
    }

}