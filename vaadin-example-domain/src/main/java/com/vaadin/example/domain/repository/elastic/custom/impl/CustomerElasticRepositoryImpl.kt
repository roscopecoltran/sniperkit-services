package com.vaadin.example.domain.repository.elastic.custom.impl

import com.vaadin.example.domain.criteria.CustomerCriteria
import com.vaadin.example.domain.entity.Customer
import com.vaadin.example.domain.entity.Customer_
import com.vaadin.example.domain.repository.elastic.custom.CustomerElasticRepositoryCustom
import com.vaadin.example.domain.util.getFormatValue
import org.elasticsearch.common.unit.Fuzziness
import org.elasticsearch.index.query.QueryBuilders.*
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.elasticsearch.core.ElasticsearchTemplate
import org.springframework.data.elasticsearch.core.query.NativeSearchQueryBuilder

class CustomerElasticRepositoryImpl
@Autowired constructor(private val elasticsearchTemplate: ElasticsearchTemplate) : CustomerElasticRepositoryCustom<Customer> {

    override fun findAllCustomer(customerCriteria: CustomerCriteria, pageable: Pageable): Page<Customer> {
        val builder = NativeSearchQueryBuilder()
        val boolQuery = boolQuery()

        if (customerCriteria.filterString.isNotEmpty()) {
            boolQuery.must(matchQuery(Customer_.description.name, customerCriteria.filterString)
                    .fuzziness(Fuzziness.ONE).prefixLength(3))
        }

        customerCriteria.birthdayBegin?.apply { boolQuery.filter(rangeQuery(Customer_.birthDate.name).gte(this.getFormatValue())) }
        customerCriteria.birthdayEnd?.apply { boolQuery.filter(rangeQuery(Customer_.birthDate.name).lte(this.getFormatValue())) }
        customerCriteria.status?.apply { boolQuery.filter(matchQuery(Customer_.status.name, customerCriteria.status.name)) }

        builder.withQuery(boolQuery)
        builder.withPageable(pageable)
        return this.elasticsearchTemplate.queryForPage(builder.build(), Customer::class.java)
    }
}