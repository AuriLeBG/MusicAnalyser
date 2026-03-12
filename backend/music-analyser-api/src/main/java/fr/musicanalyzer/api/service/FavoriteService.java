package fr.musicanalyzer.api.service;

import fr.musicanalyzer.api.dto.FavoriteDto;
import fr.musicanalyzer.api.model.FavoriteEntity;
import fr.musicanalyzer.api.model.FavoriteId;
import fr.musicanalyzer.api.model.SongEntity;
import fr.musicanalyzer.api.model.User;
import fr.musicanalyzer.api.repository.FavoriteRepository;
import fr.musicanalyzer.api.repository.SongRepository;
import fr.musicanalyzer.api.repository.UserRepository;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class FavoriteService {

    private static final Logger log = LoggerFactory.getLogger(FavoriteService.class);

    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final SongRepository songRepository;

    public FavoriteService(FavoriteRepository favoriteRepository,
                           UserRepository userRepository,
                           SongRepository songRepository,
                           MeterRegistry meterRegistry) {
        this.favoriteRepository = favoriteRepository;
        this.userRepository = userRepository;
        this.songRepository = songRepository;
        Gauge.builder("favorites.total", favoriteRepository, FavoriteRepository::count)
                .description("Total number of favorites in database")
                .register(meterRegistry);
    }

    public List<FavoriteDto> getFavorites(Integer userId) {
        log.info("Fetching favorites for userId={}", userId);
        return favoriteRepository.findById_UserId(userId).stream()
                .map(this::toDto)
                .toList();
    }

    @Transactional
    public Optional<FavoriteDto> addFavorite(Integer userId, Long songId) {
        log.info("Adding favorite userId={} songId={}", userId, songId);
        Optional<User> user = userRepository.findById(userId);
        Optional<SongEntity> songOpt = songRepository.findById(songId);

        if (user.isEmpty() || songOpt.isEmpty()) {
            return Optional.empty();
        }

        FavoriteId favoriteId = new FavoriteId(userId, songId);
        if (favoriteRepository.existsById(favoriteId)) {
            return Optional.empty();
        }

        FavoriteEntity favorite = new FavoriteEntity();
        favorite.setId(favoriteId);
        favorite.setUser(user.get());
        favorite.setSong(songOpt.get());
        favoriteRepository.save(favorite);

        SongEntity song = songOpt.get();
        String artistName = song.getArtist() != null ? song.getArtist().getName() : null;
        return Optional.of(new FavoriteDto(userId, songId, song.getTitle(), song.getYear(), song.getLanguage(), artistName));
    }

    public boolean removeFavorite(Integer userId, Long songId) {
        log.info("Removing favorite userId={} songId={}", userId, songId);
        FavoriteId favoriteId = new FavoriteId(userId, songId);
        if (!favoriteRepository.existsById(favoriteId)) {
            return false;
        }
        favoriteRepository.deleteById(favoriteId);
        return true;
    }

    private FavoriteDto toDto(FavoriteEntity f) {
        SongEntity song = f.getSong();
        String artistName = (song != null && song.getArtist() != null) ? song.getArtist().getName() : null;
        String title = song != null ? song.getTitle() : null;
        Integer year = song != null ? song.getYear() : null;
        String language = song != null ? song.getLanguage() : null;
        return new FavoriteDto(f.getId().getUserId(), f.getId().getSongId(), title, year, language, artistName);
    }
}
