package fr.musicanalyzer.api.controller;

import fr.musicanalyzer.api.dto.TopArtistDto;
import fr.musicanalyzer.api.dto.TopGenreDto;
import fr.musicanalyzer.api.dto.ViewsByYearDto;
import fr.musicanalyzer.api.service.AnalyticsService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/analytics")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    public AnalyticsController(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    @GetMapping("/views-by-year")
    public List<ViewsByYearDto> getViewsByYear() {
        return analyticsService.getViewsByYear();
    }

    @GetMapping("/top-artists")
    public List<TopArtistDto> getTopArtists(@RequestParam(defaultValue = "10") int limit) {
        return analyticsService.getTopArtists(limit);
    }

    @GetMapping("/top-genres")
    public List<TopGenreDto> getTopGenres() {
        return analyticsService.getTopGenres();
    }
}
