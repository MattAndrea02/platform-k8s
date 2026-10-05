package com.scalable.platformapi.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "healthcheck")
public class HealthCheck {

    @Id
    private Integer id;

    private String status;

}
