package fr.musicanalyzer.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "artists")
@Data
public class ArtistEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;
}