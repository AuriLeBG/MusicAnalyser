package fr.musicanalyzer.api.repository;

import fr.musicanalyzer.api.model.ArtistEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ArtistRepository extends JpaRepository<ArtistEntity, Long> {
    // Optional<ArtistEntity> findByName(String name);
}