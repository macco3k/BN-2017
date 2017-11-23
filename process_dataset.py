import pandas as pd
import numpy as np
import os
import requests

data_path = r'D:\OneDrive\Documenti\Radboud\2017\Bayesian Networks\Assignment 1\data'
data_file = os.path.join(data_path, 'data.csv')
out_file = os.path.join(data_path, 'train.csv')

def load_dataset(path):
    return pd.read_csv(path)


def process_dataset(df):
    # Keep only columns we need
    cols = {
        'title': 'str',
        'budget': 'int',
        'genres': 'str',
        'production_countries': 'str',
        'production_companies': 'str',
        'original_language': 'str',
        'popularity': 'float',
        'revenue': 'int',
        'vote_average': 'float',
        'vote_count': 'int',
        'director_name': 'str',
        'actor_1_name': 'str',
        'actor_2_name': 'str',
        'actor_3_name': 'str',
        'cast_popularity': 'float'
    }

    df = df[list(cols.keys())]
    df = df.astype(dtype=cols, copy=True)

    return df


def update_metadata(df):
    r = requests('http://api.marcalencc.com/metacritic/movie/man-of-steel/details')
    if r.status_code != requests.codes.ok:
        r.raise_for_status()

    content = r.json()


def main():
    df = load_dataset(data_file)
    df = process_dataset(df)

    df.to_csv(out_file, encoding='utf-8', index=False)

if __name__ == '__main__':
    main()
