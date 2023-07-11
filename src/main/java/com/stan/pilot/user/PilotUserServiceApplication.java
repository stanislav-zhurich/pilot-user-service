package com.stan.pilot.user;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import lombok.extern.slf4j.Slf4j;

@SpringBootApplication
@Slf4j
public class PilotUserServiceApplication{


	public static void main(String[] args) {
		log.info("Hi");
		String id = System.getenv("service_sp_id");
		log.info("id:" + id);
		String secret = System.getenv("service_sp_pswd");
		log.info("secret:" + secret);
		String tenant = System.getenv("service_sp_tenant_id");
		log.info("tenant:" + tenant);
		String mi = System.getenv("AZURE_CLIENT_ID");
		log.info("mi:" + mi);
		SpringApplication.run(PilotUserServiceApplication.class, args);
	} 
}
