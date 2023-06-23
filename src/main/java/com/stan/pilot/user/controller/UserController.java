package com.stan.pilot.user.controller;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.stan.pilot.user.domain.User;
import com.stan.pilot.user.service.UserService;

import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@Slf4j
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/users/{tenantId}")
    public Flux<User> getUsers(@PathVariable String tenantId) {
        log.info("requesting users for tenant:" + tenantId);
        return userService.getUsers(tenantId);
    }

    @GetMapping("/users/{tenantId}/{userId}")
    public Mono<User> getUserById(@PathVariable("tenantId") String tenantId, @PathVariable String userId) {
        log.info("requesting user by tenant:" + tenantId + " and id:" + userId);
        return userService.findById(userId, tenantId);
    }


}
