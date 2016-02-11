# Description
#   Pulls the most popular reddit post from a specified subreddit
# Commands
#   hubot reddit <subreddit> - Display most popular reddit post from subreddit

blacklistedChannels = if process.env.HUBOT_BLACKLIST_MEME_CHANNELS? then process.env.HUBOT_BLACKLIST_MEME_CHANNELS.split(',') else undefined
whitelistedNsfwChannels = if process.env.HUBOT_WHITELIST_NSFW_CHANNELS? then process.env.HUBOT_WHITELIST_NSFW_CHANNELS.split(',') else undefined

searchSubreddit = (res) ->
  query = res.match[1]
  isWhitelisted = !whitelistedNsfwChannels or whitelistedNsfwChannels.indexOf(query) > -1
  res.http("https://api.reddit.com/r/#{query}/hot?limit=10").get() (err, rs, body) ->
    subreddit = JSON.parse(body)
    subreddit.data.children.some((child) ->
      data = child.data
      if (!data.stickied and !data.is_self and (!data.over_18 or isWhitelisted))
        res.send child.data.url
        return true
    )
    

module.exports = (robot) ->
  robot.respond /reddit (.*)/i, (res) ->
    if (res.message and res.message.room and blacklistedChannels and blacklistedChannels.indexOf(res.message.room) != -1)
      return

    searchSubreddit res