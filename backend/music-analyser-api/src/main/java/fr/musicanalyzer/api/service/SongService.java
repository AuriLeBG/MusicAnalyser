package fr.musicanalyzer.api.service;

import fr.musicanalyzer.api.model.SongEntity;
import fr.musicanalyzer.api.repository.SongRepository;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Random;

@Service
public class SongService {

    private static final Logger log = LoggerFactory.getLogger(SongService.class);

    private final SongRepository songRepository;
    private final Counter songsSearchedCounter;
    private final Random random = new Random();

    public SongService(SongRepository songRepository, MeterRegistry meterRegistry) {
        this.songRepository = songRepository;
        this.songsSearchedCounter = Counter.builder("songs.searched")
                .description("Number of song search requests")
                .register(meterRegistry);
    }

    public Page<SongEntity> getSongs(int page, int size) {
        log.info("Fetching songs page={} size={}", page, size);
        songsSearchedCounter.increment();
        Pageable pageable = PageRequest.of(page, size);
        return songRepository.findAll(pageable);
    }

    public Page<SongEntity> getSongsByArtist(Long artistId, int page, int size) {
        log.info("Fetching songs for artistId={} page={} size={}", artistId, page, size);
        songsSearchedCounter.increment();
        Pageable pageable = PageRequest.of(page, size);
        return songRepository.findByArtist_Id(artistId, pageable);
    }

    public String randomFail() {
        log.info("random-fail endpoint called");
        if (random.nextBoolean()) {
            log.error("random-fail: simulated failure triggered");
            throw new RuntimeException("Simulated random failure");
        }
        log.info("random-fail: success");
        return "OK";
    }
}
