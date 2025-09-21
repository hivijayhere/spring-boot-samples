package com.dataarchival.config;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

@Configuration
public class DatabaseConfig {
    
    @Primary
    @Bean(name = "liveDataSource")
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource liveDataSource() {
        return DataSourceBuilder.create().build();
    }
    
    @Bean(name = "archivalDataSource")
    @ConfigurationProperties(prefix = "archival.datasource")
    public DataSource archivalDataSource() {
        return DataSourceBuilder.create().build();
    }
    
    @Primary
    @Bean(name = "liveJdbcTemplate")
    public JdbcTemplate liveJdbcTemplate(@Qualifier("liveDataSource") DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
    
    @Bean(name = "archivalJdbcTemplate")
    public JdbcTemplate archivalJdbcTemplate(@Qualifier("archivalDataSource") DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
}