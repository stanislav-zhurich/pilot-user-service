package com.stan.pilot.user.domain;

import org.springframework.data.annotation.Id;

import com.azure.spring.data.cosmos.core.mapping.Container;
import com.azure.spring.data.cosmos.core.mapping.GeneratedValue;
import com.azure.spring.data.cosmos.core.mapping.PartitionKey;

//import com.azure.spring.data.cosmos.core.mapping.Container;
//import com.azure.spring.data.cosmos.core.mapping.PartitionKey;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Container(containerName = "user-primary-data")
public class User {
    @Id
    @GeneratedValue
    private String id;
    @PartitionKey
    private String tenantId;
    private String email;
    private String firstName;
    private String lastName;
}
