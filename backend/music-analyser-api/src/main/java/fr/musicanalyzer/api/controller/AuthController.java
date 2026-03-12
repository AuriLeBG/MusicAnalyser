package fr.musicanalyzer.api.controller;

import fr.musicanalyzer.api.dto.AuthResponseDto;
import fr.musicanalyzer.api.model.User;
import fr.musicanalyzer.api.repository.UserRepository;
import fr.musicanalyzer.api.security.JwtUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthController(UserRepository userRepository,
                          PasswordEncoder passwordEncoder,
                          JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponseDto> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");

        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty() || !passwordEncoder.matches(password, userOpt.get().getPassword())) {
            return ResponseEntity.status(401).build();
        }

        User user = userOpt.get();
        String token = jwtUtil.generateToken(user.getUsername(), user.getId(), user.getRole());
        return ResponseEntity.ok(new AuthResponseDto(token, user.getId(), user.getUsername()));
    }
}
