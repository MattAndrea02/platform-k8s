package com.scalable.platformapi;

import com.scalable.platformapi.model.HealthCheck;
import com.scalable.platformapi.repository.HealthCheckRepository;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest
class HealthCheckControllerTests {

    @Autowired
    private MockMvc mvc;

    @MockitoBean
    private HealthCheckRepository repository;

    @Test
    void healthEndpointIsDiscoveredAndReturnsStoredStatus() throws Exception {
        HealthCheck health = new HealthCheck();
        health.setId(1);
        health.setStatus("UP");
        given(repository.findById(1)).willReturn(Optional.of(health));

        mvc.perform(get("/api/health"))
                .andExpect(status().isOk())
                .andExpect(content().string("UP"));
    }

    @Test
    void missingHealthRecordReturnsServiceUnavailable() throws Exception {
        given(repository.findById(1)).willReturn(Optional.empty());

        mvc.perform(get("/api/health"))
                .andExpect(status().isServiceUnavailable());
    }
}
