package fr.musicanalyzer.api.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable) // Désactiver la protection CSRF
            .authorizeHttpRequests(auth -> auth // Autorisations
                .requestMatchers(
                        "/api/**",
                        "/docs",
                        "/swagger-ui/**",
                        "/v3/api-docs/**"
                        ).permitAll()
                    .anyRequest().authenticated() // Pour tout le reste, demander une authentification
            );

        return http.build();
    }
}