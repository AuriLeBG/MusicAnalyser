package fr.musicanalyzer.api.service;

import fr.musicanalyzer.api.dto.AuthResponseDto;
import fr.musicanalyzer.api.model.User;
import fr.musicanalyzer.api.repository.UserRepository;
import fr.musicanalyzer.api.security.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    public Optional<AuthResponseDto> login(String username, String password) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty() || !passwordEncoder.matches(password, userOpt.get().getPassword())) {
            log.warn("Authentication failed for username: {}", username);
            return Optional.empty();
        }
        User user = userOpt.get();
        String token = jwtUtil.generateToken(user.getUsername(), user.getId(), user.getRole());
        return Optional.of(new AuthResponseDto(token, user.getId(), user.getUsername()));
    }
}
