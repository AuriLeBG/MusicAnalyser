package fr.musicanalyzer.api.service;

import fr.musicanalyzer.api.model.SongEntity;
import fr.musicanalyzer.api.repository.SongRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
public class SongService {

    private static final Logger log = LoggerFactory.getLogger(SongService.class);

    private final SongRepository songRepository;

    public SongService(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    public Page<SongEntity> getSongs(int page, int size) {
        log.info("Fetching songs page={} size={}", page, size);
        Pageable pageable = PageRequest.of(page, size);
        return songRepository.findAll(pageable);
    }

    public Page<SongEntity> getSongsByArtist(Long artistId, int page, int size) {
        log.info("Fetching songs for artistId={} page={} size={}", artistId, page, size);
        Pageable pageable = PageRequest.of(page, size);
        return songRepository.findByArtist_Id(artistId, pageable);
    }
}
