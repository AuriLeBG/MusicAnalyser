package fr.musicanalyzer.api.dto;

public record AuthResponseDto(String token, Integer userId, String username) {}
