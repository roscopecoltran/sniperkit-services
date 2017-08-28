package com.vaadin.example.web.ui.customer

import com.vaadin.data.provider.GridSortOrder
import com.vaadin.example.domain.criteria.CustomerCriteria
import com.vaadin.example.domain.entity.Customer_
import com.vaadin.example.domain.service.CustomerService
import com.vaadin.example.web.constants.WebConstants
import com.vaadin.example.web.ui.util.Paging
import com.vaadin.icons.VaadinIcons
import com.vaadin.shared.data.sort.SortDirection
import com.vaadin.shared.ui.ValueChangeMode
import com.vaadin.spring.annotation.SpringComponent
import com.vaadin.spring.annotation.UIScope
import com.vaadin.ui.*
import com.vaadin.ui.renderers.LocalDateRenderer
import com.vaadin.ui.themes.ValoTheme
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort

@SpringComponent
@UIScope
class CustomerList
@Autowired
constructor(private val service: CustomerService,
            private val paging: Paging) : VerticalLayout(){

    private val filterText = TextField()

    private val dateBeginBirthday = DateField()

    private val dateEndBirthday = DateField()

    private val customerStatus = ComboBox<com.vaadin.example.domain.enums.CustomerStatus>()

    private lateinit var addUserEvent : () -> Unit

    private lateinit var selectCustomerEvent: (customer: com.vaadin.example.domain.entity.Customer) -> Unit

    private final val grid = Grid<com.vaadin.example.domain.entity.Customer>()

    private final val FIRST_NAME_LABEL = "First Name"
    private final val LAST_NAME_LABEL = "Last Name"
    private final val EMAIL_LABEL = "Email"
    private final val BIRTHDAY_LABEL = "Birthday"
    private final val STATUS_LABEL = "Status"
    private final val DESCRIPTION_LABEL = "Description"

    init {
        grid.setSizeFull()
        grid.addColumn(com.vaadin.example.domain.entity.Customer::getFirstName).caption = FIRST_NAME_LABEL
        grid.addColumn(com.vaadin.example.domain.entity.Customer::getLastName).caption = LAST_NAME_LABEL
        grid.addColumn(com.vaadin.example.domain.entity.Customer::getEmail).caption = EMAIL_LABEL
        grid.addColumn(com.vaadin.example.domain.entity.Customer::getBirthDate, LocalDateRenderer("dd-MM-yyyy")).caption = BIRTHDAY_LABEL
        grid.addColumn(com.vaadin.example.domain.entity.Customer::getStatus).caption = STATUS_LABEL
        grid.addColumn(com.vaadin.example.domain.entity.Customer::getDescription).apply { isSortable = false }.caption = DESCRIPTION_LABEL

        grid.asSingleSelect().addValueChangeListener {
            if(it.value != null) {
                selectCustomerEvent(it.value)
            }
        }

        grid.addSortListener {
            renderListByPageIndex(paging.getPagingInfo().pageIndex)
        }

        this.addComponents(createToolbar(), grid, paging)
    }

    private final fun createToolbar(): HorizontalLayout {
        with(filterText){
            placeholder = "Search"
            valueChangeMode = ValueChangeMode.LAZY
            addValueChangeListener { updateList() }
        }

        val clearFilterTextBtn = Button(VaadinIcons.CLOSE)
        with(clearFilterTextBtn){
            description = "Clear the current filter"
            addClickListener { filterText.clear() }
        }

        val filtering = CssLayout()
        with(filtering) {
            addComponents(filterText, clearFilterTextBtn)
            styleName = ValoTheme.LAYOUT_COMPONENT_GROUP
        }

        val addCustomerBtn = Button("Add new customer")
        addCustomerBtn.addClickListener {
            addUserEvent()
        }

        dateBeginBirthday.addValueChangeListener{ updateList() }
        dateEndBirthday.addValueChangeListener { updateList() }

        with(customerStatus) {
            setItems((com.vaadin.example.domain.enums.CustomerStatus.values()).toList())
            addSelectionListener { updateList() }
        }

        return HorizontalLayout(filtering, dateBeginBirthday, dateEndBirthday,customerStatus, addCustomerBtn)
    }

    fun updateList() {
        val customerCriteria = CustomerCriteria(filterText.value, dateBeginBirthday.value, dateEndBirthday.value, customerStatus.value)
        val pageable = getPageable(paging.getPagingInfo().pageIndex)
        var page = service.findAll(customerCriteria, pageable)
        if(page.content.isEmpty() && page.totalElements > 0) {
            page = service.findAll(customerCriteria, getPageable(0))
        }
        grid.setItems(page.content)
        updatePaging(page)
    }

    fun setAddCustomerEvent(event: () -> Unit) {
        addUserEvent = event
    }

    fun setSelectCustomerEvent(event: (customer: com.vaadin.example.domain.entity.Customer) -> Unit) {
        selectCustomerEvent = event
    }

    private fun updatePaging(page: Page<com.vaadin.example.domain.entity.Customer>) {
        paging.setTotalElement(page.totalElements)
        paging.setPageIndex(page.number)
        paging.addClickListener {
            renderListByPageIndex(it)
        }
        paging.build()
    }

    private fun renderListByPageIndex(pageIndex: Int) {
        val customerCriteria = CustomerCriteria(filterText.value, dateBeginBirthday.value, dateEndBirthday.value, customerStatus.value)
        val p = service.findAll(customerCriteria, getPageable(pageIndex))
        grid.setItems(p.content)
    }

    private fun getPageable(pageIndex: Int): Pageable {
        val orders = grid.getOrderList()
        var pageable = PageRequest.of(pageIndex, WebConstants.MAX_PAGE_SIZE, Sort.Direction.DESC, "id")
        if (orders.isNotEmpty()) {
            pageable = PageRequest.of(pageIndex, WebConstants.MAX_PAGE_SIZE, Sort.by(orders))
        }
        return pageable
    }

    fun Grid<com.vaadin.example.domain.entity.Customer>.getOrderList() : MutableList<Sort.Order> {
        val orders: MutableList<Sort.Order> = mutableListOf()
        this.sortOrder.mapTo(orders) { it.getSortOrder() }
        return orders
    }

    private fun GridSortOrder<com.vaadin.example.domain.entity.Customer>.getSortOrder() : Sort.Order {
        val fieldName = when (this.sorted.caption) {
            FIRST_NAME_LABEL -> Customer_.firstName.name
            LAST_NAME_LABEL ->  Customer_.lastName.name
            EMAIL_LABEL -> Customer_.email.name
            BIRTHDAY_LABEL -> Customer_.birthDate.name
            STATUS_LABEL -> Customer_.status.name
            else -> throw IllegalArgumentException("caption ${this.sorted.caption} is not existed on grid")
        }
        val direction = if (this.direction == SortDirection.DESCENDING) Sort.Direction.DESC  else Sort.Direction.ASC
        return Sort.Order(direction, fieldName)
    }
}

