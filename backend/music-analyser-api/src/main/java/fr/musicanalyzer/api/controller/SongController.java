package fr.musicanalyzer.api.controller;

import fr.musicanalyzer.api.model.SongEntity;
import fr.musicanalyzer.api.service.SongService;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/songs")
public class SongController {

    private final SongService songService;

    public SongController(SongService songService) {
        this.songService = songService;
    }

    @GetMapping("/random-fail")
    public Map<String, String> randomFail() {
        String result = songService.randomFail();
        return Map.of("status", result);
    }

    @GetMapping("/random-fail-retry")
    public Map<String, String> randomFailRetry() {
        String result = songService.randomFailWithRetry();
        return Map.of("status", result);
    }

    @GetMapping
    public Page<SongEntity> getSongs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Long artistId) {

        if (artistId != null) {
            return songService.getSongsByArtist(artistId, page, size);
        }
        return songService.getSongs(page, size);
    }
}
