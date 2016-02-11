# Description
#   Pulls the most popular reddit post from a specified subreddit
# Commands
#   hubot reddit <subreddit> - Display most popular reddit post from subreddit

username = process.env.HUBOT_REDDIT_USERNAME
password = process.env.HUBOT_REDDIT_PASSWORD
clientID = process.env.HUBOT_REDDIT_CLIENT_ID
clientSecret = process.env.HUBOT_REDDIT_CLIENT_SECRET

oAuthToken = ''
expiration = new Date().getMilliseconds()

getOAuth = (now, res, callback) ->
  clientPost = "grant_type=password&username=#{username}&password=#{password}"
  robot.http("https://#{clientID}:#{clientSecret}@www.reddit.com/api/v1/access_token").post(clientPost) (err, rs, body) ->
    oAuth = JSON.parse(body)
    oAuthToken = oAuth.access_token
    expiration = now + oAuth.expires_in
    callback()

searchSubreddit = (res) ->
  query = res.match[1]
  res.http("https://oauth.reddit.com/r/#{query}/hot")
  .header('Authorization', "bearer #{oAuthToken}")
  .get() (err, rs, body) ->
    subreddit = JSON.parse(body)
    subreddit.data.children.some((child) ->
      if (!child.data.stickied and !child.data.is_self)
        res.send child.data.url
        return true
    )
    

module.exports = (robot) ->
  robot.respond /reddit (.*)/i, (res) ->
    now = new Date().getMilliseconds()
    if (expiration - now < 0)
      getOAuth now, res, () ->
        searchSubreddit res
    else 
      searchSubreddit res