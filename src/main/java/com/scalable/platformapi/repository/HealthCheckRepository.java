package com.scalable.platformapi.repository;

import com.scalable.platformapi.model.HealthCheck;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HealthCheckRepository extends JpaRepository<HealthCheck, Integer> {

}
