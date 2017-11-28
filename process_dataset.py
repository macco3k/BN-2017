import pandas as pd
import numpy as np
import os
import requests

data_path = r'D:\OneDrive\Documenti\Radboud\2017\Bayesian Networks\Assignment 1\data'
data_file = os.path.join(data_path, 'data.csv')
out_file = os.path.join(data_path, 'train.csv')

major_companies = ["Walt Disney", "Warner", "20th Century Fox", "Universal Pictures", "Columbia Pictures", "Paramount Pictures"]

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

    df['us'] = [1 if 'US' in x else 0 for x in df['production_countries']]
    df['us_only'] = [1 if x == 'US' else 0 for x in df['production_countries']]
    # df['major'] = df['production_companies'].apply(lambda companies: 1 if set(companies.split('|') - set(major_companies)) == None)

    # I got upset because I tried many ways but could not get it the way I want
    # So the below is silly elementary code, but it works :)
    major_list = np.zeros((len(df)))
    for i in range(len(df)):
        count = 0
        for j in range(len(major_companies)):
            if major_companies[j] in df['production_companies'][i]:
                count = count + 1
        print(count)

        if count == 0:
            major_list[i] = 0
        else:
            major_list[i] = 1
    df['Major'] = major_list

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
