package com.vaadin.example.web.ui.customer

import com.vaadin.data.Binder
import com.vaadin.data.validator.EmailValidator
import com.vaadin.data.validator.StringLengthValidator
import com.vaadin.example.domain.exeption.BusinessException
import com.vaadin.example.domain.service.CustomerService
import com.vaadin.example.web.ui.util.ErrorMessage
import com.vaadin.server.Sizeable
import com.vaadin.spring.annotation.SpringComponent
import com.vaadin.spring.annotation.UIScope
import com.vaadin.ui.*
import com.vaadin.ui.themes.ValoTheme
import org.springframework.beans.BeanUtils
import org.springframework.beans.factory.annotation.Autowired


@SpringComponent
@UIScope
class CustomerForm @Autowired constructor(private val customerService: CustomerService, private val errorMessage: ErrorMessage) : VerticalLayout() {

    private final val form = FormLayout().apply { setSizeUndefined() }
    private final val firstName = TextField("First Name").apply {setWidth(400f, Sizeable.Unit.PIXELS)}
    private final val lastName = TextField("Last Name").apply { setWidth(400f, Sizeable.Unit.PIXELS) }
    private final val email = TextField("Email").apply { setWidth(400f, Sizeable.Unit.PIXELS) }
    private final val status = NativeSelect<com.vaadin.example.domain.enums.CustomerStatus>("Status")
    private final val birthDate = DateField("Birthday").apply { setWidth(400f, Sizeable.Unit.PIXELS) }
    private final val description = TextArea("Description").apply { setWidth(400f, Sizeable.Unit.PIXELS) }
    private final val save = Button("Save")
    private final val delete = Button("Delete")
    private final val binder = Binder<com.vaadin.example.domain.entity.Customer>(com.vaadin.example.domain.entity.Customer::class.java)

    private var customer: com.vaadin.example.domain.entity.Customer? = null
    private lateinit var afterSaveCustomerEvent: () -> Unit

    private fun delete() {
        customerService.delete(customer!!)
        afterSaveCustomerEvent()
    }

    private fun save() {
        try {
            if (binder.writeBeanIfValid(customer)) {
                customerService.save(customer!!)
                afterSaveCustomerEvent()
            }
        } catch (e: BusinessException) {
            errorMessage.setMessage(e.message!!)
            errorMessage.isVisible = true
        }

    }

    private infix fun com.vaadin.example.domain.entity.Customer.copy(source: com.vaadin.example.domain.entity.Customer) {
        BeanUtils.copyProperties(source, this)
    }

    fun setCustomer(value: com.vaadin.example.domain.entity.Customer) {
        val clone = com.vaadin.example.domain.entity.Customer()
        clone copy value

        this.customer = clone
        binder.bean = clone

        firstName.selectAll()
        delete.isVisible = clone.id != null
        errorMessage.isVisible = false
    }

    fun setAfterSaveCustomerEvent(event: () -> Unit) {
        this.afterSaveCustomerEvent = event
    }

    init {
        this.isSpacing = false
        val buttons = HorizontalLayout(save, delete)

        birthDate.dateFormat = "dd-MM-yyyy"
        status.setItems(com.vaadin.example.domain.enums.CustomerStatus.values().toList())

        save.styleName = ValoTheme.BUTTON_PRIMARY
        save.addClickListener({ this.save() })

        delete.addClickListener { this.delete() }

        form.addComponents(firstName, lastName, email, status, birthDate, description, buttons)
        form.styleName = "customer-form"

        this.addComponents(errorMessage,form)
        this.setValidateBinder()
    }

    fun setValidateBinder() : Unit = with(binder) {
        forField(firstName)
                .asRequired("Fist name is require")
                .withValidator(StringLengthValidator("Fist name must be between 2 and 20 character", 2, 20))
                .bind(com.vaadin.example.domain.entity.Customer::getFirstName, com.vaadin.example.domain.entity.Customer::setFirstName)

        forField(lastName)
                .asRequired("Last name is require")
                .withValidator(StringLengthValidator("Last name must be between 2 and 50 character", 2, 20))
                .bind(com.vaadin.example.domain.entity.Customer::getLastName, com.vaadin.example.domain.entity.Customer::setLastName)

        forField(email).asRequired("Email is require")
                .withValidator(EmailValidator("Email invalid"))
                .bind(com.vaadin.example.domain.entity.Customer::getEmail, com.vaadin.example.domain.entity.Customer::setEmail)

        forField(status).asRequired("Status is require")
                .bind(com.vaadin.example.domain.entity.Customer::getStatus, com.vaadin.example.domain.entity.Customer::setStatus)

        forField(birthDate).asRequired("Birthday is require")
                .bind(com.vaadin.example.domain.entity.Customer::getBirthDate, com.vaadin.example.domain.entity.Customer::setBirthDate)

        forField(description).bind(com.vaadin.example.domain.entity.Customer::getDescription, com.vaadin.example.domain.entity.Customer::setDescription)
    }
}
