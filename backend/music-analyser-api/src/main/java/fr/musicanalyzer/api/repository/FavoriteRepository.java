package fr.musicanalyzer.api.repository;

import fr.musicanalyzer.api.model.FavoriteEntity;
import fr.musicanalyzer.api.model.FavoriteId;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FavoriteRepository extends JpaRepository<FavoriteEntity, FavoriteId> {

    @EntityGraph(attributePaths = {"song", "song.artist"})
    List<FavoriteEntity> findById_UserId(Integer userId);
}
