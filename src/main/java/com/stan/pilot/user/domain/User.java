package com.stan.pilot.user.domain;

import com.azure.spring.data.cosmos.core.mapping.Container;
import com.azure.spring.data.cosmos.core.mapping.PartitionKey;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
@Container(containerName = "user-primary-data")
public class User {
    private String id;
    @PartitionKey
    private String tenantid;
    private String email;
    private String firstName;
    private String lastName;
}
