# Description
#   Pulls the most popular reddit post from a specified subreddit
# Commands
#   hubot reddit <subreddit> - Display most popular reddit post from subreddit

blacklistedMemeChannels = if process.env.HUBOT_BLACKLIST_MEME_CHANNELS? then process.env.HUBOT_BLACKLIST_MEME_CHANNELS.split(',') else undefined
blacklistedMemeDomains = if process.env.HUBOT_BLACKLIST_MEME_DOMAINS? then process.env.HUBOT_BLACKLIST_MEME_DOMAINS.split(',') else undefined
whitelistedNsfwChannels = if process.env.HUBOT_WHITELIST_NSFW_CHANNELS? then process.env.HUBOT_WHITELIST_NSFW_CHANNELS.split(',') else undefined

searchSubreddit = (res) ->
  query = res.match[1]
  isWhitelisted = res.message and res.message.room and (!whitelistedNsfwChannels or whitelistedNsfwChannels.indexOf(res.message.room) > -1)
  isBlacklisted = res.message and res.message.room and blacklistedMemeChannels and blacklistedMemeChannels.indexOf(res.message.room) > -1
  res.http("https://api.reddit.com/r/#{query}/hot?limit=10").get() (err, rs, body) ->
    subreddit = JSON.parse(body)
    subreddit.data.children.some((child) ->
      data = child.data
      if (!data.stickied and !data.is_self and
          (!data.over_18 or isWhitelisted) and
          !(isBlacklisted and (data.post_hint == "image" or (blacklistedMemeDomains? and blacklistedMemeDomains.some((domain) -> data.domain.indexOf(domain) > -1)))))
        res.send "#{data.title} - #{data.url}"
        return true
    )
    

module.exports = (robot) ->
  robot.respond /reddit (.*)/i, (res) ->
    searchSubreddit res