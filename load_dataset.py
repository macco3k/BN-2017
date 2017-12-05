import pandas as pd
import json
import os
import numpy as np

data_path = r'./'
movies_file = os.path.join(data_path, 'tmdb_5000_movies.csv')
credits_file = os.path.join(data_path, 'tmdb_5000_credits.csv')
people_file = os.path.join(data_path, 'person_ids.json')

def load_tmdb_movies(path):
    df = pd.read_csv(path)
    df['release_date'] = pd.to_datetime(df['release_date']).apply(lambda x: x.date())
    json_columns = ['genres', 'keywords', 'production_countries', 'production_companies', 'spoken_languages']
    for column in json_columns:
        df[column] = df[column].apply(json.loads)
    return df


def load_tmdb_credits(path):
    df = pd.read_csv(path)
    json_columns = ['cast', 'crew']
    for column in json_columns:
        df[column] = df[column].apply(json.loads)
    return df


def safe_access(container, index_values):
    # return a missing value rather than an error upon indexing/key failure
    result = container
    try:
        for idx in index_values:
            result = result[idx]
        return result
    except IndexError or KeyError:
        return pd.np.nan


def get_director(crew_data):
    directors = [x['name'] for x in crew_data if x['job'] == 'Director']
    return safe_access(directors, [0])

def get_director_popularity(crew_data, popularity):
    director_id = safe_access([x['id'] for x in crew_data if x['job'] == 'Director'], [0])
    try:
        return popularity[director_id]
    except KeyError:
        return 0


def get_cast_popularity(cast_data, popularity):
    cast_ids = [x['id'] for x in cast_data]
    cast_popularity = sum([popularity[id] for id in cast_ids if id in popularity.keys()])
    return cast_popularity


def pipe_flatten_names(keywords):
    return '|'.join([x['name'] for x in keywords])


def convert_dataset(movies, credits, people):
    # Converts TMDb data to make it as compatible as possible with kernels built on the original version of the data.
    tmdb_movies = movies.copy()

    tmdb_movies['production_countries'] = tmdb_movies['production_countries'].apply(lambda jsn: '|'.join([x['iso_3166_1'] for x in jsn]))
    tmdb_movies['production_companies'] = tmdb_movies['production_companies'].apply(pipe_flatten_names)
    tmdb_movies['language'] = tmdb_movies['spoken_languages'].apply(lambda x: safe_access(x, [0, 'name']))
    tmdb_movies['director_name'] = credits['crew'].apply(get_director)
    tmdb_movies['director_popularity'] = credits['crew'].apply(lambda x: get_director_popularity(x, people))
    tmdb_movies['actor_1_name'] = credits['cast'].apply(lambda x: safe_access(x, [0, 'name']))
    tmdb_movies['actor_2_name'] = credits['cast'].apply(lambda x: safe_access(x, [1, 'name']))
    tmdb_movies['actor_3_name'] = credits['cast'].apply(lambda x: safe_access(x, [2, 'name']))
    tmdb_movies['cast_popularity'] = credits['cast'].apply(lambda x: get_cast_popularity(x, people))
    tmdb_movies['genres'] = tmdb_movies['genres'].apply(pipe_flatten_names)
    tmdb_movies['keywords'] = tmdb_movies['keywords'].apply(pipe_flatten_names)

    return tmdb_movies

def filter_dataset(df):
    df.production_companies.replace('', np.nan, inplace=True)
    df.production_countries.replace('', np.nan, inplace=True)
    df.dropna(subset=['production_companies', 'production_countries'], inplace=True)

    return df[(df.budget > 0) & (df.revenue > 0)]


movies = load_tmdb_movies(movies_file)
credits = load_tmdb_credits(credits_file)

# Load actors popularity from the persons_id file
people = [json.loads(l) for l in open(people_file, mode='r', encoding='utf-8')]
popularity = {p['id']: p['popularity'] for p in people}

converted_df = convert_dataset(movies, credits, popularity)
filtered_df = filter_dataset(converted_df)
filtered_df.to_csv(os.path.join(data_path, 'data.csv'), index=False, encoding='utf-8')