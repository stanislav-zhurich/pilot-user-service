package com.stan.pilot.user.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.util.Streamable;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import com.azure.cosmos.models.PartitionKey;
import com.stan.pilot.user.domain.User;
import com.stan.pilot.user.repository.UserRepository;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;
    
    public Flux<User> getUsers(String tenantId){
        return userRepository.findAll(new PartitionKey(tenantId));
    }

    public Mono<User> findById(String id, String tenantId){
        return userRepository.findById(id, new PartitionKey(tenantId));
    }
}
