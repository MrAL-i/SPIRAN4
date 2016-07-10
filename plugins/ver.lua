do

function run(msg, matches)
  return [[ SPIRAN Bot
-----------------------------------
A new bot for manage your Supergroups.
-----------------------------------
@SPIRAN_CHANNEL
-----------------------------------
@Mr_AL_i #Developer
-----------------------------------
@Developer_001 #Manager
-----------------------------------
Bot number : UNKNOWN
-----------------------------------
Bot version : 1.0 ]]
end

return {
  description = "Shows bot version", 
  usage = "version: Shows bot version",
  patterns = {
    "^[#!/]version$"
  }, 
  run = run 
}

end
