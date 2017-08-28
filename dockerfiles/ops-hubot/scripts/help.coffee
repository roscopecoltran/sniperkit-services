# Description:
#   Generates help commands for Hubot. These commands are grabbed from comment blocks at the top of each file.
#
# Commands:
#   hubot help - Displays all of the help commands that Hubot knows about.
#   hubot help <query> - Displays all help commands that match <query>.
#
# URLS:
#   /hubot/help
#
# Author:
#  Raja. S

helpContents = (name, commands) ->

  """
<!DOCTYPE html>
<html>
  <head>
  <meta charset="utf-8">
  <title>#{name} Help</title>
  <style type="text/css">
    body {
      background: #d3d6d9;
      color: #636c75;
      text-shadow: 0 1px 1px rgba(255, 255, 255, .5);
      font-family: Helvetica, Arial, sans-serif;
    }
    h1 {
      margin: 8px 0;
      padding: 0;
    }
    .commands {
      font-size: 13px;
    }
    p {
      border-bottom: 1px solid #eee;
      margin: 6px 0 0 0;
      padding-bottom: 5px;
    }
    p:last-child {
      border: 0;
    }
  </style>
  </head>
  <body>
    <h1>#{name} Help</h1>
    <div class="commands">
      #{commands}
    </div>
  </body>
</html>
  """

module.exports = (robot) ->
  robot.respond /help(?:\s+(.*))?$/i, (res) ->
    cmds = renamedHelpCommands(robot)
    filter = res.match[1]

    if filter
      cmds = cmds.filter (cmd) ->
        cmd.match(new RegExp(filter, "i"))
      if cmds.length == 0
        res.send("No available commands match #{filter}")
        return

    emit = cmds.join("\n")
    if robot.adapter.constructor.name in ["SlackBot", "Room"]
      room = robot.adapter.client.rtm.dataStore.getDMByName(
        res.message.user.name)
      robot.send({room: room.id}, emit)
    else
      res.send(emit)

  robot.router.get "/#{robot.name}/help", (req, res) ->
    cmds = renamedHelpCommands(robot).map (cmd) ->
      cmd.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")

    emit = "<p>#{cmds.join "</p><p>"}</p>"
    pattern = new RegExp("#{robot.name}", "ig")
    emit = emit.replace(pattern, "<b>#{robot.name}</b>")

    res.setHeader("content-type", "text/html")
    res.end(helpContents(robot.name, emit))

renamedHelpCommands = (robot) ->
  robot_name = robot.alias or robot.name
  help_commands = robot.helpCommands().map (command) ->
    command.replace(/^hubot/i, robot_name)
  help_commands.sort()
