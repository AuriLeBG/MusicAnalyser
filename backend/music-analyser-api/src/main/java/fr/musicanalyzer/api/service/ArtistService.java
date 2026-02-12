package fr.musicanalyzer.api.service;

import fr.musicanalyzer.api.model.ArtistEntity;
import fr.musicanalyzer.api.repository.ArtistRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ArtistService {

    private final ArtistRepository artistRepository;

    // Injection de dépendance par constructeur
    public ArtistService(ArtistRepository artistRepository) {
        this.artistRepository = artistRepository;
    }

    public List<ArtistEntity> getAllArtists() {
        return artistRepository.findAll();
    }

    // Méthode pour créer un artiste
    public ArtistEntity createArtist(String name) {
        ArtistEntity artist = new ArtistEntity();
        artist.setName(name);
        return artistRepository.save(artist);
    }
}