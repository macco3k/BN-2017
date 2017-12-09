import numpy
import pandas as pd
import os
import requests

import load_dataset

data_path = r'../data'

movies_file = os.path.join(data_path, 'tmdb_5000_movies.csv')
credits_file = os.path.join(data_path, 'tmdb_5000_credits.csv')
people_file = os.path.join(data_path, 'person_ids.json')

data_file = os.path.join(data_path, 'data.csv')
train_file = os.path.join(data_path, 'train.csv')

major_companies = ["Walt Disney", "Warner", "20th Century Fox", "Universal Pictures", "Columbia Pictures", "Paramount Pictures"]
macro_genres = {'action': ['Action','Adventure', 'Fantasy', 'Science Fiction', 'War', 'Western', 'History'],
                'dark': ['Crime', 'Thriller', 'Horror', 'Mystery'],
                'light': ['Comedy', 'Family', 'Romance'],
                'other': ['Foreign', 'Documentary', 'Music', 'Drama']}
                # 'drama': ['Drama']}

def process_dataset(df):
    # Keep only columns we need
    cols = {
        'title': 'str',
        'budget': 'int',
        'budget_binned': 'str',
        'genres': 'str',
        'macro_genre': 'str',
        'original_language': 'str',
        #'popularity': 'float',
        'revenue': 'uint',
        'vote_average': 'float',
        'vote_average_binned': 'str',
        'vote_count': 'int',
        'vote_count_binned': 'str',
        'director_name': 'str',
        'actor_1_name': 'str',
        'actor_2_name': 'str',
        'actor_3_name': 'str',
        'cast_popularity': 'float',
        'cast_popularity_binned': 'str',
        'us': 'str',
        'major': 'str',
        'revenue_binned': 'str',
    }

    # Aggregate all cast members' popularity together, normalize and bin
    df['cast_popularity'] = df['director_popularity'] + df['cast_popularity']
    df['cast_popularity_binned'] = pd.cut(df['cast_popularity'], bins=3, labels=['1st', '2nd', '3rd'])

    # Bin vote average
    df['vote_average_binned'] = pd.cut(df['vote_average'], bins=[0, 5, 7, 10], labels=['bad', 'ok', 'great'])

    # Bin budget and revenue
    df['budget_binned'] = pd.cut(df['budget'], bins=[0,10000000,50000000,400000000], labels=['low', 'avg', 'high'])
    df['vote_count_binned'] = pd.cut(df['vote_count'], bins=3, labels=['1st', '2nd', '3rd'])

    # Compute a binary column for US vs not-US productions
    df['us'] = ["yes" if 'US' in x else "no" for x in df['production_countries']]

    # bin revenue: low, avg, high
    df['revenue_binned'] = pd.cut(df['revenue'], bins=[0,10000000, 200000000,3000000000] , labels=['low', 'avg', 'high'])

    # bin vote_count: low, avg, high
    df['vote_count_binned'] = pd.cut(df['vote_count'],  bins=[0, 200, 1300, 14000], labels=['low', 'avg', 'high'])

    # Compute a binary column for major vs. non-major productions
    major_list = []
    genre_list = []

    for i in range(len(df)):
        count = 0
        for j in range(len(major_companies)):
            if major_companies[j] in df['production_companies'][i]:
                count = count + 1

        if count == 0:
            major_list.append("no")
        else:
            major_list.append("yes")

        # take the macro genre whose intersection with the genre column is largest as the macro genre
        movie_genres = [len(set(df['genres'][i].split('|')).intersection(set(mg))) for mg in macro_genres.values()]
        macro_genre_index = movie_genres.index(max(movie_genres))
        genre_list.append(list(macro_genres.keys())[macro_genre_index])

    df['major'] = major_list
    df['macro_genre'] = genre_list

    # Only keep columns we're going to use for the network
    df = df[list(cols.keys())]
    df = df.astype(dtype=cols, copy=True)

    return df


"""
    major,
    vote_avg,
    genre|major,
    us|major,
    cast_popularity|budget,
    budget|major,genre
    vote_count_community|movie_popularity
    vote_count_critics|movie_popularity
    revenue|movie_popularity

    this we don't have:
        movie_popularity|genre, us, cast_popularity, vote_avg_community, vote_avg_critics
"""
def compute_cptables(df):
    groups = [
        df.groupby('major'),
        df.groupby('vote_average_binned'),
        df.groupby(['major', 'macro_genre']),
        df.groupby(['major', 'us']),
        df.groupby(['budget_binned', 'cast_popularity_binned']),
        df.groupby(['major', 'macro_genre', 'budget_binned'])
    ]

    # we don't have this, we want to make inference about it
    #moviepop_groupby = df.groupby(['macro_genre', 'us', 'cast_popularity_category', 'vote_average_category'])

    # compute the cpt for each group.
    # Each row in the grouping is a combination for the conditioning vars, with the last column being conditioned.
    for g in groups:
        # Retrieve counts for each grouping
        group_count = g.size()
        names = group_count.index.names

        # see https://stackoverflow.com/questions/42854801/including-missing-combinations-of-values-in-a-pandas-groupby-aggregation
        # we need to unstack each and every level to account for 0-count subgroups
        # First unstack every subgroup and substitute missing values with 0, then put everything back.
        for lvl in range(1, len(names)):
            group_count = group_count.unstack(fill_value=0)

        for lvl in range(1, len(names)):
            group_count = group_count.stack()

        if(len(names) > 1):
            # group by all but the last column (the one we're conditioning on). Compute probabilities as the ratio
            # of the subgroup count/the total for the previous group
            levels = list(range(0, len(names)-1))
            conditional = group_count.groupby(level=levels).apply(lambda subg: subg/subg.sum())
    #         joint = group_count/len(df)
            filename = '%s-%s.csv' % (names[-1], ','.join(names[0:-1]))
        else:
            conditional = group_count/group_count.sum()
    #         joint = conditional
            filename = '%s.csv' % names[0]

        # Save cpt to csv files. One file per cpt
        conditional[numpy.isnan(conditional)] = 0
        conditional.to_csv(os.path.join(data_path, 'cpt', filename), header=True, encoding='utf-8')

def update_metadata(df):
    r = requests('http://api.marcalencc.com/metacritic/movie/man-of-steel/details')
    if r.status_code != requests.codes.ok:
        r.raise_for_status()

    content = r.json()


def main():
    # load raw data and save it to data.csv
    load_dataset.main(movies_file, credits_file, people_file, out_file=train_file)

    # process the data and save it to train.csv
    df = pd.read_csv(data_file)
    df = process_dataset(df)
    df.to_csv(train_file, encoding='utf-8', index=False)

    # compute cpt tables and save them to cpt/. One file per cpt
    compute_cptables(df)

    # print ('low revenue: ',(sum([1 if i == 'bad' else 0 for i in df['vote_count_binned']])))
    # print ('avg revenue: ', (sum([1 if i == 'ok' else 0 for i in df['vote_count_binned']])))
    # print( 'hgh revenue: ', (sum([1 if i == 'great' else 0 for i in df['vote_count_binned']])))


if __name__ == '__main__':
    main()
