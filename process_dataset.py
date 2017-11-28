import pandas as pd
import numpy as np
import os
import requests

data_path = r'D:\OneDrive\Documenti\Radboud\2017\Bayesian Networks\Assignment 1\data'
data_file = os.path.join(data_path, 'data.csv')
out_file = os.path.join(data_path, 'train.csv')

major_companies = ["Walt Disney", "Warner", "20th Century Fox", "Universal Pictures", "Columbia Pictures", "Paramount Pictures"]
macro_genres = {'action': ['Action','Adventure', 'Fantasy', 'Science Fiction', 'War', 'Western', 'History'],
                'dark': ['Crime', 'Thriller', 'Horror', 'Mystery'],
                'light': ['Comedy', 'Family', 'Romance'],
                'other': ['Foreign', 'Documentary', 'Music'],
                'drama': ['Drama']}

def load_dataset(path):
    return pd.read_csv(path)

def process_dataset(df):
    # Keep only columns we need
    cols = {
        'title': 'str',
        'budget': 'int',
        'genres': 'str',
        'macro_genre': 'str',
        'original_language': 'str',
        #'popularity': 'float',
        'revenue': 'uint',
        'vote_average': 'float',
        'vote_count': 'int',
        'director_name': 'str',
        'actor_1_name': 'str',
        'actor_2_name': 'str',
        'actor_3_name': 'str',
        'cast_popularity': 'float',
        'us': 'int',
        'major': 'int'
    }

    # Aggregate all cast members' popularity together
    df['cast_popularity'] = df['director_popularity'] + df['cast_popularity']
    # Compute a binary column for US vs not-US productions
    df['us'] = [1 if 'US' in x else 0 for x in df['production_countries']]

    # Compute a binary column for major vs. non-major productions
    major_list = np.zeros((len(df)))
    genre_list = []

    uncovered_movies = 0
    for i in range(len(df)):
        count = 0
        for j in range(len(major_companies)):
            if major_companies[j] in df['production_companies'][i]:
                count = count + 1

        if count == 0:
            major_list[i] = 0
        else:
            major_list[i] = 1

        movie_genres = [len(set(df['genres'][i].split('|')).intersection(set(mg))) for mg in macro_genres.values()]
        macro_genre_index = movie_genres.index(max(movie_genres))
        genre_list.append(list(macro_genres.keys())[macro_genre_index])

    df['major'] = major_list
    df['macro_genre'] = genre_list

    # Only keep columns we're going to use for the network
    df = df[list(cols.keys())]
    df = df.astype(dtype=cols, copy=True)

    return df

def build_cptables(df):
    """
        major,
        genre,
        us|major,
        budget|major, genre, cast_popularity
        cast_popularity|genre
        movie_popularity|cast_popularity, genre, us, vote_avg_community, vote_avg_critics
        vote_count_community|movie_popularity
        vote_count_critics|movie_popularity
        revenue|popularity
    """
    major_groupby = df.groupby('major')
    major_us_groupby = major_groupby.groupby('us')
    p_major = major_groupby.size().apply(lambda x: x/sum(major_groupby.size()))
    p_us_major = [count/sum(group) for group in df.groupby(['major', 'us']).size() for count in group]
    return df


def update_metadata(df):
    r = requests('http://api.marcalencc.com/metacritic/movie/man-of-steel/details')
    if r.status_code != requests.codes.ok:
        r.raise_for_status()

    content = r.json()


def main():
    df = load_dataset(data_file)
    df = process_dataset(df)
    # df = build_cptables(df)

    df.to_csv(out_file, encoding='utf-8', index=False)


if __name__ == '__main__':
    main()
