package com.stan.pilot.user.controller;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.stan.pilot.user.domain.User;

@RestController
public class UserController {

    private static Map<String, User> users = new HashMap<>();
    {
        users.put("1", new User("1", "stan@gmail.com"));
    }

    @GetMapping("/users")
    public Collection<User> getUser() {
        return users.values();
    }
}
