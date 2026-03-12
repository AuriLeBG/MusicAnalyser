package fr.musicanalyzer.api.dto;

public record FavoriteDto(
        Integer userId,
        Long songId,
        String title,
        Integer year,
        String language,
        String artistName
) {}
