package fr.musicanalyzer.api.controller;

import fr.musicanalyzer.api.dto.FavoriteDto;
import fr.musicanalyzer.api.service.FavoriteService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/favorites")
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @GetMapping
    public List<FavoriteDto> getFavorites(@RequestParam Integer userId) {
        return favoriteService.getFavorites(userId);
    }

    @PostMapping
    public ResponseEntity<FavoriteDto> addFavorite(@RequestBody Map<String, Long> body) {
        Integer userId = body.get("userId").intValue();
        Long songId = body.get("songId");
        Optional<FavoriteDto> result = favoriteService.addFavorite(userId, songId);
        return result
                .map(f -> ResponseEntity.status(HttpStatus.CREATED).body(f))
                .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    @DeleteMapping
    public ResponseEntity<Void> removeFavorite(@RequestParam Integer userId, @RequestParam Long songId) {
        boolean deleted = favoriteService.removeFavorite(userId, songId);
        return deleted
                ? ResponseEntity.noContent().build()
                : ResponseEntity.notFound().build();
    }
}
