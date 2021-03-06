import numpy
import pandas as pd
import os
import re
import requests
import unidecode

import load_dataset

data_path = r'./data'

movies_file = os.path.join(data_path, 'tmdb_5000_movies.csv')
credits_file = os.path.join(data_path, 'tmdb_5000_credits.csv')
people_file = os.path.join(data_path, 'person_ids.json')

data_file = os.path.join(data_path, 'data.csv')
train_file = os.path.join(data_path, 'train.csv')

major_companies = ["Walt Disney", "Warner", "20th Century Fox", "Universal Pictures", "Columbia Pictures", "Paramount Pictures"]
macro_genres = {'action': ['Action', 'Adventure', 'Fantasy', 'Science Fiction', 'War', 'Western', 'History'],
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
        'popularity': 'float',
        'revenue': 'uint',
        'revenue_binned': 'str',
        'vote_average': 'float',
        'vote_average_binned': 'str',
        'vote_count': 'uint',
        'vote_count_binned': 'str',
        'critics_vote': 'float',
        'critics_vote_binned': 'str',
        'critics_count': 'uint',
        'critics_count_binned': 'str',
        'director_name': 'str',
        'actor_1_name': 'str',
        'actor_2_name': 'str',
        'actor_3_name': 'str',
        'cast_popularity': 'float',
        'cast_popularity_binned': 'str',
        'us': 'str',
        'major': 'str',
        'roi': 'float',
        'roi_binned': 'str',
        'popularity_binned': 'str',
    }

    # Standard quantiles fro low/average/high
    lah = [0, .25, .75, 1]
    lah_lbls = ['low', 'avg', 'high']

    # Aggregate all cast members' popularity together and bin
    df['cast_popularity'] = df['director_popularity'] + df['cast_popularity']
    # df['cast_popularity_binned'] = pd.cut(df['cast_popularity'], bins=[0, 15, 35, 200], labels=['low', 'avg', 'high'])
    df['cast_popularity_binned'] = pd.qcut(df['cast_popularity'], q=lah, labels=lah_lbls)

    # Replace 0 votes critics with the avg
    zero_critics = df[df['critics_count'] == 0]
    df.loc[zero_critics.index, 'critics_vote'] = df.loc[~df.index.isin(zero_critics.index), 'critics_vote'].mean()
    df.loc[zero_critics.index, 'critics_count'] = df.loc[~df.index.isin(zero_critics.index), 'critics_count'].mean()

    # Bin vote average for both community and critics
    df['vote_average_binned'] = pd.cut(df['vote_average'], bins=[0, 5, 7, 10], labels=['bad', 'ok', 'great'])
    df['critics_vote_binned'] = pd.cut(df['critics_vote'], bins=[0, 5, 7, 10], labels=['bad', 'ok', 'great'])
    df['vote_count_binned'] = pd.qcut(df['vote_count'], q=lah, labels=lah_lbls)
    df['critics_count_binned'] = pd.qcut(df['critics_count'], q=lah, labels=lah_lbls)

    # Just 'make it normal'
    df['budget_binned'] = pd.qcut(df['budget'], q=lah, labels=lah_lbls)
    df['revenue_binned'] = pd.qcut(df['revenue'], q=lah, labels=lah_lbls)
    df['popularity_binned'] = pd.qcut(df['popularity'], q=lah, labels=lah_lbls)

    # Use ROI as a measure of profitability.
    df['roi'] = (df['revenue'] - df['budget']) / df['budget']

    # ROIs of up to 0 are flop (no net gain).
    # For those movies with a ROI > 0, bin them according to the standard 25-50-25 bins.
    df['roi_binned'] = ''
    neg = df[df['roi'] <= 0].index
    pos = df[df['roi'] > 0].index
    df.loc[neg, 'roi_binned'] = 'flop'
    df.loc[pos, 'roi_binned'] = pd.qcut(df.loc[pos, 'roi'], q=lah, labels=lah_lbls)

    # Compute a binary column for US vs not-US productions
    df['us'] = ["yes" if 'US' in x else "no" for x in df['production_countries']]

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

        # take the macro genre whose intersection with the genre column is largest as the macro genre.
        # Split draws by taking the first index
        movie_genres = [len(set(df['genres'][i].split('|')).intersection(set(mg))) for mg in macro_genres.values()]
        macro_genre_index = movie_genres.index(max(movie_genres))
        genre_list.append(list(macro_genres.keys())[macro_genre_index])

    df['major'] = major_list
    df['macro_genre'] = genre_list

    # Only keep columns we're going to use for the network
    copy_df = df[list(cols.keys())]
    copy_df = copy_df.astype(dtype=cols, copy=True)

    # rename columns
    copy_df.columns = [
        'title',
        'budget_',
        'budget',
        'genres',
        'genre',
        'original_language',
        'popularity_',
        'revenue_',
        'revenue',
        'community_vote_',
        'community_vote',
        'community_count_',
        'community_count',
        'critics_vote_',
        'critics_vote',
        'critics_count_',
        'critics_count',
        'director_name',
        'actor_1_name',
        'actor_2_name',
        'actor_3_name',
        'cast_popularity_',
        'cast_popularity',
        'us',
        'major',
        'roi_',
        'roi',
        'popularity']
    # Discard all remaining 0 reviews movies
    return copy_df[copy_df['community_vote_'] > 0]


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


def get_critics_rating(title):
    print('Sending request for %s' % title)

    title = unidecode.unidecode(title)
    r = requests.get(r"http://api.marcalencc.com/metacritic/movie/{0}".format(title))
    if r.status_code == 200:
        try:
            rating = r.json()[0]['Rating']
            return rating['CriticRating'] / 10, rating['CriticReviewCount']
        except KeyError:
            return 0, 0

    return 0, 0


def retrieve_critics_data(df):
    """
    Retrieve additional data (e.g. metacritic's critics review)
    :param df: the dataframe to be updated
    :return: the updated dataframe
    """
    # First replace .:, and ' &' with the empty string. Then, replace non letters/digits with a dash
    titles = df['title'].apply(lambda x: re.sub("[^\w']", "-", re.sub("(?:[.:,]|\s&)", "", x)))

    ratings = titles.apply(get_critics_rating)

    df['critics_vote'] = [r[0] for r in ratings]
    df['critics_count'] = [r[1] for r in ratings]

    return df


def update_critics(df, chunksize=50):
    if 'critics_count' not in list(df.columns):
        df['critics_vote'] = 0
        df['critics_count'] = 0

    # Do this in chunks and save every now and then
    # Filter out rows which already has critics data
    zero_count = df[df['critics_count'] == 0]
    iterations = numpy.math.floor(len(zero_count)/chunksize)+1

    for i in range(iterations):
        chunk = zero_count.iloc[i*chunksize:(i+1)*chunksize]
        df.iloc[chunk.index] = retrieve_critics_data(chunk)

        df.to_csv(data_file, encoding='utf-8', index=False)
        print('%d movies done' % ((i+1)*chunksize))

    return df

def main():
    # load raw data and save it to data.csv
    # load_dataset.main(movies_file, credits_file, people_file, out_file=train_file)

    # process the data and save it to train.csv
    df = pd.read_csv(data_file, encoding='utf-8')
    # df = update_critics(df)

    df = process_dataset(df)
    df.to_csv(train_file, encoding='utf-8', index=False)

    # compute cpt tables and save them to cpt/. One file per cpt
    # compute_cptables(df)

    #print ('low : ', (sum([1 if i == 'low' else 0 for i in df['cast_popularity_binned']])))
    #print ('avg : ', (sum([1 if i == 'avg' else 0 for i in df['cast_popularity_binned']])))
    #print( 'hgh : ', (sum([1 if i == 'high' else 0 for i in df['cast_popularity_binned']])))


if __name__ == '__main__':
    main()
