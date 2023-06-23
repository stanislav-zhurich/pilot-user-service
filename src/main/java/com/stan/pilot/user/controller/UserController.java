package com.stan.pilot.user.controller;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.stan.pilot.user.domain.User;
import com.stan.pilot.user.service.UserService;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/users/{tenantId}")
    public Flux<User> getUsers(@PathVariable String tenantId) {
        return userService.getUsers(tenantId);
    }

    @GetMapping("/users/{tenantId}/{userId}")
    public Mono<User> getUserById(@PathVariable("tenantId") String tenantId, @PathVariable String userId) {
        return userService.findById(userId, tenantId);
    }


}
