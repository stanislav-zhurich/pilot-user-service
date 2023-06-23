package com.stan.pilot.user;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Import;
import com.azure.spring.data.cosmos.repository.config.EnableCosmosRepositories;

//import com.azure.spring.data.cosmos.repository.config.EnableCosmosRepositories;

@SpringBootApplication
//@Import(CosmosDBConfiguration.class)
public class PilotUserServiceApplication implements CommandLineRunner{


	public static void main(String[] args) {
		SpringApplication.run(PilotUserServiceApplication.class, args);
	} 

	@Override
    public void run(String... args) {
        //System.out.println("sampleProperty: " + secretClient.getSecret("user-service-sp-tenant").getValue());
    }
}
