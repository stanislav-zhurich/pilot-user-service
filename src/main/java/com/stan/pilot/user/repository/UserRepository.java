package com.stan.pilot.user.repository;

import com.azure.spring.data.cosmos.repository.CosmosRepository;
import com.stan.pilot.user.domain.User;

public interface UserRepository extends CosmosRepository<User, String>{
    
}
