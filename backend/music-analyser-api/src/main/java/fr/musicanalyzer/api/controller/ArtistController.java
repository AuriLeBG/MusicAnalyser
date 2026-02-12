package fr.musicanalyzer.api.controller;

import fr.musicanalyzer.api.model.ArtistEntity;
import fr.musicanalyzer.api.service.ArtistService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/artists")
public class ArtistController {

    private final ArtistService artistService;

    public ArtistController(ArtistService artistService) {
        this.artistService = artistService;
    }

    @GetMapping
    public List<ArtistEntity> getAll() {
        return artistService.getAllArtists();
    }

    @PostMapping
    public ArtistEntity add(@RequestParam String name) {
        return artistService.createArtist(name);
    }
}