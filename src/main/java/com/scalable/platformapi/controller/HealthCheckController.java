package com.scalable.platformapi.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.scalable.platformapi.repository.HealthCheckRepository;
import org.springframework.web.server.ResponseStatusException;

@CrossOrigin("*")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api")
public class HealthCheckController {

    private final HealthCheckRepository healthCheckRepository;

    @GetMapping("/health")
    public String health(){
        return healthCheckRepository.findById(1)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.SERVICE_UNAVAILABLE, "Health check record not found"))
                .getStatus();
    }

}
