package fr.musicanalyzer.api.service;

import fr.musicanalyzer.api.dto.TopArtistDto;
import fr.musicanalyzer.api.dto.TopGenreDto;
import fr.musicanalyzer.api.dto.ViewsByYearDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AnalyticsService {

    private static final Logger log = LoggerFactory.getLogger(AnalyticsService.class);

    private final JdbcTemplate clickhouseJdbcTemplate;

    public AnalyticsService(@Qualifier("clickhouseJdbcTemplate") JdbcTemplate clickhouseJdbcTemplate) {
        this.clickhouseJdbcTemplate = clickhouseJdbcTemplate;
    }

    public List<ViewsByYearDto> getViewsByYear() {
        log.info("Querying ClickHouse: views by year");
        String sql = "SELECT year, sum(views) AS totalViews " +
                     "FROM music_db.songs " +
                     "GROUP BY year " +
                     "ORDER BY year";
        return clickhouseJdbcTemplate.query(sql, (rs, rowNum) ->
                new ViewsByYearDto(rs.getInt("year"), rs.getLong("totalViews")));
    }

    public List<TopArtistDto> getTopArtists(int limit) {
        log.info("Querying ClickHouse: top {} artists by views", limit);
        String sql = "SELECT artist, sum(views) AS totalViews " +
                     "FROM music_db.songs " +
                     "GROUP BY artist " +
                     "ORDER BY totalViews DESC " +
                     "LIMIT ?";
        return clickhouseJdbcTemplate.query(sql, (rs, rowNum) ->
                new TopArtistDto(rs.getString("artist"), rs.getLong("totalViews")), limit);
    }

    public List<TopGenreDto> getTopGenres() {
        log.info("Querying ClickHouse: top genres by views");
        String sql = "SELECT tag AS genre, sum(views) AS totalViews " +
                     "FROM music_db.songs " +
                     "GROUP BY tag " +
                     "ORDER BY totalViews DESC";
        return clickhouseJdbcTemplate.query(sql, (rs, rowNum) ->
                new TopGenreDto(rs.getString("genre"), rs.getLong("totalViews")));
    }
}
