package fr.musicanalyzer.api.service;

import fr.musicanalyzer.api.model.User;
import fr.musicanalyzer.api.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User registerUser(User user) {
        // On encode le mot de passe avant de l'envoyer à Postgres
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // On s'assure qu'un rôle par défaut est présent
        if (user.getRole() == null || user.getRole().isEmpty()) {
            user.setRole("USER");
        }

        return userRepository.save(user);
    }
}