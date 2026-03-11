package fr.musicanalyzer.api.controller;

import fr.musicanalyzer.api.model.ArtistEntity;
import fr.musicanalyzer.api.model.SongEntity;
import fr.musicanalyzer.api.service.ArtistService;
import fr.musicanalyzer.api.service.SongService;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/artists")
public class ArtistController {

    private final ArtistService artistService;
    private final SongService songService;

    public ArtistController(ArtistService artistService, SongService songService) {
        this.artistService = artistService;
        this.songService = songService;
    }

    @GetMapping
    public List<ArtistEntity> getAll(@RequestParam(required = false) String search) {
        if (search != null && !search.isBlank()) {
            return artistService.getArtistsBySearch(search);
        }
        return artistService.getAllArtists();
    }

    @GetMapping("/{id}/songs")
    public Page<SongEntity> getSongsByArtist(
            @PathVariable Long id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return songService.getSongsByArtist(id, page, size);
    }

    @PostMapping
    public ArtistEntity add(@RequestParam String name) {
        return artistService.createArtist(name);
    }
}