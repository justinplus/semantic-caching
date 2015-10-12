#!/usr/bin/env octave 

%% load files
detail = load('baidu_res_detail.csv');
event_detail = load('baidu_res_event_detail.csv');
search = load('baidu_search.csv');
event_search = load('baidu_event_search.csv');

forcast_f = load('open_weather_forecast_f.csv');
forcast_v = load('open_weather_forecast_v.csv');
index_f = load('open_weather_index_f.csv');
index_v = load('open_weather_index_v.csv');

m_detail = mean( detail );
m_event_detail = mean( event_detail );
m_event_search = mean( event_search );
m_forcast_f = mean(forcast_f);
m_forcast_v = mean(forcast_v);
m_index_f = mean(index_f);
m_index_v = mean(index_v);

display( m_detail)
