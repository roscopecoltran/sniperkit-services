package com.vaadin.example.domain.entity;

import com.vaadin.example.domain.enums.CustomerStatus;
import com.vaadin.example.env.constants.SystemConstants;
import org.springframework.data.elasticsearch.annotations.*;

import javax.persistence.*;
import java.time.LocalDate;

@Entity
@Table
@Document(indexName = "customer", type = "customer")
@Setting(settingPath = "elasticsearch/setting/autocomplete-analyser.json")
public class Customer {

    @Id
    @org.springframework.data.annotation.Id
    @GeneratedValue
    private Long id;


    @Field(type = FieldType.text, analyzer = "autocomplete", searchAnalyzer = "standard", fielddata = true)
    private String firstName;

    @Field(type = FieldType.text, analyzer = "autocomplete", searchAnalyzer = "standard", fielddata = true)
    private String lastName;

    @Field(type = FieldType.Date, format = DateFormat.custom, pattern = SystemConstants.DATE_PATTERN_DEFAULT)
    private LocalDate birthDate;

    @Field(type = FieldType.text, analyzer = "autocomplete", searchAnalyzer = "standard")
    private String description;

    @Enumerated(EnumType.STRING)
    @Field(type = FieldType.text, fielddata = true)
    private CustomerStatus status;

    @Field(type = FieldType.text, fielddata = true)
    private String email;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public LocalDate getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
    }

    public CustomerStatus getStatus() {
        return status;
    }

    public void setStatus(CustomerStatus status) {
        this.status = status;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
