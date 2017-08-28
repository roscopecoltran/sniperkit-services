package com.vaadin.example.web.ui.util

import com.vaadin.example.web.constants.WebConstants
import com.vaadin.icons.VaadinIcons
import com.vaadin.spring.annotation.SpringComponent
import com.vaadin.spring.annotation.UIScope
import com.vaadin.ui.Button
import com.vaadin.ui.CssLayout
import com.vaadin.ui.themes.ValoTheme

@SpringComponent
@UIScope
class Paging : CssLayout(){
    private lateinit var clickListener: (page: Int) -> Unit
    private val pagingInfo = PagingInfo()
    private lateinit var firstBtn: Button
    private lateinit var prevBtn: Button
    private lateinit var nextBtn: Button
    private lateinit var lastBtn: Button
    private val buttonNumbers: MutableList<Button> = mutableListOf()

    fun build () {
        if(pagingInfo.totalPage < 0) {
            throw IllegalArgumentException("total page is less than 0")
        }

        removeAllComponents()
        initComponent()

        if (pagingInfo.totalPage == 0) {
            isVisible = false
            return
        }

        isVisible = true
        styleName = ValoTheme.LAYOUT_COMPONENT_GROUP

        createPrevButtons()
        addComponents(firstBtn, prevBtn)

        createNumberButtons()
        buttonNumbers.forEach{ addComponents(it) }

        createNextButtons()
        addComponents(nextBtn, lastBtn)

        disablePrevOrNextButtons()
        disableNumberButton()
    }

    private fun initComponent() {
        firstBtn = Button(VaadinIcons.ANGLE_DOUBLE_LEFT)
        prevBtn = Button(VaadinIcons.ANGLE_LEFT)
        nextBtn = Button(VaadinIcons.ANGLE_RIGHT)
        lastBtn = Button(VaadinIcons.ANGLE_DOUBLE_RIGHT)
    }

    fun setTotalElement(totalElement: Long): Paging {
        pagingInfo.totalPage =  Math.ceil(totalElement.toDouble() / WebConstants.MAX_PAGE_SIZE).toInt()
        return this
    }

    fun setPageIndex(pageIndex: Int): Paging {
        pagingInfo.pageIndex = pageIndex
        return this
    }

    fun addClickListener(event: (index: Int) -> Unit): Paging {
        this.clickListener = event
        return this
    }

    fun getPagingInfo() : PagingInfo {
        return pagingInfo
    }

    private fun disablePrevOrNextButtons() {
        if (isFirst()) {
            firstBtn.isEnabled = false
            prevBtn.isEnabled = false
        } else {
            firstBtn.isEnabled = true
            prevBtn.isEnabled = true
        }

        if (isLast()) {
            lastBtn.isEnabled = false
            nextBtn.isEnabled = false
        } else {
            lastBtn.isEnabled = true
            nextBtn.isEnabled = true
        }
    }

    private fun createPrevButtons() {
        firstBtn.addClickListener {
            clickListener(0)
            pagingInfo.pageIndex = 0
            build()
        }
        prevBtn.addClickListener {
            clickListener(pagingInfo.pageIndex--)
            build()
        }
    }

    private fun createNextButtons() {
        nextBtn.addClickListener {
            clickListener(pagingInfo.pageIndex++)
            build()
        }
        lastBtn.addClickListener {
            clickListener(pagingInfo.totalPage - 1)
            pagingInfo.pageIndex = pagingInfo.totalPage - 1
            build()
        }
    }

    private fun createNumberButtons() {
        buttonNumbers.clear()
        val info = pagingInfo.getBeginAndEnd()
        (info.first..info.second).forEach {
            buttonNumbers.add(createNumberButton(it))
        }
    }

    private fun createNumberButton(index: Int): Button {
        val button = Button((index + 1).toString())
        button.addClickListener {
            clickListener(index)
            pagingInfo.pageIndex = index
            build()
        }
        return button
    }

    private fun disableNumberButton() {
        buttonNumbers.filter{ it.caption == (pagingInfo.pageIndex + 1).toString() }.forEach{
            it.isEnabled = false
            it.styleName = ValoTheme.BUTTON_FRIENDLY
            it.addStyleName("disable-opacity")
        }
        buttonNumbers.filter{ it.caption != (pagingInfo.pageIndex + 1).toString() }.forEach{
            it.isEnabled = true
        }
    }

    private fun isFirst(): Boolean {
        return pagingInfo.pageIndex <= 0
    }

    private fun isLast(): Boolean {
        return pagingInfo.pageIndex >= pagingInfo.totalPage - 1
    }

    class PagingInfo {
        internal var totalPage: Int = 0
        internal var pageIndex:Int = 0
        internal val maxDisplayCount = 5

        internal fun getBeginAndEnd() : Pair<Int, Int> {
            var begin:Int = maxOf(0, this.pageIndex - maxDisplayCount / 2)
            var end:Int = begin + (this.maxDisplayCount - 1)

            if (end > totalPage - 1) {
                end = totalPage - 1
                begin = maxOf(0, end - (maxDisplayCount - 1))
            }

            return Pair(begin, end)
        }
    }
}