package com.stan.pilot.user.repository;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import com.azure.spring.data.cosmos.repository.CosmosRepository;
import com.azure.spring.data.cosmos.repository.ReactiveCosmosRepository;
//import com.azure.spring.data.cosmos.repository.CosmosRepository;
import com.stan.pilot.user.domain.User;

@Repository
public interface UserRepository extends ReactiveCosmosRepository<User, String>{
    
}
