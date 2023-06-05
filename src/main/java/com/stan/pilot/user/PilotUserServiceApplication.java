package com.stan.pilot.user;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.azure.spring.data.cosmos.repository.config.EnableCosmosRepositories;

@SpringBootApplication
@EnableCosmosRepositories
public class PilotUserServiceApplication {

	

	public static void main(String[] args) {
		SpringApplication.run(PilotUserServiceApplication.class, args);
	}

}
