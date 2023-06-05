package com.stan.pilot.user.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.util.Streamable;
import org.springframework.stereotype.Component;

import com.azure.cosmos.models.PartitionKey;
import com.stan.pilot.user.domain.User;
import com.stan.pilot.user.repository.UserRepository;

@Component
public class UserService {

    @Autowired
    private UserRepository userRepository;
    
    public List<User> getUsers(String tenantId){
        var iterable = userRepository.findAll(new PartitionKey(tenantId));
        return Streamable.of(iterable).toList();
    }

    public Optional<User> findById(String id, String tenantId){
        return userRepository.findById(id, new PartitionKey(tenantId));
    }
}
