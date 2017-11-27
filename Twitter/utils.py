def get_followers(name):
    api = tweepy.API(auth)
    user = api.get_user(name)
    if user.followers_count < 5000:
        followers = user.followers_ids()
    else:
        followers = []
        for page in tweepy.Cursor(api.followers_ids, screen_name=name).pages():
            followers.extend(page)
            time.sleep(60)
    return followers

def get_friends(name):
    api = tweepy.API(auth)
    user = api.get_user(name)
    if user.followers_count < 5000:
        friends = api.friends_ids(screen_name=name)
    else:
        friends = []
        for page in tweepy.Cursor(api.friends_ids, screen_name=name).pages():
            friends.extend(page)
            time.sleep(60)
    return friends

def try_get_users(userid):
    api = tweepy.API(auth)
    while True:
        try:
            user = api.get_user(userid)
            break
        except:
            time.sleep(60)
            continue
    return user