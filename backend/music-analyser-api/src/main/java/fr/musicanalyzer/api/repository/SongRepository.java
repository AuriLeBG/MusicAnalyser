package fr.musicanalyzer.api.repository;

import fr.musicanalyzer.api.model.SongEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SongRepository extends JpaRepository<SongEntity, Long> {

    Page<SongEntity> findByArtist_Id(Long artistId, Pageable pageable);
}
